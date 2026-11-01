// Transformed from `anthropic.types.browser_toolset_configs_param` (browser_toolset_configs_param.py).

import Foundation

/// Per-member configuration for ``browser_toolset_20260801``: one
/// optional field per member tool, keyed by the member name — the same
/// name the member's ``tool_use`` blocks carry. Every member is an
/// accepted key, and a member's defaults apply wherever its key is
/// absent. Unknown keys are rejected: the field set is this toolset
/// version's complete member set.
public struct BrowserToolsetConfigsParam: Codable, Hashable, Sendable {
    /// `close_tab`'s config overrides.
    public var closeTab: BrowserCloseTabConfigParam??
    /// `double_click`'s config overrides.
    public var doubleClick: BrowserDoubleClickConfigParam??
    /// `file_upload`'s config overrides.
    public var fileUpload: BrowserFileUploadConfigParam??
    /// `find`'s config overrides.
    public var find: BrowserFindConfigParam??
    /// `form_input`'s config overrides.
    public var formInput: BrowserFormInputConfigParam??
    /// `get_page_text`'s config overrides.
    public var getPageText: BrowserGetPageTextConfigParam??
    /// `hold_key`'s config overrides.
    public var holdKey: BrowserHoldKeyConfigParam??
    /// `hover`'s config overrides.
    public var hover: BrowserHoverConfigParam??
    /// `javascript_exec`'s config overrides.
    public var javascriptExec: BrowserJavascriptExecConfigParam??
    /// `key`'s config overrides.
    public var key: BrowserKeyConfigParam??
    /// `left_click`'s config overrides.
    public var leftClick: BrowserLeftClickConfigParam??
    /// `left_click_drag`'s config overrides.
    public var leftClickDrag: BrowserLeftClickDragConfigParam??
    /// `left_mouse_down`'s config overrides.
    public var leftMouseDown: BrowserLeftMouseDownConfigParam??
    /// `left_mouse_up`'s config overrides.
    public var leftMouseUp: BrowserLeftMouseUpConfigParam??
    /// `list_tabs`'s config overrides.
    public var listTabs: BrowserListTabsConfigParam??
    /// `middle_click`'s config overrides.
    public var middleClick: BrowserMiddleClickConfigParam??
    /// `mouse_move`'s config overrides.
    public var mouseMove: BrowserMouseMoveConfigParam??
    /// `navigate`'s config overrides.
    public var navigate: BrowserNavigateConfigParam??
    /// `new_tab`'s config overrides.
    public var newTab: BrowserNewTabConfigParam??
    /// `read_console`'s config overrides.
    public var readConsole: BrowserReadConsoleConfigParam??
    /// `read_network`'s config overrides.
    public var readNetwork: BrowserReadNetworkConfigParam??
    /// `read_page`'s config overrides.
    public var readPage: BrowserReadPageConfigParam??
    /// `right_click`'s config overrides.
    public var rightClick: BrowserRightClickConfigParam??
    /// `screenshot`'s config overrides.
    public var screenshot: BrowserScreenshotConfigParam??
    /// `scroll`'s config overrides.
    public var scroll: BrowserScrollConfigParam??
    /// `scroll_to`'s config overrides.
    public var scrollTo: BrowserScrollToConfigParam??
    /// `switch_tab`'s config overrides.
    public var switchTab: BrowserSwitchTabConfigParam??
    /// `triple_click`'s config overrides.
    public var tripleClick: BrowserTripleClickConfigParam??
    /// `type`'s config overrides.
    public var type: BrowserTypeConfigParam??
    /// `wait`'s config overrides.
    public var wait: BrowserWaitConfigParam??
    /// `zoom`'s config overrides.
    public var zoom: BrowserZoomConfigParam??

    public init(closeTab: BrowserCloseTabConfigParam?? = nil, doubleClick: BrowserDoubleClickConfigParam?? = nil, fileUpload: BrowserFileUploadConfigParam?? = nil, find: BrowserFindConfigParam?? = nil, formInput: BrowserFormInputConfigParam?? = nil, getPageText: BrowserGetPageTextConfigParam?? = nil, holdKey: BrowserHoldKeyConfigParam?? = nil, hover: BrowserHoverConfigParam?? = nil, javascriptExec: BrowserJavascriptExecConfigParam?? = nil, key: BrowserKeyConfigParam?? = nil, leftClick: BrowserLeftClickConfigParam?? = nil, leftClickDrag: BrowserLeftClickDragConfigParam?? = nil, leftMouseDown: BrowserLeftMouseDownConfigParam?? = nil, leftMouseUp: BrowserLeftMouseUpConfigParam?? = nil, listTabs: BrowserListTabsConfigParam?? = nil, middleClick: BrowserMiddleClickConfigParam?? = nil, mouseMove: BrowserMouseMoveConfigParam?? = nil, navigate: BrowserNavigateConfigParam?? = nil, newTab: BrowserNewTabConfigParam?? = nil, readConsole: BrowserReadConsoleConfigParam?? = nil, readNetwork: BrowserReadNetworkConfigParam?? = nil, readPage: BrowserReadPageConfigParam?? = nil, rightClick: BrowserRightClickConfigParam?? = nil, screenshot: BrowserScreenshotConfigParam?? = nil, scroll: BrowserScrollConfigParam?? = nil, scrollTo: BrowserScrollToConfigParam?? = nil, switchTab: BrowserSwitchTabConfigParam?? = nil, tripleClick: BrowserTripleClickConfigParam?? = nil, type: BrowserTypeConfigParam?? = nil, wait: BrowserWaitConfigParam?? = nil, zoom: BrowserZoomConfigParam?? = nil) {
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
