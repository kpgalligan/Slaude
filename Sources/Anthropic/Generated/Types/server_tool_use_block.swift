// Transformed from `anthropic.types.server_tool_use_block` (server_tool_use_block.py).

import Foundation

public struct ServerToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    public var caller: ServerToolUseBlock.Caller?
    public var input: [String: JSONValue]
    public var name: Name
    public var type: String

    public init(id: String, caller: ServerToolUseBlock.Caller? = nil, input: [String: JSONValue], name: Name, type: String = "server_tool_use") {
        self.id = id
        self.caller = caller
        self.input = input
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case caller
        case input
        case name
        case type
    }

    public enum Name: OpenEnum, CaseIterable {
        case webSearch
        case webFetch
        case codeExecution
        case bashCodeExecution
        case textEditorCodeExecution
        case toolSearchToolRegex
        case toolSearchToolBm25
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Name] = [.webSearch, .webFetch, .codeExecution, .bashCodeExecution, .textEditorCodeExecution, .toolSearchToolRegex, .toolSearchToolBm25]

        public init(rawValue: String) {
            switch rawValue {
            case "web_search": self = .webSearch
            case "web_fetch": self = .webFetch
            case "code_execution": self = .codeExecution
            case "bash_code_execution": self = .bashCodeExecution
            case "text_editor_code_execution": self = .textEditorCodeExecution
            case "tool_search_tool_regex": self = .toolSearchToolRegex
            case "tool_search_tool_bm25": self = .toolSearchToolBm25
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .webSearch: return "web_search"
            case .webFetch: return "web_fetch"
            case .codeExecution: return "code_execution"
            case .bashCodeExecution: return "bash_code_execution"
            case .textEditorCodeExecution: return "text_editor_code_execution"
            case .toolSearchToolRegex: return "tool_search_tool_regex"
            case .toolSearchToolBm25: return "tool_search_tool_bm25"
            case .unknown(let value): return value
            }
        }
    }
}

extension ServerToolUseBlock {

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
