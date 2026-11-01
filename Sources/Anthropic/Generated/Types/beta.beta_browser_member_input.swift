// Transformed from `anthropic.types.beta.beta_browser_member_input` (beta_browser_member_input.py).

import Foundation

public indirect enum BetaBrowserMemberInput: Codable, Hashable, Sendable {
    case betaBrowserNavigateInput(BetaBrowserNavigateInput)
    case betaBrowserListTabsInput(BetaBrowserListTabsInput)
    case betaBrowserNewTabInput(BetaBrowserNewTabInput)
    case betaBrowserSwitchTabInput(BetaBrowserSwitchTabInput)
    case betaBrowserCloseTabInput(BetaBrowserCloseTabInput)
    case betaBrowserReadPageInput(BetaBrowserReadPageInput)
    case betaBrowserGetPageTextInput(BetaBrowserGetPageTextInput)
    case betaBrowserReadConsoleInput(BetaBrowserReadConsoleInput)
    case betaBrowserReadNetworkInput(BetaBrowserReadNetworkInput)
    case betaBrowserFindInput(BetaBrowserFindInput)
    case betaBrowserFormInputInput(BetaBrowserFormInputInput)
    case betaBrowserFileUploadInput(BetaBrowserFileUploadInput)
    case betaBrowserScrollToInput(BetaBrowserScrollToInput)
    case betaBrowserScreenshotInput(BetaBrowserScreenshotInput)
    case betaBrowserZoomInput(BetaBrowserZoomInput)
    case betaBrowserLeftClickInput(BetaBrowserLeftClickInput)
    case betaBrowserRightClickInput(BetaBrowserRightClickInput)
    case betaBrowserMiddleClickInput(BetaBrowserMiddleClickInput)
    case betaBrowserDoubleClickInput(BetaBrowserDoubleClickInput)
    case betaBrowserTripleClickInput(BetaBrowserTripleClickInput)
    case betaBrowserHoverInput(BetaBrowserHoverInput)
    case betaBrowserLeftClickDragInput(BetaBrowserLeftClickDragInput)
    case betaBrowserLeftMouseDownInput(BetaBrowserLeftMouseDownInput)
    case betaBrowserLeftMouseUpInput(BetaBrowserLeftMouseUpInput)
    case betaBrowserMouseMoveInput(BetaBrowserMouseMoveInput)
    case betaBrowserScrollInput(BetaBrowserScrollInput)
    case betaBrowserTypeInput(BetaBrowserTypeInput)
    case betaBrowserKeyInput(BetaBrowserKeyInput)
    case betaBrowserHoldKeyInput(BetaBrowserHoldKeyInput)
    case betaBrowserWaitInput(BetaBrowserWaitInput)
    case betaBrowserJavascriptExecInput(BetaBrowserJavascriptExecInput)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaBrowserNavigateInput(from: decoder) { self = .betaBrowserNavigateInput(v); return }
        if let v = try? BetaBrowserListTabsInput(from: decoder) { self = .betaBrowserListTabsInput(v); return }
        if let v = try? BetaBrowserNewTabInput(from: decoder) { self = .betaBrowserNewTabInput(v); return }
        if let v = try? BetaBrowserSwitchTabInput(from: decoder) { self = .betaBrowserSwitchTabInput(v); return }
        if let v = try? BetaBrowserCloseTabInput(from: decoder) { self = .betaBrowserCloseTabInput(v); return }
        if let v = try? BetaBrowserReadPageInput(from: decoder) { self = .betaBrowserReadPageInput(v); return }
        if let v = try? BetaBrowserGetPageTextInput(from: decoder) { self = .betaBrowserGetPageTextInput(v); return }
        if let v = try? BetaBrowserReadConsoleInput(from: decoder) { self = .betaBrowserReadConsoleInput(v); return }
        if let v = try? BetaBrowserReadNetworkInput(from: decoder) { self = .betaBrowserReadNetworkInput(v); return }
        if let v = try? BetaBrowserFindInput(from: decoder) { self = .betaBrowserFindInput(v); return }
        if let v = try? BetaBrowserFormInputInput(from: decoder) { self = .betaBrowserFormInputInput(v); return }
        if let v = try? BetaBrowserFileUploadInput(from: decoder) { self = .betaBrowserFileUploadInput(v); return }
        if let v = try? BetaBrowserScrollToInput(from: decoder) { self = .betaBrowserScrollToInput(v); return }
        if let v = try? BetaBrowserScreenshotInput(from: decoder) { self = .betaBrowserScreenshotInput(v); return }
        if let v = try? BetaBrowserZoomInput(from: decoder) { self = .betaBrowserZoomInput(v); return }
        if let v = try? BetaBrowserLeftClickInput(from: decoder) { self = .betaBrowserLeftClickInput(v); return }
        if let v = try? BetaBrowserRightClickInput(from: decoder) { self = .betaBrowserRightClickInput(v); return }
        if let v = try? BetaBrowserMiddleClickInput(from: decoder) { self = .betaBrowserMiddleClickInput(v); return }
        if let v = try? BetaBrowserDoubleClickInput(from: decoder) { self = .betaBrowserDoubleClickInput(v); return }
        if let v = try? BetaBrowserTripleClickInput(from: decoder) { self = .betaBrowserTripleClickInput(v); return }
        if let v = try? BetaBrowserHoverInput(from: decoder) { self = .betaBrowserHoverInput(v); return }
        if let v = try? BetaBrowserLeftClickDragInput(from: decoder) { self = .betaBrowserLeftClickDragInput(v); return }
        if let v = try? BetaBrowserLeftMouseDownInput(from: decoder) { self = .betaBrowserLeftMouseDownInput(v); return }
        if let v = try? BetaBrowserLeftMouseUpInput(from: decoder) { self = .betaBrowserLeftMouseUpInput(v); return }
        if let v = try? BetaBrowserMouseMoveInput(from: decoder) { self = .betaBrowserMouseMoveInput(v); return }
        if let v = try? BetaBrowserScrollInput(from: decoder) { self = .betaBrowserScrollInput(v); return }
        if let v = try? BetaBrowserTypeInput(from: decoder) { self = .betaBrowserTypeInput(v); return }
        if let v = try? BetaBrowserKeyInput(from: decoder) { self = .betaBrowserKeyInput(v); return }
        if let v = try? BetaBrowserHoldKeyInput(from: decoder) { self = .betaBrowserHoldKeyInput(v); return }
        if let v = try? BetaBrowserWaitInput(from: decoder) { self = .betaBrowserWaitInput(v); return }
        if let v = try? BetaBrowserJavascriptExecInput(from: decoder) { self = .betaBrowserJavascriptExecInput(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaBrowserNavigateInput(let v): try v.encode(to: encoder)
        case .betaBrowserListTabsInput(let v): try v.encode(to: encoder)
        case .betaBrowserNewTabInput(let v): try v.encode(to: encoder)
        case .betaBrowserSwitchTabInput(let v): try v.encode(to: encoder)
        case .betaBrowserCloseTabInput(let v): try v.encode(to: encoder)
        case .betaBrowserReadPageInput(let v): try v.encode(to: encoder)
        case .betaBrowserGetPageTextInput(let v): try v.encode(to: encoder)
        case .betaBrowserReadConsoleInput(let v): try v.encode(to: encoder)
        case .betaBrowserReadNetworkInput(let v): try v.encode(to: encoder)
        case .betaBrowserFindInput(let v): try v.encode(to: encoder)
        case .betaBrowserFormInputInput(let v): try v.encode(to: encoder)
        case .betaBrowserFileUploadInput(let v): try v.encode(to: encoder)
        case .betaBrowserScrollToInput(let v): try v.encode(to: encoder)
        case .betaBrowserScreenshotInput(let v): try v.encode(to: encoder)
        case .betaBrowserZoomInput(let v): try v.encode(to: encoder)
        case .betaBrowserLeftClickInput(let v): try v.encode(to: encoder)
        case .betaBrowserRightClickInput(let v): try v.encode(to: encoder)
        case .betaBrowserMiddleClickInput(let v): try v.encode(to: encoder)
        case .betaBrowserDoubleClickInput(let v): try v.encode(to: encoder)
        case .betaBrowserTripleClickInput(let v): try v.encode(to: encoder)
        case .betaBrowserHoverInput(let v): try v.encode(to: encoder)
        case .betaBrowserLeftClickDragInput(let v): try v.encode(to: encoder)
        case .betaBrowserLeftMouseDownInput(let v): try v.encode(to: encoder)
        case .betaBrowserLeftMouseUpInput(let v): try v.encode(to: encoder)
        case .betaBrowserMouseMoveInput(let v): try v.encode(to: encoder)
        case .betaBrowserScrollInput(let v): try v.encode(to: encoder)
        case .betaBrowserTypeInput(let v): try v.encode(to: encoder)
        case .betaBrowserKeyInput(let v): try v.encode(to: encoder)
        case .betaBrowserHoldKeyInput(let v): try v.encode(to: encoder)
        case .betaBrowserWaitInput(let v): try v.encode(to: encoder)
        case .betaBrowserJavascriptExecInput(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
