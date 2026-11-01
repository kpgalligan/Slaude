// Transformed from `anthropic.resources.beta.webhooks` (webhooks.py).

import Foundation

public struct BetaWebhooksResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public struct WithRawResponse: Sendable {
        let resource: BetaWebhooksResource
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaWebhooksResource
    }

    public indirect enum UnwrapKey: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case data(Data)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Data(from: decoder) { self = .data(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .data(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
