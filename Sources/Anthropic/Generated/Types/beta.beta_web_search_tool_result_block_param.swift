// Transformed from `anthropic.types.beta.beta_web_search_tool_result_block_param` (beta_web_search_tool_result_block_param.py).

import Foundation

public struct BetaWebSearchToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BetaWebSearchToolResultBlockParamContentParam
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var caller: BetaWebSearchToolResultBlockParam.Caller?

    public init(content: BetaWebSearchToolResultBlockParamContentParam, toolUseID: String, type: String = "web_search_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil, caller: BetaWebSearchToolResultBlockParam.Caller? = nil) {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
        self.cacheControl = cacheControl
        self.caller = caller
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
        case cacheControl = "cache_control"
        case caller
    }
}

extension BetaWebSearchToolResultBlockParam {

    public indirect enum Caller: Codable, Hashable, Sendable {
        case direct(BetaDirectCallerParam)
        case codeExecution20250825(BetaServerToolCallerParam)
        case codeExecution20260120(BetaServerToolCaller20260120Param)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "direct": self = .direct(try BetaDirectCallerParam(from: decoder))
            case "code_execution_20250825": self = .codeExecution20250825(try BetaServerToolCallerParam(from: decoder))
            case "code_execution_20260120": self = .codeExecution20260120(try BetaServerToolCaller20260120Param(from: decoder))
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
