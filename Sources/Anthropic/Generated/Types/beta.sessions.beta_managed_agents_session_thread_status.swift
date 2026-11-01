// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread_status` (beta_managed_agents_session_thread_status.py).

import Foundation

public enum BetaManagedAgentsSessionThreadStatus: OpenEnum, CaseIterable {
    case running
    case idle
    case rescheduling
    case terminated
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsSessionThreadStatus] = [.running, .idle, .rescheduling, .terminated]

    public init(rawValue: String) {
        switch rawValue {
        case "running": self = .running
        case "idle": self = .idle
        case "rescheduling": self = .rescheduling
        case "terminated": self = .terminated
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .running: return "running"
        case .idle: return "idle"
        case .rescheduling: return "rescheduling"
        case .terminated: return "terminated"
        case .unknown(let value): return value
        }
    }
}
