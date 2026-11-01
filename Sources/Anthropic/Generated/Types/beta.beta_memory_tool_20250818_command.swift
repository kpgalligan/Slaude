// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_command` (beta_memory_tool_20250818_command.py).

import Foundation

public indirect enum BetaMemoryTool20250818Command: Codable, Hashable, Sendable {
    case view(BetaMemoryTool20250818ViewCommand)
    case create(BetaMemoryTool20250818CreateCommand)
    case strReplace(BetaMemoryTool20250818StrReplaceCommand)
    case insert(BetaMemoryTool20250818InsertCommand)
    case delete(BetaMemoryTool20250818DeleteCommand)
    case rename(BetaMemoryTool20250818RenameCommand)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "command") {
        case "view": self = .view(try BetaMemoryTool20250818ViewCommand(from: decoder))
        case "create": self = .create(try BetaMemoryTool20250818CreateCommand(from: decoder))
        case "str_replace": self = .strReplace(try BetaMemoryTool20250818StrReplaceCommand(from: decoder))
        case "insert": self = .insert(try BetaMemoryTool20250818InsertCommand(from: decoder))
        case "delete": self = .delete(try BetaMemoryTool20250818DeleteCommand(from: decoder))
        case "rename": self = .rename(try BetaMemoryTool20250818RenameCommand(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .view(let v): try v.encode(to: encoder)
        case .create(let v): try v.encode(to: encoder)
        case .strReplace(let v): try v.encode(to: encoder)
        case .insert(let v): try v.encode(to: encoder)
        case .delete(let v): try v.encode(to: encoder)
        case .rename(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
