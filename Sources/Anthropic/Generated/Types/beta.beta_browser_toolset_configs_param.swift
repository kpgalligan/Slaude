// Transformed from `anthropic.types.beta.beta_browser_toolset_configs_param` (beta_browser_toolset_configs_param.py).

import Foundation

/// Per-member configuration for ``browser_toolset_20260801``: one
/// optional field per member tool, keyed by the member name — the same
/// name the member's ``tool_use`` blocks carry. Every member is an
/// accepted key, and a member's defaults apply wherever its key is
/// absent. Unknown keys are rejected: the field set is this toolset
/// version's complete member set.
public struct BetaBrowserToolsetConfigsParam: Codable, Hashable, Sendable {
    /// `close_tab`'s config overrides.
    public var closeTab: BetaBrowserCloseTabConfigParam??
    /// `double_click`'s config overrides.
    public var doubleClick: BetaBrowserDoubleClickConfigParam??
    /// `file_upload`'s config overrides.
    public var fileUpload: BetaBrowserFileUploadConfigParam??
    /// `find`'s config overrides.
    public var find: BetaBrowserFindConfigParam??
    /// `form_input`'s config overrides.
    public var formInput: BetaBrowserFormInputConfigParam??
    /// `get_page_text`'s config overrides.
    public var getPageText: BetaBrowserGetPageTextConfigParam??
    /// `hold_key`'s config overrides.
    public var holdKey: BetaBrowserHoldKeyConfigParam??
    /// `hover`'s config overrides.
    public var hover: BetaBrowserHoverConfigParam??
    /// `javascript_exec`'s config overrides.
    public var javascriptExec: BetaBrowserJavascriptExecConfigParam??
    /// `key`'s config overrides.
    public var key: BetaBrowserKeyConfigParam??
    /// `left_click`'s config overrides.
    public var leftClick: BetaBrowserLeftClickConfigParam??
    /// `left_click_drag`'s config overrides.
    public var leftClickDrag: BetaBrowserLeftClickDragConfigParam??
    /// `left_mouse_down`'s config overrides.
    public var leftMouseDown: BetaBrowserLeftMouseDownConfigParam??
    /// `left_mouse_up`'s config overrides.
    public var leftMouseUp: BetaBrowserLeftMouseUpConfigParam??
    /// `list_tabs`'s config overrides.
    public var listTabs: BetaBrowserListTabsConfigParam??
    /// `middle_click`'s config overrides.
    public var middleClick: BetaBrowserMiddleClickConfigParam??
    /// `mouse_move`'s config overrides.
    public var mouseMove: BetaBrowserMouseMoveConfigParam??
    /// `navigate`'s config overrides.
    public var navigate: BetaBrowserNavigateConfigParam??
    /// `new_tab`'s config overrides.
    public var newTab: BetaBrowserNewTabConfigParam??
    /// `read_console`'s config overrides.
    public var readConsole: BetaBrowserReadConsoleConfigParam??
    /// `read_network`'s config overrides.
    public var readNetwork: BetaBrowserReadNetworkConfigParam??
    /// `read_page`'s config overrides.
    public var readPage: BetaBrowserReadPageConfigParam??
    /// `right_click`'s config overrides.
    public var rightClick: BetaBrowserRightClickConfigParam??
    /// `screenshot`'s config overrides.
    public var screenshot: BetaBrowserScreenshotConfigParam??
    /// `scroll`'s config overrides.
    public var scroll: BetaBrowserScrollConfigParam??
    /// `scroll_to`'s config overrides.
    public var scrollTo: BetaBrowserScrollToConfigParam??
    /// `switch_tab`'s config overrides.
    public var switchTab: BetaBrowserSwitchTabConfigParam??
    /// `triple_click`'s config overrides.
    public var tripleClick: BetaBrowserTripleClickConfigParam??
    /// `type`'s config overrides.
    public var type: BetaBrowserTypeConfigParam??
    /// `wait`'s config overrides.
    public var wait: BetaBrowserWaitConfigParam??
    /// `zoom`'s config overrides.
    public var zoom: BetaBrowserZoomConfigParam??

    public init(closeTab: BetaBrowserCloseTabConfigParam?? = nil, doubleClick: BetaBrowserDoubleClickConfigParam?? = nil, fileUpload: BetaBrowserFileUploadConfigParam?? = nil, find: BetaBrowserFindConfigParam?? = nil, formInput: BetaBrowserFormInputConfigParam?? = nil, getPageText: BetaBrowserGetPageTextConfigParam?? = nil, holdKey: BetaBrowserHoldKeyConfigParam?? = nil, hover: BetaBrowserHoverConfigParam?? = nil, javascriptExec: BetaBrowserJavascriptExecConfigParam?? = nil, key: BetaBrowserKeyConfigParam?? = nil, leftClick: BetaBrowserLeftClickConfigParam?? = nil, leftClickDrag: BetaBrowserLeftClickDragConfigParam?? = nil, leftMouseDown: BetaBrowserLeftMouseDownConfigParam?? = nil, leftMouseUp: BetaBrowserLeftMouseUpConfigParam?? = nil, listTabs: BetaBrowserListTabsConfigParam?? = nil, middleClick: BetaBrowserMiddleClickConfigParam?? = nil, mouseMove: BetaBrowserMouseMoveConfigParam?? = nil, navigate: BetaBrowserNavigateConfigParam?? = nil, newTab: BetaBrowserNewTabConfigParam?? = nil, readConsole: BetaBrowserReadConsoleConfigParam?? = nil, readNetwork: BetaBrowserReadNetworkConfigParam?? = nil, readPage: BetaBrowserReadPageConfigParam?? = nil, rightClick: BetaBrowserRightClickConfigParam?? = nil, screenshot: BetaBrowserScreenshotConfigParam?? = nil, scroll: BetaBrowserScrollConfigParam?? = nil, scrollTo: BetaBrowserScrollToConfigParam?? = nil, switchTab: BetaBrowserSwitchTabConfigParam?? = nil, tripleClick: BetaBrowserTripleClickConfigParam?? = nil, type: BetaBrowserTypeConfigParam?? = nil, wait: BetaBrowserWaitConfigParam?? = nil, zoom: BetaBrowserZoomConfigParam?? = nil) {
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
