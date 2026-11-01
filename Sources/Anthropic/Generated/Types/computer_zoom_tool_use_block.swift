// Transformed from `anthropic.types.computer_zoom_tool_use_block` (computer_zoom_tool_use_block.py).

import Foundation

public struct ComputerZoomToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Take a screenshot of a rectangular region.
    ///
    /// Region coordinates are in the full-screenshot space (not physical display
    /// pixels). The crop is scaled up to fill the image budget so fine details become
    /// legible.
    public var input: ComputerZoomInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerZoomInput, name: String = "zoom", toolsetName: String = "computer", type: String = "tool_use") {
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
