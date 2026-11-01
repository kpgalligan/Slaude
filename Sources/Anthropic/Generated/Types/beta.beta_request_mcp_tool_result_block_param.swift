// Transformed from `anthropic.types.beta.beta_request_mcp_tool_result_block_param` (beta_request_mcp_tool_result_block_param.py).

import Foundation

public struct BetaRequestMCPToolResultBlockParam: Codable, Hashable, Sendable {
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var content: Content?
    public var isError: Bool?

    public init(toolUseID: String, type: String = "mcp_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil, content: Content? = nil, isError: Bool? = nil) {
        self.toolUseID = toolUseID
        self.type = type
        self.cacheControl = cacheControl
        self.content = content
        self.isError = isError
    }

    enum CodingKeys: String, CodingKey {
        case toolUseID = "tool_use_id"
        case type
        case cacheControl = "cache_control"
        case content
        case isError = "is_error"
    }

    public indirect enum Content: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case betaTextBlockParams([BetaTextBlockParam])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: BetaTextBlockParam...) { self = .betaTextBlockParams(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [BetaTextBlockParam](from: decoder) { self = .betaTextBlockParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaTextBlockParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
