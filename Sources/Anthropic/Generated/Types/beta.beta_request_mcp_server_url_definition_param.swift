// Transformed from `anthropic.types.beta.beta_request_mcp_server_url_definition_param` (beta_request_mcp_server_url_definition_param.py).

import Foundation

public struct BetaRequestMCPServerURLDefinitionParam: Codable, Hashable, Sendable {
    public var name: String
    public var type: String
    public var url: String
    public var authorizationToken: String??
    public var toolConfiguration: BetaRequestMCPServerToolConfigurationParam??

    public init(name: String, type: String = "url", url: String, authorizationToken: String?? = nil, toolConfiguration: BetaRequestMCPServerToolConfigurationParam?? = nil) {
        self.name = name
        self.type = type
        self.url = url
        self.authorizationToken = authorizationToken
        self.toolConfiguration = toolConfiguration
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case url
        case authorizationToken = "authorization_token"
        case toolConfiguration = "tool_configuration"
    }
}
