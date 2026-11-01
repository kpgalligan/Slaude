// Transformed from `anthropic.types.beta.beta_dream` (beta_dream.py).

import Foundation

/// An asynchronous job that reads a memory store and past sessions, then writes a reorganized version of that memory store.
///
/// By default the dream writes its result to a new memory store and doesn't change the input memory store. With `output_behavior` set to `update_existing`, it writes its result into the input memory store instead.
///
/// The Dreams API is in research preview: the request and response shapes are volatile and may change without the deprecation period that applies to generally-available endpoints.
///
/// See the [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#how-it-works) for what a dream reads and produces.
public struct BetaDream: Codable, Hashable, Sendable {
    /// The unique ID of the dream (`drm_...`).
    public var id: String
    /// When the dream was archived, in RFC 3339, or `null` if it hasn't been archived.
    public var archivedAt: Date?
    /// When the dream was created, in RFC 3339.
    ///
    /// Lists of dreams are sorted by this time, newest first.
    public var createdAt: Date
    /// When the dream reached `completed`, `failed`, or `canceled`, in RFC 3339, or
    /// `null` if it is still `pending` or `running`.
    public var endedAt: Date?
    /// Why the dream failed, or `null` if `status` isn't `failed`.
    public var error: BetaDreamError?
    /// The sources that the dream reads, from the request that created it.
    public var inputs: [BetaDreamInput]
    /// The guidance given when the dream was created, or `null` if none was given.
    public var instructions: String?
    /// The model that runs a dream, from the request that created it.
    ///
    /// The dream uses this model for all of its work. The response always gives the
    /// model as an object, even if the request gave only a model ID.
    public var model: BetaDreamModelConfig
    /// Where the dream writes its result, as set in the request that created the dream.
    ///
    /// If that request left out `output_behavior`, the dream used the `create_new`
    /// behavior.
    public var outputBehavior: BetaOutputBehavior
    /// The memory store that holds the dream's result, as a one-item array, or an empty
    /// array until the dream records that memory store.
    ///
    /// The array is empty while the dream is `pending` and for a short time after it
    /// starts `running`. It can stay empty if the dream fails or is canceled before
    /// then. The memory store holds the complete result only once `status` is
    /// `completed`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#use-the-output)
    /// for how to review and use the result.
    public var outputs: [BetaDreamOutput]
    /// The ID of the session that runs the dream (`sesn_...`), or `null` if that
    /// session hasn't started.
    ///
    /// Stream that session's events to follow what the dream reads and writes.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#watch-the-pipeline-run)
    /// for how to watch a running dream.
    public var sessionId: String?
    /// Where a dream is in its lifecycle.
    ///
    /// `completed`, `failed`, and `canceled` are final: once a dream has one of these
    /// statuses, its status doesn't change again.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#lifecycle)
    /// for what each status means.
    public var status: BetaDreamStatus
    public var type: String
    /// The dream's token counts, which stop changing once its `status` is `completed`
    /// or `failed`. After a cancel, they can keep changing.
    public var usage: BetaDreamUsage

    public init(id: String, archivedAt: Date? = nil, createdAt: Date, endedAt: Date? = nil, error: BetaDreamError? = nil, inputs: [BetaDreamInput], instructions: String? = nil, model: BetaDreamModelConfig, outputBehavior: BetaOutputBehavior, outputs: [BetaDreamOutput], sessionId: String? = nil, status: BetaDreamStatus, type: String = "dream", usage: BetaDreamUsage) {
        self.id = id
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.endedAt = endedAt
        self.error = error
        self.inputs = inputs
        self.instructions = instructions
        self.model = model
        self.outputBehavior = outputBehavior
        self.outputs = outputs
        self.sessionId = sessionId
        self.status = status
        self.type = type
        self.usage = usage
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case endedAt = "ended_at"
        case error
        case inputs
        case instructions
        case model
        case outputBehavior = "output_behavior"
        case outputs
        case sessionId = "session_id"
        case status
        case type
        case usage
    }
}
