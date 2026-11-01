// Transformed from `anthropic.types.beta.beta_request_mcp_server_tool_configuration_param` (beta_request_mcp_server_tool_configuration_param.py).

import Foundation

public struct BetaRequestMCPServerToolConfigurationParam: Codable, Hashable, Sendable {
    public var allowedTools: [String]??
    public var enabled: Bool??

    public init(allowedTools: [String]?? = nil, enabled: Bool?? = nil) {
        self.allowedTools = allowedTools
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case allowedTools = "allowed_tools"
        case enabled
    }
}
