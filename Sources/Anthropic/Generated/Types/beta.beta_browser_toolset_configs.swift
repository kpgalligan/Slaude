// Transformed from `anthropic.types.beta.beta_browser_toolset_configs` (beta_browser_toolset_configs.py).

import Foundation

/// Per-member configuration for ``browser_toolset_20260801``: one
/// optional field per member tool, keyed by the member name — the same
/// name the member's ``tool_use`` blocks carry. Every member is an
/// accepted key, and a member's defaults apply wherever its key is
/// absent. Unknown keys are rejected: the field set is this toolset
/// version's complete member set.
public struct BetaBrowserToolsetConfigs: Codable, Hashable, Sendable {
    /// `close_tab`'s config overrides.
    public var closeTab: BetaBrowserCloseTabConfig?
    /// `double_click`'s config overrides.
    public var doubleClick: BetaBrowserDoubleClickConfig?
    /// `file_upload`'s config overrides.
    public var fileUpload: BetaBrowserFileUploadConfig?
    /// `find`'s config overrides.
    public var find: BetaBrowserFindConfig?
    /// `form_input`'s config overrides.
    public var formInput: BetaBrowserFormInputConfig?
    /// `get_page_text`'s config overrides.
    public var getPageText: BetaBrowserGetPageTextConfig?
    /// `hold_key`'s config overrides.
    public var holdKey: BetaBrowserHoldKeyConfig?
    /// `hover`'s config overrides.
    public var hover: BetaBrowserHoverConfig?
    /// `javascript_exec`'s config overrides.
    public var javascriptExec: BetaBrowserJavascriptExecConfig?
    /// `key`'s config overrides.
    public var key: BetaBrowserKeyConfig?
    /// `left_click`'s config overrides.
    public var leftClick: BetaBrowserLeftClickConfig?
    /// `left_click_drag`'s config overrides.
    public var leftClickDrag: BetaBrowserLeftClickDragConfig?
    /// `left_mouse_down`'s config overrides.
    public var leftMouseDown: BetaBrowserLeftMouseDownConfig?
    /// `left_mouse_up`'s config overrides.
    public var leftMouseUp: BetaBrowserLeftMouseUpConfig?
    /// `list_tabs`'s config overrides.
    public var listTabs: BetaBrowserListTabsConfig?
    /// `middle_click`'s config overrides.
    public var middleClick: BetaBrowserMiddleClickConfig?
    /// `mouse_move`'s config overrides.
    public var mouseMove: BetaBrowserMouseMoveConfig?
    /// `navigate`'s config overrides.
    public var navigate: BetaBrowserNavigateConfig?
    /// `new_tab`'s config overrides.
    public var newTab: BetaBrowserNewTabConfig?
    /// `read_console`'s config overrides.
    public var readConsole: BetaBrowserReadConsoleConfig?
    /// `read_network`'s config overrides.
    public var readNetwork: BetaBrowserReadNetworkConfig?
    /// `read_page`'s config overrides.
    public var readPage: BetaBrowserReadPageConfig?
    /// `right_click`'s config overrides.
    public var rightClick: BetaBrowserRightClickConfig?
    /// `screenshot`'s config overrides.
    public var screenshot: BetaBrowserScreenshotConfig?
    /// `scroll`'s config overrides.
    public var scroll: BetaBrowserScrollConfig?
    /// `scroll_to`'s config overrides.
    public var scrollTo: BetaBrowserScrollToConfig?
    /// `switch_tab`'s config overrides.
    public var switchTab: BetaBrowserSwitchTabConfig?
    /// `triple_click`'s config overrides.
    public var tripleClick: BetaBrowserTripleClickConfig?
    /// `type`'s config overrides.
    public var type: BetaBrowserTypeConfig?
    /// `wait`'s config overrides.
    public var wait: BetaBrowserWaitConfig?
    /// `zoom`'s config overrides.
    public var zoom: BetaBrowserZoomConfig?

