import Foundation

/// An error caused by another one (Python's `raise ... from err`, i.e. `__cause__`).
///
/// The retry policy walks this chain: an error thrown by middleware that wraps a retryable failure
/// (e.g. an `APIConnectionError`) keeps the request on the retry path.
public protocol ChainedError: Error {
    var cause: (any Error)? { get }
}

/// Root of the SDK's error hierarchy (`_exceptions.AnthropicError`).
open class AnthropicError: Error, ChainedError, CustomStringConvertible, LocalizedError, @unchecked Sendable {
    public let message: String

    public init(_ message: String) { self.message = message }

    open var description: String { message }
    public var errorDescription: String? { message }
    /// The error this one was raised from, if any.
    open var cause: (any Error)? { nil }
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

    open override var cause: (any Error)? { underlying }
}

/// A webhook payload could not be verified.
open class APIWebhookValidationError: APIError, @unchecked Sendable {}

/// The API responded with a 4xx or 5xx status code, or a stream ended with an `error` event.
open class APIStatusError: APIError, @unchecked Sendable {
    public let response: HTTPResponse
    /// The response's status code. For an `error` event of a stream (whose response succeeded) it is the status the
    /// API answers that `error.type` with (529 for `overloaded_error`), and `response.statusCode` is the stream's.
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
        self.type = APIStatusError.errorType(body)
        super.init(message, request: response.request, body: body)
    }

    /// An error whose status is `statusCode` rather than the response's (an `error` event of a stream).
    public init(_ message: String, response: HTTPResponse, body: JSONValue?, statusCode: Int) {
        self.response = response
        self.statusCode = statusCode
        self.requestID = response.headers["request-id"]
        self.workspaceID = response.headers["anthropic-workspace-id"]
        self.type = APIStatusError.errorType(body)
        super.init(message, request: response.request, body: body)
    }

    /// The `error.message` from the body, when present.
    public var errorMessage: String? { body?["error"]?["message"]?.stringValue }

    static func errorType(_ body: JSONValue?) -> ErrorType? {
        if case .object(let o)? = body, case .object(let err)? = o["error"], case .string(let t)? = err["type"] {
            return ErrorType(rawValue: t)
        }
        return nil
    }
}

/// The request could not be sent or the connection failed.
open class APIConnectionError: APIError, @unchecked Sendable {
    public let underlying: Error?

    public init(message: String = "Connection error.", request: HTTPRequest?, underlying: Error? = nil) {
        self.underlying = underlying
        super.init(message, request: request, body: nil)
    }

    open override var cause: (any Error)? { underlying }
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
    makeStatusError(message, body: body, response: response, status: response.statusCode)
}

/// The error class the first-party client raises for `status`, carrying `status` as its `statusCode`.
func makeStatusError(_ message: String, body: JSONValue?, response: HTTPResponse, status: Int) -> APIStatusError {
    switch status {
    case 400: return BadRequestError(message, response: response, body: body, statusCode: status)
    case 401: return AuthenticationError(message, response: response, body: body, statusCode: status)
    case 403: return PermissionDeniedError(message, response: response, body: body, statusCode: status)
    case 404: return NotFoundError(message, response: response, body: body, statusCode: status)
    case 409: return ConflictError(message, response: response, body: body, statusCode: status)
    case 413: return RequestTooLargeError(message, response: response, body: body, statusCode: status)
    case 422: return UnprocessableEntityError(message, response: response, body: body, statusCode: status)
    case 429: return RateLimitError(message, response: response, body: body, statusCode: status)
    case 529: return OverloadedError(message, response: response, body: body, statusCode: status)
    case 500...: return InternalServerError(message, response: response, body: body, statusCode: status)
    default: return APIStatusError(message, response: response, body: body, statusCode: status)
    }
}

/// The HTTP status the API answers each `error.type` with (https://docs.anthropic.com/en/api/errors).
let errorTypeStatus: [String: Int] = [
    "invalid_request_error": 400, "authentication_error": 401, "billing_error": 402, "permission_error": 403,
    "not_found_error": 404, "request_too_large": 413, "rate_limit_error": 429, "api_error": 500, "timeout_error": 504,
    "overloaded_error": 529,
]

/// The typed error for an `error` event of a stream: the class a response with the status of its `error.type` gets,
/// with that status. `nil` when the event names no `error.type` this SDK knows.
///
/// The Python SDK raises an `APIStatusError` with the stream's status (200) for every `error` event, so a mid-stream
/// `overloaded_error` is not an `OverloadedError` there; here it is.
func makeStreamEventError(_ message: String, body: JSONValue?, response: HTTPResponse) -> APIStatusError? {
    guard let type = body?["error"]?["type"]?.stringValue, let status = errorTypeStatus[type] else { return nil }
    return makeStatusError(message, body: body, response: response, status: status)
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
