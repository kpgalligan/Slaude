// Transformed from `anthropic.types.beta.beta_computer_toolset_configs_param` (beta_computer_toolset_configs_param.py).

import Foundation

/// Per-member configuration for ``computer_toolset_20260801``: one
/// optional field per member tool, keyed by the member name — the same
/// name the member's ``tool_use`` blocks carry. Every member is an
/// accepted key, and a member's defaults apply wherever its key is
/// absent. Unknown keys are rejected: the field set is this toolset
/// version's complete member set.
public struct BetaComputerToolsetConfigsParam: Codable, Hashable, Sendable {
    /// `cursor_position`'s config overrides.
    public var cursorPosition: BetaComputerCursorPositionConfigParam??
    /// `double_click`'s config overrides.
    public var doubleClick: BetaComputerDoubleClickConfigParam??
    /// `hold_key`'s config overrides.
    public var holdKey: BetaComputerHoldKeyConfigParam??
    /// `key`'s config overrides.
    public var key: BetaComputerKeyConfigParam??
    /// `left_click`'s config overrides.
    public var leftClick: BetaComputerLeftClickConfigParam??
    /// `left_click_drag`'s config overrides.
    public var leftClickDrag: BetaComputerLeftClickDragConfigParam??
    /// `left_mouse_down`'s config overrides.
    public var leftMouseDown: BetaComputerLeftMouseDownConfigParam??
    /// `left_mouse_up`'s config overrides.
    public var leftMouseUp: BetaComputerLeftMouseUpConfigParam??
    /// `middle_click`'s config overrides.
    public var middleClick: BetaComputerMiddleClickConfigParam??
    /// `mouse_move`'s config overrides.
    public var mouseMove: BetaComputerMouseMoveConfigParam??
    /// `right_click`'s config overrides.
    public var rightClick: BetaComputerRightClickConfigParam??
    /// `screenshot`'s config overrides.
    public var screenshot: BetaComputerScreenshotConfigParam??
    /// `scroll`'s config overrides.
    public var scroll: BetaComputerScrollConfigParam??
    /// `triple_click`'s config overrides.
    public var tripleClick: BetaComputerTripleClickConfigParam??
    /// `type`'s config overrides.
    public var type: BetaComputerTypeConfigParam??
    /// `wait`'s config overrides.
    public var wait: BetaComputerWaitConfigParam??
    /// `zoom`'s config overrides.
    public var zoom: BetaComputerZoomConfigParam??

    public init(cursorPosition: BetaComputerCursorPositionConfigParam?? = nil, doubleClick: BetaComputerDoubleClickConfigParam?? = nil, holdKey: BetaComputerHoldKeyConfigParam?? = nil, key: BetaComputerKeyConfigParam?? = nil, leftClick: BetaComputerLeftClickConfigParam?? = nil, leftClickDrag: BetaComputerLeftClickDragConfigParam?? = nil, leftMouseDown: BetaComputerLeftMouseDownConfigParam?? = nil, leftMouseUp: BetaComputerLeftMouseUpConfigParam?? = nil, middleClick: BetaComputerMiddleClickConfigParam?? = nil, mouseMove: BetaComputerMouseMoveConfigParam?? = nil, rightClick: BetaComputerRightClickConfigParam?? = nil, screenshot: BetaComputerScreenshotConfigParam?? = nil, scroll: BetaComputerScrollConfigParam?? = nil, tripleClick: BetaComputerTripleClickConfigParam?? = nil, type: BetaComputerTypeConfigParam?? = nil, wait: BetaComputerWaitConfigParam?? = nil, zoom: BetaComputerZoomConfigParam?? = nil) {
        self.cursorPosition = cursorPosition
        self.doubleClick = doubleClick
        self.holdKey = holdKey
        self.key = key
        self.leftClick = leftClick
        self.leftClickDrag = leftClickDrag
        self.leftMouseDown = leftMouseDown
        self.leftMouseUp = leftMouseUp
        self.middleClick = middleClick
        self.mouseMove = mouseMove
        self.rightClick = rightClick
        self.screenshot = screenshot
        self.scroll = scroll
        self.tripleClick = tripleClick
        self.type = type
        self.wait = wait
        self.zoom = zoom
    }

    enum CodingKeys: String, CodingKey {
        case cursorPosition = "cursor_position"
        case doubleClick = "double_click"
        case holdKey = "hold_key"
        case key
        case leftClick = "left_click"
        case leftClickDrag = "left_click_drag"
        case leftMouseDown = "left_mouse_down"
        case leftMouseUp = "left_mouse_up"
        case middleClick = "middle_click"
        case mouseMove = "mouse_move"
        case rightClick = "right_click"
        case screenshot
        case scroll
        case tripleClick = "triple_click"
        case type
        case wait
        case zoom
    }
}
