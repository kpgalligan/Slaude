// Transformed from `anthropic.types.model` (model.py).

import Foundation

public enum Model: OpenEnum, CaseIterable {
    case claudeHaiku5_5
    case claudeSonnet5_5
    case claudeFable5_1
    case claudeOpus5_5
    case claudeMythos5_1
    case claudeSonnet5
    case claudeFable5
    case claudeMythos5
    case claudeOpus5
    case claudeOpus4_8
    case claudeOpus4_7
    case claudeMythosPreview
    case claudeOpus4_6
    case claudeSonnet4_6
    case claudeHaiku4_5
    case claudeHaiku4_5_20251001
    case claudeOpus4_5
    case claudeOpus4_5_20251101
    case claudeSonnet4_5
    case claudeSonnet4_5_20250929
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [Model] = [.claudeHaiku5_5, .claudeSonnet5_5, .claudeFable5_1, .claudeOpus5_5, .claudeMythos5_1, .claudeSonnet5, .claudeFable5, .claudeMythos5, .claudeOpus5, .claudeOpus4_8, .claudeOpus4_7, .claudeMythosPreview, .claudeOpus4_6, .claudeSonnet4_6, .claudeHaiku4_5, .claudeHaiku4_5_20251001, .claudeOpus4_5, .claudeOpus4_5_20251101, .claudeSonnet4_5, .claudeSonnet4_5_20250929]

    public init(rawValue: String) {
        switch rawValue {
        case "claude-haiku-5-5": self = .claudeHaiku5_5
        case "claude-sonnet-5-5": self = .claudeSonnet5_5
        case "claude-fable-5-1": self = .claudeFable5_1
        case "claude-opus-5-5": self = .claudeOpus5_5
        case "claude-mythos-5-1": self = .claudeMythos5_1
        case "claude-sonnet-5": self = .claudeSonnet5
        case "claude-fable-5": self = .claudeFable5
        case "claude-mythos-5": self = .claudeMythos5
        case "claude-opus-5": self = .claudeOpus5
        case "claude-opus-4-8": self = .claudeOpus4_8
        case "claude-opus-4-7": self = .claudeOpus4_7
        case "claude-mythos-preview": self = .claudeMythosPreview
        case "claude-opus-4-6": self = .claudeOpus4_6
        case "claude-sonnet-4-6": self = .claudeSonnet4_6
        case "claude-haiku-4-5": self = .claudeHaiku4_5
        case "claude-haiku-4-5-20251001": self = .claudeHaiku4_5_20251001
        case "claude-opus-4-5": self = .claudeOpus4_5
        case "claude-opus-4-5-20251101": self = .claudeOpus4_5_20251101
        case "claude-sonnet-4-5": self = .claudeSonnet4_5
        case "claude-sonnet-4-5-20250929": self = .claudeSonnet4_5_20250929
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .claudeHaiku5_5: return "claude-haiku-5-5"
        case .claudeSonnet5_5: return "claude-sonnet-5-5"
        case .claudeFable5_1: return "claude-fable-5-1"
        case .claudeOpus5_5: return "claude-opus-5-5"
        case .claudeMythos5_1: return "claude-mythos-5-1"
        case .claudeSonnet5: return "claude-sonnet-5"
        case .claudeFable5: return "claude-fable-5"
        case .claudeMythos5: return "claude-mythos-5"
        case .claudeOpus5: return "claude-opus-5"
        case .claudeOpus4_8: return "claude-opus-4-8"
        case .claudeOpus4_7: return "claude-opus-4-7"
        case .claudeMythosPreview: return "claude-mythos-preview"
        case .claudeOpus4_6: return "claude-opus-4-6"
        case .claudeSonnet4_6: return "claude-sonnet-4-6"
        case .claudeHaiku4_5: return "claude-haiku-4-5"
        case .claudeHaiku4_5_20251001: return "claude-haiku-4-5-20251001"
        case .claudeOpus4_5: return "claude-opus-4-5"
        case .claudeOpus4_5_20251101: return "claude-opus-4-5-20251101"
        case .claudeSonnet4_5: return "claude-sonnet-4-5"
        case .claudeSonnet4_5_20250929: return "claude-sonnet-4-5-20250929"
        case .unknown(let value): return value
        }
    }
}
