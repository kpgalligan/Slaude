// Transformed from `anthropic.types.tool_use_caller` (tool_use_caller.py).

import Foundation

public indirect enum ToolUseCaller: Codable, Hashable, Sendable {
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
