// Transformed from `anthropic.types.beta.beta_dream_status` (beta_dream_status.py).

import Foundation

public enum BetaDreamStatus: OpenEnum, CaseIterable {
    case pending
    case running
    case completed
    case failed
    case canceled
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaDreamStatus] = [.pending, .running, .completed, .failed, .canceled]

    public init(rawValue: String) {
        switch rawValue {
        case "pending": self = .pending
        case "running": self = .running
        case "completed": self = .completed
        case "failed": self = .failed
        case "canceled": self = .canceled
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .pending: return "pending"
        case .running: return "running"
        case .completed: return "completed"
        case .failed: return "failed"
        case .canceled: return "canceled"
        case .unknown(let value): return value
        }
    }
}
