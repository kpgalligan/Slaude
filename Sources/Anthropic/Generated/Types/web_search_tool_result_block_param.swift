// Transformed from `anthropic.types.web_search_tool_result_block_param` (web_search_tool_result_block_param.py).

import Foundation

public struct WebSearchToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: WebSearchToolResultBlockParamContentParam
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var caller: WebSearchToolResultBlockParam.Caller?

    public init(content: WebSearchToolResultBlockParamContentParam, toolUseId: String, type: String = "web_search_tool_result", cacheControl: CacheControlEphemeralParam?? = nil, caller: WebSearchToolResultBlockParam.Caller? = nil) {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
        self.cacheControl = cacheControl
        self.caller = caller
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
        case cacheControl = "cache_control"
        case caller
    }
}

extension WebSearchToolResultBlockParam {

    public indirect enum Caller: Codable, Hashable, Sendable {
        case direct(DirectCallerParam)
        case codeExecution20250825(ServerToolCallerParam)
        case codeExecution20260120(ServerToolCaller20260120Param)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "direct": self = .direct(try DirectCallerParam(from: decoder))
            case "code_execution_20250825": self = .codeExecution20250825(try ServerToolCallerParam(from: decoder))
            case "code_execution_20260120": self = .codeExecution20260120(try ServerToolCaller20260120Param(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .direct(let v): try v.encode(to: encoder)
            case .codeExecution20250825(let v): try v.encode(to: encoder)
            case .codeExecution20260120(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
