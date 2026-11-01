// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_custom_tool_result_event_params` (beta_managed_agents_user_custom_tool_result_event_params.py).

import Foundation

/// Parameters for providing the result of a custom tool execution.
public struct BetaManagedAgentsUserCustomToolResultEventParams: Codable, Hashable, Sendable {
    /// The id of the `agent.custom_tool_use` event this result corresponds to.
    ///
    /// It is also listed in the last `session.status_idle`
    /// [event's](https://platform.claude.com/docs/en/api/beta/sessions/events/list#beta_managed_agents_session_requires_action.event_ids)
    /// `stop_reason.event_ids` field.
    public var customToolUseID: String
    public var type: String
    /// The result content returned by the tool.
    public var content: [BetaManagedAgentsUserCustomToolResultEventParams.Content]?
    /// Whether the tool execution resulted in an error.
    public var isError: Bool??

    public init(customToolUseID: String, type: String = "user.custom_tool_result", content: [BetaManagedAgentsUserCustomToolResultEventParams.Content]? = nil, isError: Bool?? = nil) {
        self.customToolUseID = customToolUseID
        self.type = type
        self.content = content
        self.isError = isError
    }

    enum CodingKeys: String, CodingKey {
        case customToolUseID = "custom_tool_use_id"
        case type
        case content
        case isError = "is_error"
    }
}

extension BetaManagedAgentsUserCustomToolResultEventParams {

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
