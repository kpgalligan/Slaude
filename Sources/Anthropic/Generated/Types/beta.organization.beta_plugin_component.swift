// Transformed from `anthropic.types.beta.organization.beta_plugin_component` (beta_plugin_component.py).

import Foundation

public struct BetaPluginComponent: Codable, Hashable, Sendable {
    /// What the component declares about itself; always null for MCP servers, hooks,
    /// and CLIs.
    public var description: String?
    /// The component's name: a skill's, command's or agent's name, an MCP server's key
    /// in the manifest, the event a hook runs on, or a CLI's executable.
    public var name: String
    /// The kind of component.
    public var type: TypeValue

    public init(description: String? = nil, name: String, type: TypeValue) {
        self.description = description
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case description
        case name
        case type
    }

    public enum TypeValue: OpenEnum, CaseIterable {
        case agent
        case cli
        case command
        case hook
        case mcpServer
        case skill
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [TypeValue] = [.agent, .cli, .command, .hook, .mcpServer, .skill]

        public init(rawValue: String) {
            switch rawValue {
            case "agent": self = .agent
            case "cli": self = .cli
            case "command": self = .command
            case "hook": self = .hook
            case "mcp_server": self = .mcpServer
            case "skill": self = .skill
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .agent: return "agent"
            case .cli: return "cli"
            case .command: return "command"
            case .hook: return "hook"
            case .mcpServer: return "mcp_server"
            case .skill: return "skill"
            case .unknown(let value): return value
            }
        }
    }
}
