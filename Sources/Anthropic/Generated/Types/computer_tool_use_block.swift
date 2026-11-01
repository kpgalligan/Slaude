// Transformed from `anthropic.types.computer_tool_use_block` (computer_tool_use_block.py).

import Foundation

public indirect enum ComputerToolUseBlock: Codable, Hashable, Sendable {
    case key(ComputerKeyToolUseBlock)
    case holdKey(ComputerHoldKeyToolUseBlock)
    case type(ComputerTypeToolUseBlock)
    case cursorPosition(ComputerCursorPositionToolUseBlock)
    case mouseMove(ComputerMouseMoveToolUseBlock)
    case leftMouseDown(ComputerLeftMouseDownToolUseBlock)
    case leftMouseUp(ComputerLeftMouseUpToolUseBlock)
    case leftClick(ComputerLeftClickToolUseBlock)
    case leftClickDrag(ComputerLeftClickDragToolUseBlock)
    case rightClick(ComputerRightClickToolUseBlock)
    case middleClick(ComputerMiddleClickToolUseBlock)
    case doubleClick(ComputerDoubleClickToolUseBlock)
    case tripleClick(ComputerTripleClickToolUseBlock)
    case scroll(ComputerScrollToolUseBlock)
    case wait(ComputerWaitToolUseBlock)
    case screenshot(ComputerScreenshotToolUseBlock)
    case zoom(ComputerZoomToolUseBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "name") {
        case "key": self = .key(try ComputerKeyToolUseBlock(from: decoder))
        case "hold_key": self = .holdKey(try ComputerHoldKeyToolUseBlock(from: decoder))
        case "type": self = .type(try ComputerTypeToolUseBlock(from: decoder))
        case "cursor_position": self = .cursorPosition(try ComputerCursorPositionToolUseBlock(from: decoder))
        case "mouse_move": self = .mouseMove(try ComputerMouseMoveToolUseBlock(from: decoder))
        case "left_mouse_down": self = .leftMouseDown(try ComputerLeftMouseDownToolUseBlock(from: decoder))
        case "left_mouse_up": self = .leftMouseUp(try ComputerLeftMouseUpToolUseBlock(from: decoder))
        case "left_click": self = .leftClick(try ComputerLeftClickToolUseBlock(from: decoder))
        case "left_click_drag": self = .leftClickDrag(try ComputerLeftClickDragToolUseBlock(from: decoder))
        case "right_click": self = .rightClick(try ComputerRightClickToolUseBlock(from: decoder))
        case "middle_click": self = .middleClick(try ComputerMiddleClickToolUseBlock(from: decoder))
        case "double_click": self = .doubleClick(try ComputerDoubleClickToolUseBlock(from: decoder))
        case "triple_click": self = .tripleClick(try ComputerTripleClickToolUseBlock(from: decoder))
        case "scroll": self = .scroll(try ComputerScrollToolUseBlock(from: decoder))
        case "wait": self = .wait(try ComputerWaitToolUseBlock(from: decoder))
        case "screenshot": self = .screenshot(try ComputerScreenshotToolUseBlock(from: decoder))
        case "zoom": self = .zoom(try ComputerZoomToolUseBlock(from: decoder))
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