    public init(closeTab: BetaBrowserCloseTabConfig? = nil, doubleClick: BetaBrowserDoubleClickConfig? = nil, fileUpload: BetaBrowserFileUploadConfig? = nil, find: BetaBrowserFindConfig? = nil, formInput: BetaBrowserFormInputConfig? = nil, getPageText: BetaBrowserGetPageTextConfig? = nil, holdKey: BetaBrowserHoldKeyConfig? = nil, hover: BetaBrowserHoverConfig? = nil, javascriptExec: BetaBrowserJavascriptExecConfig? = nil, key: BetaBrowserKeyConfig? = nil, leftClick: BetaBrowserLeftClickConfig? = nil, leftClickDrag: BetaBrowserLeftClickDragConfig? = nil, leftMouseDown: BetaBrowserLeftMouseDownConfig? = nil, leftMouseUp: BetaBrowserLeftMouseUpConfig? = nil, listTabs: BetaBrowserListTabsConfig? = nil, middleClick: BetaBrowserMiddleClickConfig? = nil, mouseMove: BetaBrowserMouseMoveConfig? = nil, navigate: BetaBrowserNavigateConfig? = nil, newTab: BetaBrowserNewTabConfig? = nil, readConsole: BetaBrowserReadConsoleConfig? = nil, readNetwork: BetaBrowserReadNetworkConfig? = nil, readPage: BetaBrowserReadPageConfig? = nil, rightClick: BetaBrowserRightClickConfig? = nil, screenshot: BetaBrowserScreenshotConfig? = nil, scroll: BetaBrowserScrollConfig? = nil, scrollTo: BetaBrowserScrollToConfig? = nil, switchTab: BetaBrowserSwitchTabConfig? = nil, tripleClick: BetaBrowserTripleClickConfig? = nil, type: BetaBrowserTypeConfig? = nil, wait: BetaBrowserWaitConfig? = nil, zoom: BetaBrowserZoomConfig? = nil) {
        self.closeTab = closeTab
        self.doubleClick = doubleClick
        self.fileUpload = fileUpload
        self.find = find
        self.formInput = formInput
        self.getPageText = getPageText
        self.holdKey = holdKey
        self.hover = hover
        self.javascriptExec = javascriptExec
        self.key = key
        self.leftClick = leftClick
        self.leftClickDrag = leftClickDrag
        self.leftMouseDown = leftMouseDown
        self.leftMouseUp = leftMouseUp
        self.listTabs = listTabs
        self.middleClick = middleClick
        self.mouseMove = mouseMove
        self.navigate = navigate
        self.newTab = newTab
        self.readConsole = readConsole
        self.readNetwork = readNetwork
        self.readPage = readPage
        self.rightClick = rightClick
        self.screenshot = screenshot
        self.scroll = scroll
        self.scrollTo = scrollTo
        self.switchTab = switchTab
        self.tripleClick = tripleClick
        self.type = type
        self.wait = wait
        self.zoom = zoom
    }

    enum CodingKeys: String, CodingKey {
        case closeTab = "close_tab"
        case doubleClick = "double_click"
        case fileUpload = "file_upload"
        case find
        case formInput = "form_input"
        case getPageText = "get_page_text"
        case holdKey = "hold_key"
        case hover
        case javascriptExec = "javascript_exec"
        case key
        case leftClick = "left_click"
        case leftClickDrag = "left_click_drag"
        case leftMouseDown = "left_mouse_down"
        case leftMouseUp = "left_mouse_up"
        case listTabs = "list_tabs"
        case middleClick = "middle_click"
        case mouseMove = "mouse_move"
        case navigate
        case newTab = "new_tab"
        case readConsole = "read_console"
        case readNetwork = "read_network"
        case readPage = "read_page"
        case rightClick = "right_click"
        case screenshot
        case scroll
        case scrollTo = "scroll_to"
        case switchTab = "switch_tab"
        case tripleClick = "triple_click"
        case type
        case wait
        case zoom
    }
}
