// Transformed from `anthropic.types.browser_zoom_tool_use_block` (browser_zoom_tool_use_block.py).

import Foundation

public struct BrowserZoomToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Return a cropped screenshot of the given viewport region, scaled up for closer
    /// inspection — useful for small icons, buttons, or text. Coordinates are in the
    /// same viewport-pixel space as a full screenshot.
    public var input: BrowserZoomInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserZoomInput, name: String = "zoom", toolsetName: String = "browser", type: String = "tool_use") {
        self.id = id
        self.caller = caller
        self.input = input
        self.name = name
        self.toolsetName = toolsetName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case caller
        case input
        case name
        case toolsetName = "toolset_name"
        case type
    }
}
