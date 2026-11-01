// Transformed from `anthropic.types.beta.beta_computer_toolset_configs` (beta_computer_toolset_configs.py).

import Foundation

/// Per-member configuration for ``computer_toolset_20260801``: one
/// optional field per member tool, keyed by the member name — the same
/// name the member's ``tool_use`` blocks carry. Every member is an
/// accepted key, and a member's defaults apply wherever its key is
/// absent. Unknown keys are rejected: the field set is this toolset
/// version's complete member set.
public struct BetaComputerToolsetConfigs: Codable, Hashable, Sendable {
    /// `cursor_position`'s config overrides.
    public var cursorPosition: BetaComputerCursorPositionConfig?
    /// `double_click`'s config overrides.
    public var doubleClick: BetaComputerDoubleClickConfig?
    /// `hold_key`'s config overrides.
    public var holdKey: BetaComputerHoldKeyConfig?
    /// `key`'s config overrides.
    public var key: BetaComputerKeyConfig?
    /// `left_click`'s config overrides.
    public var leftClick: BetaComputerLeftClickConfig?
    /// `left_click_drag`'s config overrides.
    public var leftClickDrag: BetaComputerLeftClickDragConfig?
    /// `left_mouse_down`'s config overrides.
    public var leftMouseDown: BetaComputerLeftMouseDownConfig?
    /// `left_mouse_up`'s config overrides.
    public var leftMouseUp: BetaComputerLeftMouseUpConfig?
    /// `middle_click`'s config overrides.
    public var middleClick: BetaComputerMiddleClickConfig?
    /// `mouse_move`'s config overrides.
    public var mouseMove: BetaComputerMouseMoveConfig?
    /// `right_click`'s config overrides.
    public var rightClick: BetaComputerRightClickConfig?
    /// `screenshot`'s config overrides.
    public var screenshot: BetaComputerScreenshotConfig?
    /// `scroll`'s config overrides.
    public var scroll: BetaComputerScrollConfig?
    /// `triple_click`'s config overrides.
    public var tripleClick: BetaComputerTripleClickConfig?
    /// `type`'s config overrides.
    public var type: BetaComputerTypeConfig?
    /// `wait`'s config overrides.
    public var wait: BetaComputerWaitConfig?
    /// `zoom`'s config overrides.
    public var zoom: BetaComputerZoomConfig?

    public init(cursorPosition: BetaComputerCursorPositionConfig? = nil, doubleClick: BetaComputerDoubleClickConfig? = nil, holdKey: BetaComputerHoldKeyConfig? = nil, key: BetaComputerKeyConfig? = nil, leftClick: BetaComputerLeftClickConfig? = nil, leftClickDrag: BetaComputerLeftClickDragConfig? = nil, leftMouseDown: BetaComputerLeftMouseDownConfig? = nil, leftMouseUp: BetaComputerLeftMouseUpConfig? = nil, middleClick: BetaComputerMiddleClickConfig? = nil, mouseMove: BetaComputerMouseMoveConfig? = nil, rightClick: BetaComputerRightClickConfig? = nil, screenshot: BetaComputerScreenshotConfig? = nil, scroll: BetaComputerScrollConfig? = nil, tripleClick: BetaComputerTripleClickConfig? = nil, type: BetaComputerTypeConfig? = nil, wait: BetaComputerWaitConfig? = nil, zoom: BetaComputerZoomConfig? = nil) {
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
