// Transformed from `anthropic.types.messages.batch_create_params` (batch_create_params.py).

import Foundation

public struct BatchCreateParams: Codable, Hashable, Sendable {
    /// List of requests for prompt completion.
    ///
    /// Each is an individual request to create a Message.
    public var requests: [BatchCreateParams.Request]
    /// The user profile ID to attribute the requests in this batch to.
    ///
    /// Use when acting on behalf of a party other than your organization. Applies to
    /// every request in the batch; an individual request whose `user_profile_id` body
    /// field conflicts with this header is errored.
    public var userProfileId: String?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(requests: [BatchCreateParams.Request], userProfileId: String? = nil, workspaceId: String? = nil) {
        self.requests = requests
        self.userProfileId = userProfileId
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case requests
        case userProfileId = "user_profile_id"
        case workspaceId = "workspace_id"
    }
}

extension BatchCreateParams {

    public struct Request: Codable, Hashable, Sendable {
        /// Developer-provided ID created for each request in a Message Batch.
        ///
        /// Useful for matching results to requests, as results may be given out of request
        /// order.
        ///
        /// Must be unique for each request within the Message Batch.
        public var customId: String
        /// Messages API creation parameters for the individual request.
        ///
        /// See the
        /// [Messages API reference](https://platform.claude.com/docs/en/api/messages) for
        /// full documentation on available parameters.
        public var params: MessageCreateParamsBase.MessageCreateParamsNonStreaming

        public init(customId: String, params: MessageCreateParamsBase.MessageCreateParamsNonStreaming) {
            self.customId = customId
            self.params = params
        }

        enum CodingKeys: String, CodingKey {
            case customId = "custom_id"
            case params
        }
    }
}
