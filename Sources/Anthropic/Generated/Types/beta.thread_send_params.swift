// Transformed from `anthropic.types.beta.thread_send_params` (thread_send_params.py).

import Foundation

/// The `create()` fields that a thread's `send()`, `parse()` and `stream()` override for one turn, and `update()`
/// for all later turns.
public struct ThreadSendParams: Codable, Hashable, Sendable {
    /// The maximum number of tokens to generate before stopping.
    ///
    /// Note that our models may stop _before_ reaching this maximum. This parameter
    /// only specifies the absolute maximum number of tokens to generate.
    ///
    /// Set to `0` to populate the
    /// [prompt cache](https://platform.claude.com/docs/en/build-with-claude/prompt-caching#pre-warming-the-cache)
    /// without generating a response.
    ///
    /// Different models have different maximum values for this parameter. See
    /// [models](https://platform.claude.com/docs/en/about-claude/models/overview) for
    /// details.
    public var maxTokens: Int?
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: ModelParam?
    /// Top-level cache control automatically applies a cache_control marker to the last
    /// cacheable block in the request.
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// Compaction configuration.
    ///
    /// When set on `POST /v1/messages`, the request is a compaction request: the
    /// conversation in `messages` is summarized and the response holds only the
    /// resulting `compaction` block (`stop_reason` `"compaction"`), which later
    /// requests send first in `messages` in place of the messages it summarizes.
    /// `POST /v1/messages/count_tokens` accepts this parameter and ignores it: the
    /// count it returns is for the conversation in `messages` as sent. Cannot be
    /// combined with `context_management`.
    public var compaction: BetaCompactionConfigParam??
    /// Container identifier for reuse across requests.
    public var container: BetaMessageCreateParamsBase.Container??
    /// Context management configuration.
    ///
    /// This allows you to control how Claude manages context across multiple requests,
    /// such as whether to clear function results or not.
    public var contextManagement: BetaContextManagementConfigParam??
    /// Request-level diagnostics.
    ///
    /// Supply `previous_message_id` to have the response include
    /// `diagnostics.cache_miss_reason` explaining any prompt-cache divergence from that
    /// prior request.
    public var diagnostics: BetaDiagnosticsParam??
    /// The `fallback_credit_token` from a prior refusal's `stop_details`.
    ///
    /// When a preceding request was refused and returned a `fallback_credit_token`,
    /// pass that code here on the retry to have the retry's cache-creation tokens for
    /// the prefix that was warm on the refused model billed at the cache-read rate.
    /// Must be redeemed by the same organization and workspace, with the same request
    /// body (optionally extended by one appended `assistant` message whose content is
    /// the partial text — with any trailing whitespace stripped from the final text
    /// block — and paired server-tool blocks streamed before the refusal; the
    /// appended-assistant form is not available for requests with `output_format` set
    /// or forced `tool_choice`), on an eligible fallback model, on the same platform,
    /// and within 5 minutes of the refusal; a mismatch is a 400. A token minted
    /// mid-server-tool-loop whose partial content was continuable may only be redeemed
    /// with the appended-assistant form — if an exact-body retry is rejected with a 400
    /// saying the token must be redeemed by continuing the partial response, retry with
    /// the appended-assistant form instead.
    ///
    /// When the appended-assistant form is used on a model that otherwise disallows
    /// assistant-turn prefill, this token also authorizes that one prefill.
    public var fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken??
    /// Opt-in server-side retry on one or more substitute models when the requested
    /// model declines for policy reasons. Tried in order: if the first entry also
    /// declines, the second is tried, and so on. Some models don't support fallbacks;
    /// on those models, a list of fallback models returns a 400 error. See
    /// [Server-side fallback](https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback#server-side-fallback).
    /// The string "default" requests the requested model's server-defined default
    /// fallback configuration. On a model that doesn't support fallbacks, the request
    /// runs on the requested model alone, so a declined request stays declined.
    public var fallbacks: BetaFallbacksParam??
    /// Specifies the geographic region for inference processing.
    ///
    /// If not specified, the workspace's `default_inference_geo` is used.
    public var inferenceGeo: String??
    /// MCP servers to be utilized in this request
    public var mcpServers: [BetaRequestMCPServerURLDefinitionParam]?
    /// An object describing metadata about the request.
    public var metadata: BetaMetadataParam?
    /// Determines whether to use priority capacity (if available) or standard capacity
    /// for this request.
    ///
    /// Anthropic offers different levels of service for your API requests. See
    /// [service-tiers](https://platform.claude.com/docs/en/api/service-tiers) for
    /// details.
    public var serviceTier: ServiceTier?
    /// The inference speed mode for this request.
    ///
    /// `"fast"` enables high output-tokens-per-second inference.
    ///
    /// Some models require the `fast-mode-2026-02-01` beta header for any `speed`
    /// value. See
    /// [fast mode](https://platform.claude.com/docs/en/build-with-claude/fast-mode) for
    /// which models.
    public var speed: Speed??
    /// Custom text sequences that will cause the model to stop generating.
    ///
    /// Our models will normally stop when they have naturally completed their turn,
    /// which will result in a response `stop_reason` of `"end_turn"`.
    ///
    /// If you want the model to stop generating when it encounters custom strings of
    /// text, you can use the `stop_sequences` parameter. If the model encounters one of
    /// the custom sequences, the response `stop_reason` value will be `"stop_sequence"`
    /// and the response `stop_sequence` value will contain the matched stop sequence.
    public var stopSequences: [String]?
    /// System prompt.
    ///
    /// A system prompt is a way of providing context and instructions to Claude, such
    /// as specifying a particular goal or role. See our
    /// [guide to system prompts](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role).
    public var system: System?
    /// Configuration for Claude's thinking.
    ///
    /// With `{"type": "adaptive"}`, Claude decides when and how much to think. With
    /// `{"type": "enabled"}` (manual extended thinking), you set a `budget_tokens` of
    /// at least 1,024. Thinking tokens count toward your `max_tokens` limit.
    ///
    /// Which `type` values are accepted, and what happens when you omit `thinking`,
    /// depend on the model. See
    /// [thinking](https://platform.claude.com/docs/en/build-with-claude/thinking#configuring-thinking)
    /// for each model's behavior.
    public var thinking: BetaThinkingConfigParam?
    /// How the model should use the provided tools.
    ///
    /// The model can use a specific tool, any available tool, decide by itself, or not
    /// use tools at all.
    public var toolChoice: BetaToolChoiceParam?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// The user profile ID to attribute this request to.
    ///
    /// Use when acting on behalf of a party other than your organization.
    public var userProfileID: String?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(maxTokens: Int? = nil, model: ModelParam? = nil, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, serviceTier: ServiceTier? = nil, speed: Speed?? = nil, stopSequences: [String]? = nil, system: System? = nil, thinking: BetaThinkingConfigParam? = nil, toolChoice: BetaToolChoiceParam? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil) {
        self.maxTokens = maxTokens
        self.model = model
        self.cacheControl = cacheControl
        self.compaction = compaction
        self.container = container
        self.contextManagement = contextManagement
        self.diagnostics = diagnostics
        self.fallbackCreditToken = fallbackCreditToken
        self.fallbacks = fallbacks
        self.inferenceGeo = inferenceGeo
        self.mcpServers = mcpServers
        self.metadata = metadata
        self.serviceTier = serviceTier
        self.speed = speed
        self.stopSequences = stopSequences
        self.system = system
        self.thinking = thinking
        self.toolChoice = toolChoice
        self.betas = betas
        self.userProfileID = userProfileID
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case maxTokens = "max_tokens"
        case model
        case cacheControl = "cache_control"
        case compaction
        case container
        case contextManagement = "context_management"
        case diagnostics
        case fallbackCreditToken = "fallback_credit_token"
        case fallbacks
        case inferenceGeo = "inference_geo"
        case mcpServers = "mcp_servers"
        case metadata
        case serviceTier = "service_tier"
        case speed
        case stopSequences = "stop_sequences"
        case system
        case thinking
        case toolChoice = "tool_choice"
        case betas
        case userProfileID = "user_profile_id"
        case workspaceID = "workspace_id"
    }

    public enum ServiceTier: OpenEnum, CaseIterable {
        case auto
        case standardOnly
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ServiceTier] = [.auto, .standardOnly]

        public init(rawValue: String) {
            switch rawValue {
            case "auto": self = .auto
            case "standard_only": self = .standardOnly
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .auto: return "auto"
            case .standardOnly: return "standard_only"
            case .unknown(let value): return value
            }
        }
    }

    public enum Speed: OpenEnum, CaseIterable {
        case standard
        case fast
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Speed] = [.standard, .fast]

        public init(rawValue: String) {
            switch rawValue {
            case "standard": self = .standard
            case "fast": self = .fast
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .standard: return "standard"
            case .fast: return "fast"
            case .unknown(let value): return value
            }
        }
    }

    public indirect enum System: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case betaTextBlockParams([BetaTextBlockParam])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: BetaTextBlockParam...) { self = .betaTextBlockParams(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [BetaTextBlockParam](from: decoder) { self = .betaTextBlockParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaTextBlockParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
