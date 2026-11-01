// Transformed from `anthropic._client` (the AsyncAnthropic resource accessors).

import Foundation

extension Anthropic {
    public var messages: MessagesResource { MessagesResource(client: self) }
    public var models: ModelsResource { ModelsResource(client: self) }
    public var files: FilesResource { FilesResource(client: self) }
    public var skills: SkillsResource { SkillsResource(client: self) }
    public var userProfiles: UserProfilesResource { UserProfilesResource(client: self) }
    public var organization: OrganizationResource { OrganizationResource(client: self) }
    public var beta: BetaResource { BetaResource(client: self) }

    public var withRawResponse: WithRawResponse { WithRawResponse(client: self) }
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(client: self) }

    public struct WithRawResponse: Sendable {
        let client: Anthropic
        public var messages: MessagesResource.WithRawResponse { MessagesResource(client: client).withRawResponse }
        public var models: ModelsResource.WithRawResponse { ModelsResource(client: client).withRawResponse }
        public var files: FilesResource.WithRawResponse { FilesResource(client: client).withRawResponse }
        public var skills: SkillsResource.WithRawResponse { SkillsResource(client: client).withRawResponse }
        public var userProfiles: UserProfilesResource.WithRawResponse { UserProfilesResource(client: client).withRawResponse }
        public var organization: OrganizationResource.WithRawResponse { OrganizationResource(client: client).withRawResponse }
        public var beta: BetaResource.WithRawResponse { BetaResource(client: client).withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let client: Anthropic
        public var messages: MessagesResource.WithStreamingResponse { MessagesResource(client: client).withStreamingResponse }
        public var models: ModelsResource.WithStreamingResponse { ModelsResource(client: client).withStreamingResponse }
        public var files: FilesResource.WithStreamingResponse { FilesResource(client: client).withStreamingResponse }
        public var skills: SkillsResource.WithStreamingResponse { SkillsResource(client: client).withStreamingResponse }
        public var userProfiles: UserProfilesResource.WithStreamingResponse { UserProfilesResource(client: client).withStreamingResponse }
        public var organization: OrganizationResource.WithStreamingResponse { OrganizationResource(client: client).withStreamingResponse }
        public var beta: BetaResource.WithStreamingResponse { BetaResource(client: client).withStreamingResponse }
    }
}
