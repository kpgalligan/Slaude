// Transformed from `anthropic.types.browser_member_input` (browser_member_input.py).

import Foundation

public indirect enum BrowserMemberInput: Codable, Hashable, Sendable {
    case browserNavigateInput(BrowserNavigateInput)
    case browserListTabsInput(BrowserListTabsInput)
    case browserNewTabInput(BrowserNewTabInput)
    case browserSwitchTabInput(BrowserSwitchTabInput)
    case browserCloseTabInput(BrowserCloseTabInput)
    case browserReadPageInput(BrowserReadPageInput)
    case browserGetPageTextInput(BrowserGetPageTextInput)
    case browserReadConsoleInput(BrowserReadConsoleInput)
    case browserReadNetworkInput(BrowserReadNetworkInput)
    case browserFindInput(BrowserFindInput)
    case browserFormInputInput(BrowserFormInputInput)
    case browserFileUploadInput(BrowserFileUploadInput)
    case browserScrollToInput(BrowserScrollToInput)
    case browserScreenshotInput(BrowserScreenshotInput)
    case browserZoomInput(BrowserZoomInput)
    case browserLeftClickInput(BrowserLeftClickInput)
    case browserRightClickInput(BrowserRightClickInput)
    case browserMiddleClickInput(BrowserMiddleClickInput)
    case browserDoubleClickInput(BrowserDoubleClickInput)
    case browserTripleClickInput(BrowserTripleClickInput)
    case browserHoverInput(BrowserHoverInput)
    case browserLeftClickDragInput(BrowserLeftClickDragInput)
    case browserLeftMouseDownInput(BrowserLeftMouseDownInput)
    case browserLeftMouseUpInput(BrowserLeftMouseUpInput)
    case browserMouseMoveInput(BrowserMouseMoveInput)
    case browserScrollInput(BrowserScrollInput)
    case browserTypeInput(BrowserTypeInput)
    case browserKeyInput(BrowserKeyInput)
    case browserHoldKeyInput(BrowserHoldKeyInput)
    case browserWaitInput(BrowserWaitInput)
    case browserJavascriptExecInput(BrowserJavascriptExecInput)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BrowserNavigateInput(from: decoder) { self = .browserNavigateInput(v); return }
        if let v = try? BrowserListTabsInput(from: decoder) { self = .browserListTabsInput(v); return }
        if let v = try? BrowserNewTabInput(from: decoder) { self = .browserNewTabInput(v); return }
        if let v = try? BrowserSwitchTabInput(from: decoder) { self = .browserSwitchTabInput(v); return }
        if let v = try? BrowserCloseTabInput(from: decoder) { self = .browserCloseTabInput(v); return }
        if let v = try? BrowserReadPageInput(from: decoder) { self = .browserReadPageInput(v); return }
        if let v = try? BrowserGetPageTextInput(from: decoder) { self = .browserGetPageTextInput(v); return }
        if let v = try? BrowserReadConsoleInput(from: decoder) { self = .browserReadConsoleInput(v); return }
        if let v = try? BrowserReadNetworkInput(from: decoder) { self = .browserReadNetworkInput(v); return }
        if let v = try? BrowserFindInput(from: decoder) { self = .browserFindInput(v); return }
        if let v = try? BrowserFormInputInput(from: decoder) { self = .browserFormInputInput(v); return }
        if let v = try? BrowserFileUploadInput(from: decoder) { self = .browserFileUploadInput(v); return }
        if let v = try? BrowserScrollToInput(from: decoder) { self = .browserScrollToInput(v); return }
        if let v = try? BrowserScreenshotInput(from: decoder) { self = .browserScreenshotInput(v); return }
        if let v = try? BrowserZoomInput(from: decoder) { self = .browserZoomInput(v); return }
        if let v = try? BrowserLeftClickInput(from: decoder) { self = .browserLeftClickInput(v); return }
        if let v = try? BrowserRightClickInput(from: decoder) { self = .browserRightClickInput(v); return }
        if let v = try? BrowserMiddleClickInput(from: decoder) { self = .browserMiddleClickInput(v); return }
        if let v = try? BrowserDoubleClickInput(from: decoder) { self = .browserDoubleClickInput(v); return }
        if let v = try? BrowserTripleClickInput(from: decoder) { self = .browserTripleClickInput(v); return }
        if let v = try? BrowserHoverInput(from: decoder) { self = .browserHoverInput(v); return }
        if let v = try? BrowserLeftClickDragInput(from: decoder) { self = .browserLeftClickDragInput(v); return }
        if let v = try? BrowserLeftMouseDownInput(from: decoder) { self = .browserLeftMouseDownInput(v); return }
        if let v = try? BrowserLeftMouseUpInput(from: decoder) { self = .browserLeftMouseUpInput(v); return }
        if let v = try? BrowserMouseMoveInput(from: decoder) { self = .browserMouseMoveInput(v); return }
        if let v = try? BrowserScrollInput(from: decoder) { self = .browserScrollInput(v); return }
        if let v = try? BrowserTypeInput(from: decoder) { self = .browserTypeInput(v); return }
        if let v = try? BrowserKeyInput(from: decoder) { self = .browserKeyInput(v); return }
        if let v = try? BrowserHoldKeyInput(from: decoder) { self = .browserHoldKeyInput(v); return }
        if let v = try? BrowserWaitInput(from: decoder) { self = .browserWaitInput(v); return }
        if let v = try? BrowserJavascriptExecInput(from: decoder) { self = .browserJavascriptExecInput(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .browserNavigateInput(let v): try v.encode(to: encoder)
        case .browserListTabsInput(let v): try v.encode(to: encoder)
        case .browserNewTabInput(let v): try v.encode(to: encoder)
        case .browserSwitchTabInput(let v): try v.encode(to: encoder)
        case .browserCloseTabInput(let v): try v.encode(to: encoder)
        case .browserReadPageInput(let v): try v.encode(to: encoder)
        case .browserGetPageTextInput(let v): try v.encode(to: encoder)
        case .browserReadConsoleInput(let v): try v.encode(to: encoder)
        case .browserReadNetworkInput(let v): try v.encode(to: encoder)
        case .browserFindInput(let v): try v.encode(to: encoder)
        case .browserFormInputInput(let v): try v.encode(to: encoder)
        case .browserFileUploadInput(let v): try v.encode(to: encoder)
        case .browserScrollToInput(let v): try v.encode(to: encoder)
        case .browserScreenshotInput(let v): try v.encode(to: encoder)
        case .browserZoomInput(let v): try v.encode(to: encoder)
        case .browserLeftClickInput(let v): try v.encode(to: encoder)
        case .browserRightClickInput(let v): try v.encode(to: encoder)
        case .browserMiddleClickInput(let v): try v.encode(to: encoder)
        case .browserDoubleClickInput(let v): try v.encode(to: encoder)
        case .browserTripleClickInput(let v): try v.encode(to: encoder)
        case .browserHoverInput(let v): try v.encode(to: encoder)
        case .browserLeftClickDragInput(let v): try v.encode(to: encoder)
        case .browserLeftMouseDownInput(let v): try v.encode(to: encoder)
        case .browserLeftMouseUpInput(let v): try v.encode(to: encoder)
        case .browserMouseMoveInput(let v): try v.encode(to: encoder)
        case .browserScrollInput(let v): try v.encode(to: encoder)
        case .browserTypeInput(let v): try v.encode(to: encoder)
        case .browserKeyInput(let v): try v.encode(to: encoder)
        case .browserHoldKeyInput(let v): try v.encode(to: encoder)
        case .browserWaitInput(let v): try v.encode(to: encoder)
        case .browserJavascriptExecInput(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
