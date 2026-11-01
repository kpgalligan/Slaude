import Foundation

/// Root of the SDK's error hierarchy (`_exceptions.AnthropicError`).
open class AnthropicError: Error, CustomStringConvertible, LocalizedError, @unchecked Sendable {
    public let message: String

    public init(_ message: String) { self.message = message }

    open var description: String { message }
    public var errorDescription: String? { message }
}

/// An error tied to an API request (`APIError`).
open class APIError: AnthropicError, @unchecked Sendable {
    public let request: HTTPRequest?
    /// The API response body: decoded JSON when the API responded with valid JSON,
    /// otherwise the raw text, or `nil` when there was no response.
    public let body: JSONValue?

    public init(_ message: String, request: HTTPRequest?, body: JSONValue?) {
        self.request = request
        self.body = body
        super.init(message)
    }
}

/// The API returned data that doesn't match the expected schema.
open class APIResponseValidationError: APIError, @unchecked Sendable {
    public let response: HTTPResponse
    public let statusCode: Int
    public let underlying: Error?

    public init(response: HTTPResponse, body: JSONValue?, message: String? = nil, underlying: Error? = nil) {
        self.response = response
        self.statusCode = response.statusCode
        self.underlying = underlying
        super.init(message ?? "Data returned by API invalid for expected schema.", request: response.request, body: body)
    }
}

/// A webhook payload could not be verified.
open class APIWebhookValidationError: APIError, @unchecked Sendable {}

/// The API responded with a 4xx or 5xx status code.
open class APIStatusError: APIError, @unchecked Sendable {
    public let response: HTTPResponse
    public let statusCode: Int
    public let requestID: String?
    public let workspaceID: String?
    /// The `error.type` from the response body, when present.
    public let type: ErrorType?

    public required init(_ message: String, response: HTTPResponse, body: JSONValue?) {
        self.response = response
        self.statusCode = response.statusCode
        self.requestID = response.headers["request-id"]
        self.workspaceID = response.headers["anthropic-workspace-id"]
        if case .object(let o)? = body, case .object(let err)? = o["error"], case .string(let t)? = err["type"] {
            self.type = ErrorType(rawValue: t)
        } else {
            self.type = nil
        }
        super.init(message, request: response.request, body: body)
    }
}

/// The request could not be sent or the connection failed.
open class APIConnectionError: APIError, @unchecked Sendable {
    public let underlying: Error?

    public init(message: String = "Connection error.", request: HTTPRequest?, underlying: Error? = nil) {
        self.underlying = underlying
        super.init(message, request: request, body: nil)
    }
}

/// The request timed out.
open class APITimeoutError: APIConnectionError, @unchecked Sendable {
    public init(request: HTTPRequest?) {
        super.init(
            message: "Request timed out or interrupted. This could be due to a network timeout, dropped connection, or request cancellation. See https://docs.anthropic.com/en/api/errors#long-requests for more details.",
            request: request
        )
    }
}

/// An error that opts into the SDK's retry policy: throw it (e.g. from middleware) to have the
/// request attempt retried while retries remain.
open class RetryableError: AnthropicError, @unchecked Sendable {}

/// Credentials cannot be loaded from local files, config, or the environment.
open class CredentialsError: AnthropicError, @unchecked Sendable {}

/// The identity token file does not exist, is empty, or cannot be read.
open class IdentityTokenFileError: CredentialsError, @unchecked Sendable {
    public let path: URL?
    public init(_ message: String, path: URL? = nil) {
        self.path = path
        super.init(message)
    }
}

/// A Python built-in `ValueError` equivalent: an argument value is invalid.
public struct ValueError: Error, CustomStringConvertible, LocalizedError, Sendable, Equatable {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var description: String { message }
    public var errorDescription: String? { message }
}

/// A Python built-in `TypeError` equivalent: an argument has the wrong kind or is missing.
public struct ArgumentTypeError: Error, CustomStringConvertible, LocalizedError, Sendable, Equatable {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var description: String { message }
    public var errorDescription: String? { message }
}

open class BadRequestError: APIStatusError, @unchecked Sendable {}
open class AuthenticationError: APIStatusError, @unchecked Sendable {}
open class PermissionDeniedError: APIStatusError, @unchecked Sendable {}
open class NotFoundError: APIStatusError, @unchecked Sendable {}
open class ConflictError: APIStatusError, @unchecked Sendable {}
open class RequestTooLargeError: APIStatusError, @unchecked Sendable {}
open class UnprocessableEntityError: APIStatusError, @unchecked Sendable {}
open class RateLimitError: APIStatusError, @unchecked Sendable {}
open class ServiceUnavailableError: APIStatusError, @unchecked Sendable {}
open class OverloadedError: APIStatusError, @unchecked Sendable {}
open class DeadlineExceededError: APIStatusError, @unchecked Sendable {}
open class InternalServerError: APIStatusError, @unchecked Sendable {}

/// Builds the typed status error for a response (`Anthropic._make_status_error`).
func makeStatusError(_ message: String, body: JSONValue?, response: HTTPResponse) -> APIStatusError {
    switch response.statusCode {
    case 400: return BadRequestError(message, response: response, body: body)
    case 401: return AuthenticationError(message, response: response, body: body)
    case 403: return PermissionDeniedError(message, response: response, body: body)
    case 404: return NotFoundError(message, response: response, body: body)
    case 409: return ConflictError(message, response: response, body: body)
    case 413: return RequestTooLargeError(message, response: response, body: body)
    case 422: return UnprocessableEntityError(message, response: response, body: body)
    case 429: return RateLimitError(message, response: response, body: body)
    case 529: return OverloadedError(message, response: response, body: body)
    case 500...: return InternalServerError(message, response: response, body: body)
    default: return APIStatusError(message, response: response, body: body)
    }
}

/// Renders a JSON value the way Python's `str()` renders the decoded object, so error messages
/// match the Python SDK's (`Error code: 400 - {'error': {...}}`).
func pythonRepr(_ value: JSONValue) -> String {
    switch value {
    case .null: return "None"
    case .bool(let b): return b ? "True" : "False"
    case .int(let i): return String(i)
    case .double(let d): return pythonFloatString(d)
    case .string(let s): return pythonStringRepr(s)
    case .array(let a): return "[" + a.map(pythonRepr).joined(separator: ", ") + "]"
    case .object(let o):
        // JSON object order is not preserved by `JSONValue`; sort for determinism.
        return "{" + o.sorted(by: { $0.key < $1.key }).map { "\(pythonStringRepr($0.key)): \(pythonRepr($0.value))" }.joined(separator: ", ") + "}"
    }
}

func pythonStringRepr(_ s: String) -> String {
    let quote: Character = s.contains("'") && !s.contains("\"") ? "\"" : "'"
    var out = String(quote)
    for ch in s {
        switch ch {
        case "\\": out += "\\\\"
        case "\n": out += "\\n"
        case "\r": out += "\\r"
        case "\t": out += "\\t"
        case quote: out += "\\" + String(quote)
        default: out.append(ch)
        }
    }
    out.append(quote)
    return out
}
