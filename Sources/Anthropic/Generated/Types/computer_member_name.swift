// Transformed from `anthropic.types.computer_member_name` (computer_member_name.py).

import Foundation

public enum ComputerMemberName: OpenEnum, CaseIterable {
    case key
    case holdKey
    case type
    case cursorPosition
    case mouseMove
    case leftMouseDown
    case leftMouseUp
    case leftClick
    case leftClickDrag
    case rightClick
    case middleClick
    case doubleClick
    case tripleClick
    case scroll
    case wait
    case screenshot
    case zoom
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [ComputerMemberName] = [.key, .holdKey, .type, .cursorPosition, .mouseMove, .leftMouseDown, .leftMouseUp, .leftClick, .leftClickDrag, .rightClick, .middleClick, .doubleClick, .tripleClick, .scroll, .wait, .screenshot, .zoom]

    public init(rawValue: String) {
        switch rawValue {
        case "key": self = .key
        case "hold_key": self = .holdKey
        case "type": self = .type
        case "cursor_position": self = .cursorPosition
        case "mouse_move": self = .mouseMove
        case "left_mouse_down": self = .leftMouseDown
        case "left_mouse_up": self = .leftMouseUp
        case "left_click": self = .leftClick
        case "left_click_drag": self = .leftClickDrag
        case "right_click": self = .rightClick
        case "middle_click": self = .middleClick
        case "double_click": self = .doubleClick
        case "triple_click": self = .tripleClick
        case "scroll": self = .scroll
        case "wait": self = .wait
        case "screenshot": self = .screenshot
        case "zoom": self = .zoom
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .key: return "key"
        case .holdKey: return "hold_key"
        case .type: return "type"
        case .cursorPosition: return "cursor_position"
        case .mouseMove: return "mouse_move"
        case .leftMouseDown: return "left_mouse_down"
        case .leftMouseUp: return "left_mouse_up"
        case .leftClick: return "left_click"
        case .leftClickDrag: return "left_click_drag"
        case .rightClick: return "right_click"
        case .middleClick: return "middle_click"
        case .doubleClick: return "double_click"
        case .tripleClick: return "triple_click"
        case .scroll: return "scroll"
        case .wait: return "wait"
        case .screenshot: return "screenshot"
        case .zoom: return "zoom"
        case .unknown(let value): return value
        }
    }
}
