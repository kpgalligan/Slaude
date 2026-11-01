// Transformed from `anthropic.types.computer_member_input` (computer_member_input.py).

import Foundation

public indirect enum ComputerMemberInput: Codable, Hashable, Sendable {
    case computerKeyInput(ComputerKeyInput)
    case computerHoldKeyInput(ComputerHoldKeyInput)
    case computerTypeInput(ComputerTypeInput)
    case computerCursorPositionInput(ComputerCursorPositionInput)
    case computerMouseMoveInput(ComputerMouseMoveInput)
    case computerLeftMouseDownInput(ComputerLeftMouseDownInput)
    case computerLeftMouseUpInput(ComputerLeftMouseUpInput)
    case computerLeftClickInput(ComputerLeftClickInput)
    case computerLeftClickDragInput(ComputerLeftClickDragInput)
    case computerRightClickInput(ComputerRightClickInput)
    case computerMiddleClickInput(ComputerMiddleClickInput)
    case computerDoubleClickInput(ComputerDoubleClickInput)
    case computerTripleClickInput(ComputerTripleClickInput)
    case computerScrollInput(ComputerScrollInput)
    case computerWaitInput(ComputerWaitInput)
    case computerScreenshotInput(ComputerScreenshotInput)
    case computerZoomInput(ComputerZoomInput)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? ComputerKeyInput(from: decoder) { self = .computerKeyInput(v); return }
        if let v = try? ComputerHoldKeyInput(from: decoder) { self = .computerHoldKeyInput(v); return }
        if let v = try? ComputerTypeInput(from: decoder) { self = .computerTypeInput(v); return }
        if let v = try? ComputerCursorPositionInput(from: decoder) { self = .computerCursorPositionInput(v); return }
        if let v = try? ComputerMouseMoveInput(from: decoder) { self = .computerMouseMoveInput(v); return }
        if let v = try? ComputerLeftMouseDownInput(from: decoder) { self = .computerLeftMouseDownInput(v); return }
        if let v = try? ComputerLeftMouseUpInput(from: decoder) { self = .computerLeftMouseUpInput(v); return }
        if let v = try? ComputerLeftClickInput(from: decoder) { self = .computerLeftClickInput(v); return }
        if let v = try? ComputerLeftClickDragInput(from: decoder) { self = .computerLeftClickDragInput(v); return }
        if let v = try? ComputerRightClickInput(from: decoder) { self = .computerRightClickInput(v); return }
        if let v = try? ComputerMiddleClickInput(from: decoder) { self = .computerMiddleClickInput(v); return }
        if let v = try? ComputerDoubleClickInput(from: decoder) { self = .computerDoubleClickInput(v); return }
        if let v = try? ComputerTripleClickInput(from: decoder) { self = .computerTripleClickInput(v); return }
        if let v = try? ComputerScrollInput(from: decoder) { self = .computerScrollInput(v); return }
        if let v = try? ComputerWaitInput(from: decoder) { self = .computerWaitInput(v); return }
        if let v = try? ComputerScreenshotInput(from: decoder) { self = .computerScreenshotInput(v); return }
        if let v = try? ComputerZoomInput(from: decoder) { self = .computerZoomInput(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .computerKeyInput(let v): try v.encode(to: encoder)
        case .computerHoldKeyInput(let v): try v.encode(to: encoder)
        case .computerTypeInput(let v): try v.encode(to: encoder)
        case .computerCursorPositionInput(let v): try v.encode(to: encoder)
        case .computerMouseMoveInput(let v): try v.encode(to: encoder)
        case .computerLeftMouseDownInput(let v): try v.encode(to: encoder)
        case .computerLeftMouseUpInput(let v): try v.encode(to: encoder)
        case .computerLeftClickInput(let v): try v.encode(to: encoder)
        case .computerLeftClickDragInput(let v): try v.encode(to: encoder)
        case .computerRightClickInput(let v): try v.encode(to: encoder)
        case .computerMiddleClickInput(let v): try v.encode(to: encoder)
        case .computerDoubleClickInput(let v): try v.encode(to: encoder)
        case .computerTripleClickInput(let v): try v.encode(to: encoder)
        case .computerScrollInput(let v): try v.encode(to: encoder)
        case .computerWaitInput(let v): try v.encode(to: encoder)
        case .computerScreenshotInput(let v): try v.encode(to: encoder)
        case .computerZoomInput(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
