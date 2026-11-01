// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_tool_result_event_params` (beta_managed_agents_user_tool_result_event_params.py).

import Foundation

/// Parameters for providing the result of an agent-toolset tool execution.
///
/// Only valid on `self_hosted` environments, where sandbox-routed tools are executed by the client rather than the server.
public struct BetaManagedAgentsUserToolResultEventParams: Codable, Hashable, Sendable {
    /// The id of the `agent.tool_use` event this result corresponds to, which can be
    /// found in the last `session.status_idle`
    /// [event's](https://platform.claude.com/docs/en/api/beta/sessions/events/list#beta_managed_agents_session_requires_action.event_ids)
    /// `stop_reason.event_ids` field.
    public var toolUseId: String
    public var type: String
    /// The result content returned by the tool.
    public var content: [BetaManagedAgentsUserToolResultEventParams.Content]?
    /// Whether the tool execution resulted in an error.
    public var isError: Bool??

    public init(toolUseId: String, type: String = "user.tool_result", content: [BetaManagedAgentsUserToolResultEventParams.Content]? = nil, isError: Bool?? = nil) {
        self.toolUseId = toolUseId
        self.type = type
        self.content = content
        self.isError = isError
    }

    enum CodingKeys: String, CodingKey {
        case toolUseId = "tool_use_id"
        case type
        case content
        case isError = "is_error"
    }
}

extension BetaManagedAgentsUserToolResultEventParams {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(BetaManagedAgentsTextBlockParam)
        case image(BetaManagedAgentsImageBlockParam)
        case document(BetaManagedAgentsDocumentBlockParam)
        case searchResult(BetaManagedAgentsSearchResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaManagedAgentsTextBlockParam(from: decoder))
            case "image": self = .image(try BetaManagedAgentsImageBlockParam(from: decoder))
            case "document": self = .document(try BetaManagedAgentsDocumentBlockParam(from: decoder))
            case "search_result": self = .searchResult(try BetaManagedAgentsSearchResultBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let v): try v.encode(to: encoder)
            case .image(let v): try v.encode(to: encoder)
            case .document(let v): try v.encode(to: encoder)
            case .searchResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
