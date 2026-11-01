// Transformed from `anthropic.types.server_tools_capability` (server_tools_capability.py).

import Foundation

/// Web search and code execution tool support, with one entry per tool.
public struct ServerToolsCapability: Codable, Hashable, Sendable {
    /// Whether the model supports the code execution tool: true when the model supports
    /// at least one version of the tool, not necessarily every version.
    public var codeExecution: CapabilitySupport
    /// Whether this capability is supported by the model.
    public var supported: Bool
    /// Whether the model supports the web search tool: true when the model supports at
    /// least one version of the tool, not necessarily every version.
    public var webSearch: CapabilitySupport

    public init(codeExecution: CapabilitySupport, supported: Bool, webSearch: CapabilitySupport) {
        self.codeExecution = codeExecution
        self.supported = supported
        self.webSearch = webSearch
    }

    enum CodingKeys: String, CodingKey {
        case codeExecution = "code_execution"
        case supported
        case webSearch = "web_search"
    }
}
