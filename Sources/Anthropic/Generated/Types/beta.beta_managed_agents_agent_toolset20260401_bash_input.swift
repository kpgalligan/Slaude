// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_bash_input` (beta_managed_agents_agent_toolset20260401_bash_input.py).

import Foundation

/// Input payload for the `bash` tool of the
/// `agent_toolset_20260401` toolset.
///
/// All fields are optional;
/// a normal invocation supplies `command`, while `restart=true`
/// (with no `command`) reboots the runner-side bash session.
public struct BetaManagedAgentsAgentToolset20260401BashInput: Codable, Hashable, Sendable {
    /// Shell command to execute. Omit only when `restart` is true.
    public var command: String?
    /// When true, restart the persistent bash session instead of running a command.
    ///
    /// Subsequent calls without `restart` will run against the fresh session.
    public var restart: Bool?
    /// Per-call timeout in milliseconds.
    ///
    /// Defaults to the runner-wide tool timeout when omitted or zero.
    public var timeoutMs: Int?

    public init(command: String? = nil, restart: Bool? = nil, timeoutMs: Int? = nil) {
        self.command = command
        self.restart = restart
        self.timeoutMs = timeoutMs
    }

    enum CodingKeys: String, CodingKey {
        case command
        case restart
        case timeoutMs = "timeout_ms"
    }
}
