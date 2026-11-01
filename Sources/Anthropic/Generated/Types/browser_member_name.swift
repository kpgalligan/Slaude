// Transformed from `anthropic.types.browser_member_name` (browser_member_name.py).

import Foundation

public enum BrowserMemberName: OpenEnum, CaseIterable {
    case navigate
    case listTabs
    case newTab
    case switchTab
    case closeTab
    case readPage
    case getPageText
    case readConsole
    case readNetwork
    case find
    case formInput
    case fileUpload
    case scrollTo
    case screenshot
    case zoom
    case leftClick
    case rightClick
    case middleClick
    case doubleClick
    case tripleClick
    case hover
    case leftClickDrag
    case leftMouseDown
    case leftMouseUp
    case mouseMove
    case scroll
    case type
    case key
    case holdKey
    case wait
    case javascriptExec
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BrowserMemberName] = [.navigate, .listTabs, .newTab, .switchTab, .closeTab, .readPage, .getPageText, .readConsole, .readNetwork, .find, .formInput, .fileUpload, .scrollTo, .screenshot, .zoom, .leftClick, .rightClick, .middleClick, .doubleClick, .tripleClick, .hover, .leftClickDrag, .leftMouseDown, .leftMouseUp, .mouseMove, .scroll, .type, .key, .holdKey, .wait, .javascriptExec]

    public init(rawValue: String) {
        switch rawValue {
        case "navigate": self = .navigate
        case "list_tabs": self = .listTabs
        case "new_tab": self = .newTab
        case "switch_tab": self = .switchTab
        case "close_tab": self = .closeTab
        case "read_page": self = .readPage
        case "get_page_text": self = .getPageText
        case "read_console": self = .readConsole
        case "read_network": self = .readNetwork
        case "find": self = .find
        case "form_input": self = .formInput
        case "file_upload": self = .fileUpload
        case "scroll_to": self = .scrollTo
        case "screenshot": self = .screenshot
        case "zoom": self = .zoom
        case "left_click": self = .leftClick
        case "right_click": self = .rightClick
        case "middle_click": self = .middleClick
        case "double_click": self = .doubleClick
        case "triple_click": self = .tripleClick
        case "hover": self = .hover
        case "left_click_drag": self = .leftClickDrag
        case "left_mouse_down": self = .leftMouseDown
        case "left_mouse_up": self = .leftMouseUp
        case "mouse_move": self = .mouseMove
        case "scroll": self = .scroll
        case "type": self = .type
        case "key": self = .key
        case "hold_key": self = .holdKey
        case "wait": self = .wait
        case "javascript_exec": self = .javascriptExec
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .navigate: return "navigate"
        case .listTabs: return "list_tabs"
        case .newTab: return "new_tab"
        case .switchTab: return "switch_tab"
        case .closeTab: return "close_tab"
        case .readPage: return "read_page"
        case .getPageText: return "get_page_text"
        case .readConsole: return "read_console"
        case .readNetwork: return "read_network"
        case .find: return "find"
        case .formInput: return "form_input"
        case .fileUpload: return "file_upload"
        case .scrollTo: return "scroll_to"
        case .screenshot: return "screenshot"
        case .zoom: return "zoom"
        case .leftClick: return "left_click"
        case .rightClick: return "right_click"
        case .middleClick: return "middle_click"
        case .doubleClick: return "double_click"
        case .tripleClick: return "triple_click"
        case .hover: return "hover"
        case .leftClickDrag: return "left_click_drag"
        case .leftMouseDown: return "left_mouse_down"
        case .leftMouseUp: return "left_mouse_up"
        case .mouseMove: return "mouse_move"
        case .scroll: return "scroll"
        case .type: return "type"
        case .key: return "key"
        case .holdKey: return "hold_key"
        case .wait: return "wait"
        case .javascriptExec: return "javascript_exec"
        case .unknown(let value): return value
        }
    }
}
