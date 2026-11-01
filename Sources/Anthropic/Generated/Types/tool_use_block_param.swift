// Transformed from `anthropic.types.tool_use_block_param` (tool_use_block_param.py).

import Foundation

public struct ToolUseBlockParam: Codable, Hashable, Sendable {
    public var id: String
    public var input: [String: JSONValue]
    public var name: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var caller: ToolUseBlockParam.Caller?
    /// For a toolset member tool_use, the toolset family this member belongs to.
    public var toolsetName: String??

    public init(id: String, input: [String: JSONValue], name: String, type: String = "tool_use", cacheControl: CacheControlEphemeralParam?? = nil, caller: ToolUseBlockParam.Caller? = nil, toolsetName: String?? = nil) {
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

extension ToolUseBlockParam {

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
