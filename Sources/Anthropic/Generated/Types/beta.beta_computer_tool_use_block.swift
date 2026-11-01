// Transformed from `anthropic.types.beta.beta_computer_tool_use_block` (beta_computer_tool_use_block.py).

import Foundation

public indirect enum BetaComputerToolUseBlock: Codable, Hashable, Sendable {
    case key(BetaComputerKeyToolUseBlock)
    case holdKey(BetaComputerHoldKeyToolUseBlock)
    case type(BetaComputerTypeToolUseBlock)
    case cursorPosition(BetaComputerCursorPositionToolUseBlock)
    case mouseMove(BetaComputerMouseMoveToolUseBlock)
    case leftMouseDown(BetaComputerLeftMouseDownToolUseBlock)
    case leftMouseUp(BetaComputerLeftMouseUpToolUseBlock)
    case leftClick(BetaComputerLeftClickToolUseBlock)
    case leftClickDrag(BetaComputerLeftClickDragToolUseBlock)
    case rightClick(BetaComputerRightClickToolUseBlock)
    case middleClick(BetaComputerMiddleClickToolUseBlock)
    case doubleClick(BetaComputerDoubleClickToolUseBlock)
    case tripleClick(BetaComputerTripleClickToolUseBlock)
    case scroll(BetaComputerScrollToolUseBlock)
    case wait(BetaComputerWaitToolUseBlock)
    case screenshot(BetaComputerScreenshotToolUseBlock)
    case zoom(BetaComputerZoomToolUseBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "name") {
        case "key": self = .key(try BetaComputerKeyToolUseBlock(from: decoder))
        case "hold_key": self = .holdKey(try BetaComputerHoldKeyToolUseBlock(from: decoder))
        case "type": self = .type(try BetaComputerTypeToolUseBlock(from: decoder))
        case "cursor_position": self = .cursorPosition(try BetaComputerCursorPositionToolUseBlock(from: decoder))
        case "mouse_move": self = .mouseMove(try BetaComputerMouseMoveToolUseBlock(from: decoder))
        case "left_mouse_down": self = .leftMouseDown(try BetaComputerLeftMouseDownToolUseBlock(from: decoder))
        case "left_mouse_up": self = .leftMouseUp(try BetaComputerLeftMouseUpToolUseBlock(from: decoder))
        case "left_click": self = .leftClick(try BetaComputerLeftClickToolUseBlock(from: decoder))
        case "left_click_drag": self = .leftClickDrag(try BetaComputerLeftClickDragToolUseBlock(from: decoder))
        case "right_click": self = .rightClick(try BetaComputerRightClickToolUseBlock(from: decoder))
        case "middle_click": self = .middleClick(try BetaComputerMiddleClickToolUseBlock(from: decoder))
        case "double_click": self = .doubleClick(try BetaComputerDoubleClickToolUseBlock(from: decoder))
        case "triple_click": self = .tripleClick(try BetaComputerTripleClickToolUseBlock(from: decoder))
        case "scroll": self = .scroll(try BetaComputerScrollToolUseBlock(from: decoder))
        case "wait": self = .wait(try BetaComputerWaitToolUseBlock(from: decoder))
        case "screenshot": self = .screenshot(try BetaComputerScreenshotToolUseBlock(from: decoder))
        case "zoom": self = .zoom(try BetaComputerZoomToolUseBlock(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .key(let v): try v.encode(to: encoder)
        case .holdKey(let v): try v.encode(to: encoder)
        case .type(let v): try v.encode(to: encoder)
        case .cursorPosition(let v): try v.encode(to: encoder)
        case .mouseMove(let v): try v.encode(to: encoder)
        case .leftMouseDown(let v): try v.encode(to: encoder)
        case .leftMouseUp(let v): try v.encode(to: encoder)
        case .leftClick(let v): try v.encode(to: encoder)
        case .leftClickDrag(let v): try v.encode(to: encoder)
        case .rightClick(let v): try v.encode(to: encoder)
        case .middleClick(let v): try v.encode(to: encoder)
        case .doubleClick(let v): try v.encode(to: encoder)
        case .tripleClick(let v): try v.encode(to: encoder)
        case .scroll(let v): try v.encode(to: encoder)
        case .wait(let v): try v.encode(to: encoder)
        case .screenshot(let v): try v.encode(to: encoder)
        case .zoom(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
