// Transformed from `anthropic.types.computer_toolset_configs_param` (computer_toolset_configs_param.py).

import Foundation

/// Per-member configuration for ``computer_toolset_20260801``: one
/// optional field per member tool, keyed by the member name — the same
/// name the member's ``tool_use`` blocks carry. Every member is an
/// accepted key, and a member's defaults apply wherever its key is
/// absent. Unknown keys are rejected: the field set is this toolset
/// version's complete member set.
public struct ComputerToolsetConfigsParam: Codable, Hashable, Sendable {
    /// `cursor_position`'s config overrides.
    public var cursorPosition: ComputerCursorPositionConfigParam??
    /// `double_click`'s config overrides.
    public var doubleClick: ComputerDoubleClickConfigParam??
    /// `hold_key`'s config overrides.
    public var holdKey: ComputerHoldKeyConfigParam??
    /// `key`'s config overrides.
    public var key: ComputerKeyConfigParam??
    /// `left_click`'s config overrides.
    public var leftClick: ComputerLeftClickConfigParam??
    /// `left_click_drag`'s config overrides.
    public var leftClickDrag: ComputerLeftClickDragConfigParam??
    /// `left_mouse_down`'s config overrides.
    public var leftMouseDown: ComputerLeftMouseDownConfigParam??
    /// `left_mouse_up`'s config overrides.
    public var leftMouseUp: ComputerLeftMouseUpConfigParam??
    /// `middle_click`'s config overrides.
    public var middleClick: ComputerMiddleClickConfigParam??
    /// `mouse_move`'s config overrides.
    public var mouseMove: ComputerMouseMoveConfigParam??
    /// `right_click`'s config overrides.
    public var rightClick: ComputerRightClickConfigParam??
    /// `screenshot`'s config overrides.
    public var screenshot: ComputerScreenshotConfigParam??
    /// `scroll`'s config overrides.
    public var scroll: ComputerScrollConfigParam??
    /// `triple_click`'s config overrides.
    public var tripleClick: ComputerTripleClickConfigParam??
    /// `type`'s config overrides.
    public var type: ComputerTypeConfigParam??
    /// `wait`'s config overrides.
    public var wait: ComputerWaitConfigParam??
    /// `zoom`'s config overrides.
    public var zoom: ComputerZoomConfigParam??

    public init(cursorPosition: ComputerCursorPositionConfigParam?? = nil, doubleClick: ComputerDoubleClickConfigParam?? = nil, holdKey: ComputerHoldKeyConfigParam?? = nil, key: ComputerKeyConfigParam?? = nil, leftClick: ComputerLeftClickConfigParam?? = nil, leftClickDrag: ComputerLeftClickDragConfigParam?? = nil, leftMouseDown: ComputerLeftMouseDownConfigParam?? = nil, leftMouseUp: ComputerLeftMouseUpConfigParam?? = nil, middleClick: ComputerMiddleClickConfigParam?? = nil, mouseMove: ComputerMouseMoveConfigParam?? = nil, rightClick: ComputerRightClickConfigParam?? = nil, screenshot: ComputerScreenshotConfigParam?? = nil, scroll: ComputerScrollConfigParam?? = nil, tripleClick: ComputerTripleClickConfigParam?? = nil, type: ComputerTypeConfigParam?? = nil, wait: ComputerWaitConfigParam?? = nil, zoom: ComputerZoomConfigParam?? = nil) {
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
