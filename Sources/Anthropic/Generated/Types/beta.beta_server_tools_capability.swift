// Transformed from `anthropic.types.beta.beta_server_tools_capability` (beta_server_tools_capability.py).

import Foundation

/// Web search and code execution tool support, with one entry per tool.
public struct BetaServerToolsCapability: Codable, Hashable, Sendable {
    /// Whether the model supports the code execution tool: true when the model supports
    /// at least one version of the tool, not necessarily every version.
    public var codeExecution: BetaCapabilitySupport
    /// Whether this capability is supported by the model.
    public var supported: Bool
    /// Whether the model supports the web search tool: true when the model supports at
    /// least one version of the tool, not necessarily every version.
    public var webSearch: BetaCapabilitySupport

    public init(codeExecution: BetaCapabilitySupport, supported: Bool, webSearch: BetaCapabilitySupport) {
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
