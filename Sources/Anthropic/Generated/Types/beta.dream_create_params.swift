// Transformed from `anthropic.types.beta.dream_create_params` (dream_create_params.py).

import Foundation

public struct DreamCreateParams: Codable, Hashable, Sendable {
    /// The memory store and sessions for the dream to read, as exactly one
    /// `memory_store` entry and exactly one `sessions` entry.
    public var inputs: [BetaDreamInputParam]
    /// The model that runs a dream, given as a model ID or as an object with `id` and
    /// `speed`.
    ///
    /// In the object form, `speed` can only be `standard`.
    ///
    /// The
    /// [limits table in the Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#limits)
    /// lists the supported models.
    public var model: DreamCreateParams.Model
    /// Guidance that steers how the dream reads the sessions and organizes the output
    /// memory store, from 1 to 4,096 characters.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#steer-with-instructions)
    /// for what kinds of instructions work well.
    public var instructions: String??
    /// Which memory store a dream writes its result to.
    ///
    /// Defaults to `create_new` when left out of a create request.
    public var outputBehavior: BetaOutputBehaviorParam?
    /// This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(inputs: [BetaDreamInputParam], model: DreamCreateParams.Model, instructions: String?? = nil, outputBehavior: BetaOutputBehaviorParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.inputs = inputs
        self.model = model
        self.instructions = instructions
        self.outputBehavior = outputBehavior
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case inputs
        case model
        case instructions
        case outputBehavior = "output_behavior"
        case betas
        case workspaceId = "workspace_id"
    }
}

extension DreamCreateParams {

    public indirect enum Model: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case betaDreamModelConfigParam(BetaDreamModelConfigParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? BetaDreamModelConfigParam(from: decoder) { self = .betaDreamModelConfigParam(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaDreamModelConfigParam(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
