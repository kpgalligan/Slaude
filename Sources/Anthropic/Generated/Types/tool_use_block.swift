// Transformed from `anthropic.types.tool_use_block` (tool_use_block.py).

import Foundation

public struct ToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    public var caller: ToolUseBlock.Caller?
    public var input: [String: JSONValue]
    public var name: String
    public var type: String
    /// For a toolset member tool_use, the toolset family.
    public var toolsetName: String?

    public init(id: String, caller: ToolUseBlock.Caller? = nil, input: [String: JSONValue], name: String, type: String = "tool_use", toolsetName: String? = nil) {
        self.id = id
        self.caller = caller
        self.input = input
        self.name = name
        self.type = type
        self.toolsetName = toolsetName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case caller
        case input
        case name
        case type
        case toolsetName = "toolset_name"
    }
}

extension ToolUseBlock {

    public indirect enum Caller: Codable, Hashable, Sendable {
        case direct(DirectCaller)
        case codeExecution20250825(ServerToolCaller)
        case codeExecution20260120(ServerToolCaller20260120)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "direct": self = .direct(try DirectCaller(from: decoder))
            case "code_execution_20250825": self = .codeExecution20250825(try ServerToolCaller(from: decoder))
            case "code_execution_20260120": self = .codeExecution20260120(try ServerToolCaller20260120(from: decoder))
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
