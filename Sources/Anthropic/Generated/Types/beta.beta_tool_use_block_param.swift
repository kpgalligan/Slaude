// Transformed from `anthropic.types.beta.beta_tool_use_block_param` (beta_tool_use_block_param.py).

import Foundation

public struct BetaToolUseBlockParam: Codable, Hashable, Sendable {
    public var id: String
    public var input: [String: JSONValue]
    public var name: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var caller: BetaToolUseBlockParam.Caller?
    /// For a toolset member tool_use, the toolset family this member belongs to.
    public var toolsetName: String??

    public init(id: String, input: [String: JSONValue], name: String, type: String = "tool_use", cacheControl: BetaCacheControlEphemeralParam?? = nil, caller: BetaToolUseBlockParam.Caller? = nil, toolsetName: String?? = nil) {
        self.id = id
        self.input = input
        self.name = name
        self.type = type
        self.cacheControl = cacheControl
        self.caller = caller
        self.toolsetName = toolsetName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case input
        case name
        case type
        case cacheControl = "cache_control"
        case caller
        case toolsetName = "toolset_name"
    }
}

extension BetaToolUseBlockParam {

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
