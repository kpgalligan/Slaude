// Transformed from `anthropic.resources.beta.organization.claude_tag.claude_tag` (claude_tag.py).

import Foundation

public struct BetaOrganizationClaudeTagResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var slackChannels: BetaOrganizationClaudeTagSlackChannelsResource { BetaOrganizationClaudeTagSlackChannelsResource(client: client) }

    public var slackWorkspaces: BetaOrganizationClaudeTagSlackWorkspacesResource { BetaOrganizationClaudeTagSlackWorkspacesResource(client: client) }

    public var bundles: BetaOrganizationClaudeTagBundlesResource { BetaOrganizationClaudeTagBundlesResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationClaudeTagResource

        public var slackChannels: BetaOrganizationClaudeTagSlackChannelsResource.WithRawResponse { resource.slackChannels.withRawResponse }

        public var slackWorkspaces: BetaOrganizationClaudeTagSlackWorkspacesResource.WithRawResponse { resource.slackWorkspaces.withRawResponse }

        public var bundles: BetaOrganizationClaudeTagBundlesResource.WithRawResponse { resource.bundles.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationClaudeTagResource

        public var slackChannels: BetaOrganizationClaudeTagSlackChannelsResource.WithStreamingResponse { resource.slackChannels.withStreamingResponse }

        public var slackWorkspaces: BetaOrganizationClaudeTagSlackWorkspacesResource.WithStreamingResponse { resource.slackWorkspaces.withStreamingResponse }

        public var bundles: BetaOrganizationClaudeTagBundlesResource.WithStreamingResponse { resource.bundles.withStreamingResponse }
    }
}
