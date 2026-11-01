// Transformed from `anthropic.types.beta.beta_computer_member_input` (beta_computer_member_input.py).

import Foundation

public indirect enum BetaComputerMemberInput: Codable, Hashable, Sendable {
    case betaComputerKeyInput(BetaComputerKeyInput)
    case betaComputerHoldKeyInput(BetaComputerHoldKeyInput)
    case betaComputerTypeInput(BetaComputerTypeInput)
    case betaComputerCursorPositionInput(BetaComputerCursorPositionInput)
    case betaComputerMouseMoveInput(BetaComputerMouseMoveInput)
    case betaComputerLeftMouseDownInput(BetaComputerLeftMouseDownInput)
    case betaComputerLeftMouseUpInput(BetaComputerLeftMouseUpInput)
    case betaComputerLeftClickInput(BetaComputerLeftClickInput)
    case betaComputerLeftClickDragInput(BetaComputerLeftClickDragInput)
    case betaComputerRightClickInput(BetaComputerRightClickInput)
    case betaComputerMiddleClickInput(BetaComputerMiddleClickInput)
    case betaComputerDoubleClickInput(BetaComputerDoubleClickInput)
    case betaComputerTripleClickInput(BetaComputerTripleClickInput)
    case betaComputerScrollInput(BetaComputerScrollInput)
    case betaComputerWaitInput(BetaComputerWaitInput)
    case betaComputerScreenshotInput(BetaComputerScreenshotInput)
    case betaComputerZoomInput(BetaComputerZoomInput)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaComputerKeyInput(from: decoder) { self = .betaComputerKeyInput(v); return }
        if let v = try? BetaComputerHoldKeyInput(from: decoder) { self = .betaComputerHoldKeyInput(v); return }
        if let v = try? BetaComputerTypeInput(from: decoder) { self = .betaComputerTypeInput(v); return }
        if let v = try? BetaComputerCursorPositionInput(from: decoder) { self = .betaComputerCursorPositionInput(v); return }
        if let v = try? BetaComputerMouseMoveInput(from: decoder) { self = .betaComputerMouseMoveInput(v); return }
        if let v = try? BetaComputerLeftMouseDownInput(from: decoder) { self = .betaComputerLeftMouseDownInput(v); return }
        if let v = try? BetaComputerLeftMouseUpInput(from: decoder) { self = .betaComputerLeftMouseUpInput(v); return }
        if let v = try? BetaComputerLeftClickInput(from: decoder) { self = .betaComputerLeftClickInput(v); return }
        if let v = try? BetaComputerLeftClickDragInput(from: decoder) { self = .betaComputerLeftClickDragInput(v); return }
        if let v = try? BetaComputerRightClickInput(from: decoder) { self = .betaComputerRightClickInput(v); return }
        if let v = try? BetaComputerMiddleClickInput(from: decoder) { self = .betaComputerMiddleClickInput(v); return }
        if let v = try? BetaComputerDoubleClickInput(from: decoder) { self = .betaComputerDoubleClickInput(v); return }
        if let v = try? BetaComputerTripleClickInput(from: decoder) { self = .betaComputerTripleClickInput(v); return }
        if let v = try? BetaComputerScrollInput(from: decoder) { self = .betaComputerScrollInput(v); return }
        if let v = try? BetaComputerWaitInput(from: decoder) { self = .betaComputerWaitInput(v); return }
        if let v = try? BetaComputerScreenshotInput(from: decoder) { self = .betaComputerScreenshotInput(v); return }
        if let v = try? BetaComputerZoomInput(from: decoder) { self = .betaComputerZoomInput(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaComputerKeyInput(let v): try v.encode(to: encoder)
        case .betaComputerHoldKeyInput(let v): try v.encode(to: encoder)
        case .betaComputerTypeInput(let v): try v.encode(to: encoder)
        case .betaComputerCursorPositionInput(let v): try v.encode(to: encoder)
        case .betaComputerMouseMoveInput(let v): try v.encode(to: encoder)
        case .betaComputerLeftMouseDownInput(let v): try v.encode(to: encoder)
        case .betaComputerLeftMouseUpInput(let v): try v.encode(to: encoder)
        case .betaComputerLeftClickInput(let v): try v.encode(to: encoder)
        case .betaComputerLeftClickDragInput(let v): try v.encode(to: encoder)
        case .betaComputerRightClickInput(let v): try v.encode(to: encoder)
        case .betaComputerMiddleClickInput(let v): try v.encode(to: encoder)
        case .betaComputerDoubleClickInput(let v): try v.encode(to: encoder)
        case .betaComputerTripleClickInput(let v): try v.encode(to: encoder)
        case .betaComputerScrollInput(let v): try v.encode(to: encoder)
        case .betaComputerWaitInput(let v): try v.encode(to: encoder)
        case .betaComputerScreenshotInput(let v): try v.encode(to: encoder)
        case .betaComputerZoomInput(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
