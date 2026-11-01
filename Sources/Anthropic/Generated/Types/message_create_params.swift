// Transformed from `anthropic.types.message_create_params` (message_create_params.py).

import Foundation

public struct MessageCreateParamsBase: Codable, Hashable, Sendable {
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
    public var maxTokens: Int
    /// Input messages.
    ///
    /// Our models are trained to operate on alternating `user` and `assistant`
    /// conversational turns. When creating a new `Message`, you specify the prior
    /// conversational turns with the `messages` parameter, and the model then generates
    /// the next `Message` in the conversation. Consecutive `user` or `assistant` turns
    /// in your request will be combined into a single turn.
    ///
    /// Each input message must be an object with a `role` and `content`. You can
    /// specify a single `user`-role message, or you can include multiple `user` and
    /// `assistant` messages.
    ///
    /// If the final message uses the `assistant` role, the response content will
    /// continue immediately from the content in that message. This can be used to
    /// constrain part of the model's response. This is called prefill. On models that
    /// don't support prefill, creating a message that ends with a partial `assistant`
    /// response returns a 400 error. See
    /// [Prefill not supported](https://platform.claude.com/docs/en/api/errors#prefill-not-supported).
    ///
    /// Example with a single `user` message:
    ///
    /// ```json
    /// [{ "role": "user", "content": "Hello, Claude" }]
    /// ```
    ///
    /// Example with multiple conversational turns:
    ///
    /// ```json
    /// [
    ///   { "role": "user", "content": "Hello there." },
    ///   { "role": "assistant", "content": "Hi, I'm Claude. How can I help you?" },
    ///   { "role": "user", "content": "Can you explain LLMs in plain English?" }
    /// ]
    /// ```
    ///
    /// Example with a partially-filled response from Claude, for models that support
    /// prefill:
    ///
    /// ```json
    /// [
    ///   {
    ///     "role": "user",
    ///     "content": "What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun"
    ///   },
    ///   { "role": "assistant", "content": "The best answer is (" }
    /// ]
    /// ```
    ///
    /// Each input message `content` may be either a single `string` or an array of
    /// content blocks, where each block has a specific `type`. Using a `string` for
    /// `content` is shorthand for an array of one content block of type `"text"`. The
    /// following input messages are equivalent:
    ///
    /// ```json
    /// { "role": "user", "content": "Hello, Claude" }
    /// ```
    ///
    /// ```json
    /// { "role": "user", "content": [{ "type": "text", "text": "Hello, Claude" }] }
    /// ```
    ///
    /// See
    /// [input examples](https://platform.claude.com/docs/en/build-with-claude/working-with-messages).
    ///
    /// Note that if you want to include a
    /// [system prompt](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role),
    /// you can use the top-level `system` parameter.
    ///
    /// There is a limit of 100,000 messages in a single request.
    public var messages: [MessageParam]
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: ModelParam
    /// Top-level cache control automatically applies a cache_control marker to the last
    /// cacheable block in the request.
    public var cacheControl: CacheControlEphemeralParam??
    /// Container identifier for reuse across requests.
    public var container: MessageCreateParamsContainerParam??
    /// Request-level diagnostics.
    ///
    /// Supply `previous_message_id` to have the response include
    /// `diagnostics.cache_miss_reason` explaining any prompt-cache divergence from that
    /// prior request.
    public var diagnostics: DiagnosticsParam??
    /// Specifies the geographic region for inference processing.
    ///
    /// If not specified, the workspace's `default_inference_geo` is used.
    public var inferenceGeo: String??
    /// An object describing metadata about the request.
    public var metadata: MetadataParam?
    /// Configuration options for the model's output, such as the output format.
    public var outputConfig: OutputConfigParam?
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
    public var thinking: ThinkingConfigParam?
    /// How the model should use the provided tools.
    ///
    /// The model can use a specific tool, any available tool, decide by itself, or not
    /// use tools at all.
    public var toolChoice: ToolChoiceParam?
    /// Definitions of tools that the model may use.
    ///
    /// If you include `tools` in your API request, the model may return `tool_use`
    /// content blocks that represent the model's use of those tools. You can then run
    /// those tools using the tool input generated by the model and then optionally
    /// return results back to the model using `tool_result` content blocks.
    ///
    /// There are two types of tools: **client tools** and **server tools**. The
    /// behavior described below applies to client tools. For
    /// [server tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools),
    /// see their individual documentation as each has its own behavior (e.g., the
    /// [web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool)).
    ///
    /// Each tool definition includes:
    ///
    /// - `name`: Name of the tool.
    /// - `description`: Optional, but strongly-recommended description of the tool.
    /// - `input_schema`: [JSON schema](https://json-schema.org/draft/2020-12) for the
    ///   tool `input` shape that the model will produce in `tool_use` output content
    ///   blocks.
    ///
    /// For example, if you defined `tools` as:
    ///
    /// ```json
    /// [
    ///   {
    ///     "name": "get_stock_price",
    ///     "description": "Get the current stock price for a given ticker symbol.",
    ///     "input_schema": {
    ///       "type": "object",
    ///       "properties": {
    ///         "ticker": {
    ///           "type": "string",
    ///           "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
    ///         }
    ///       },
    ///       "required": ["ticker"]
    ///     }
    ///   }
    /// ]
    /// ```
    ///
    /// And then asked the model "What's the S&P 500 at today?", the model might produce
    /// `tool_use` content blocks in the response like this:
    ///
    /// ```json
    /// [
    ///   {
    ///     "type": "tool_use",
    ///     "id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///     "name": "get_stock_price",
    ///     "input": { "ticker": "^GSPC" }
    ///   }
    /// ]
    /// ```
    ///
    /// You might then run your `get_stock_price` tool with `{"ticker": "^GSPC"}` as an
    /// input, and return the following back to the model in a subsequent `user`
    /// message:
    ///
    /// ```json
    /// [
    ///   {
    ///     "type": "tool_result",
    ///     "tool_use_id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///     "content": "259.75 USD"
    ///   }
    /// ]
    /// ```
    ///
    /// Tools can be used for workflows that include running client-side tools and
    /// functions, or more generally whenever you want the model to produce a particular
    /// JSON structure of output.
    ///
    /// See our
    /// [guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
    /// for more details.
    public var tools: [ToolUnionParam]?
    /// The user profile ID to attribute this request to.
    ///
    /// Use when acting on behalf of a party other than your organization.
    public var userProfileId: String?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(maxTokens: Int, messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam?? = nil, container: MessageCreateParamsContainerParam?? = nil, diagnostics: DiagnosticsParam?? = nil, inferenceGeo: String?? = nil, metadata: MetadataParam? = nil, outputConfig: OutputConfigParam? = nil, serviceTier: ServiceTier? = nil, speed: Speed?? = nil, stopSequences: [String]? = nil, system: System? = nil, thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil, userProfileId: String? = nil, workspaceId: String? = nil) {
        self.maxTokens = maxTokens
        self.messages = messages
        self.model = model
        self.cacheControl = cacheControl
        self.container = container
        self.diagnostics = diagnostics
        self.inferenceGeo = inferenceGeo
        self.metadata = metadata
        self.outputConfig = outputConfig
        self.serviceTier = serviceTier
        self.speed = speed
        self.stopSequences = stopSequences
        self.system = system
        self.thinking = thinking
        self.toolChoice = toolChoice
        self.tools = tools
        self.userProfileId = userProfileId
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case maxTokens = "max_tokens"
        case messages
        case model
        case cacheControl = "cache_control"
        case container
        case diagnostics
        case inferenceGeo = "inference_geo"
        case metadata
        case outputConfig = "output_config"
        case serviceTier = "service_tier"
        case speed
        case stopSequences = "stop_sequences"
        case system
        case thinking
        case toolChoice = "tool_choice"
        case tools
        case userProfileId = "user_profile_id"
        case workspaceId = "workspace_id"
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
        case textBlockParams([TextBlockParam])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: TextBlockParam...) { self = .textBlockParams(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [TextBlockParam](from: decoder) { self = .textBlockParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .textBlockParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}

extension MessageCreateParamsBase {

    /// This is deprecated, `MetadataParam` should be used instead
    public typealias Metadata = MetadataParam

    /// This is deprecated, `ToolChoiceParam` should be used instead
    public typealias ToolChoice = ToolChoiceParam

    /// This is deprecated, `ToolChoiceAutoParam` should be used instead
    public typealias ToolChoiceToolChoiceAuto = ToolChoiceAutoParam

    /// This is deprecated, `ToolChoiceAnyParam` should be used instead
    public typealias ToolChoiceToolChoiceAny = ToolChoiceAnyParam

    /// This is deprecated, `ToolChoiceToolParam` should be used instead
    public typealias ToolChoiceToolChoiceTool = ToolChoiceToolParam

    public struct MessageCreateParamsNonStreaming: Codable, Hashable, Sendable {
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
        public var maxTokens: Int
        /// Input messages.
        ///
        /// Our models are trained to operate on alternating `user` and `assistant`
        /// conversational turns. When creating a new `Message`, you specify the prior
        /// conversational turns with the `messages` parameter, and the model then generates
        /// the next `Message` in the conversation. Consecutive `user` or `assistant` turns
        /// in your request will be combined into a single turn.
        ///
        /// Each input message must be an object with a `role` and `content`. You can
        /// specify a single `user`-role message, or you can include multiple `user` and
        /// `assistant` messages.
        ///
        /// If the final message uses the `assistant` role, the response content will
        /// continue immediately from the content in that message. This can be used to
        /// constrain part of the model's response. This is called prefill. On models that
        /// don't support prefill, creating a message that ends with a partial `assistant`
        /// response returns a 400 error. See
        /// [Prefill not supported](https://platform.claude.com/docs/en/api/errors#prefill-not-supported).
        ///
        /// Example with a single `user` message:
        ///
        /// ```json
        /// [{ "role": "user", "content": "Hello, Claude" }]
        /// ```
        ///
        /// Example with multiple conversational turns:
        ///
        /// ```json
        /// [
        ///   { "role": "user", "content": "Hello there." },
        ///   { "role": "assistant", "content": "Hi, I'm Claude. How can I help you?" },
        ///   { "role": "user", "content": "Can you explain LLMs in plain English?" }
        /// ]
        /// ```
        ///
        /// Example with a partially-filled response from Claude, for models that support
        /// prefill:
        ///
        /// ```json
        /// [
        ///   {
        ///     "role": "user",
        ///     "content": "What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun"
        ///   },
        ///   { "role": "assistant", "content": "The best answer is (" }
        /// ]
        /// ```
        ///
        /// Each input message `content` may be either a single `string` or an array of
        /// content blocks, where each block has a specific `type`. Using a `string` for
        /// `content` is shorthand for an array of one content block of type `"text"`. The
        /// following input messages are equivalent:
        ///
        /// ```json
        /// { "role": "user", "content": "Hello, Claude" }
        /// ```
        ///
        /// ```json
        /// { "role": "user", "content": [{ "type": "text", "text": "Hello, Claude" }] }
        /// ```
        ///
        /// See
        /// [input examples](https://platform.claude.com/docs/en/build-with-claude/working-with-messages).
        ///
        /// Note that if you want to include a
        /// [system prompt](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role),
        /// you can use the top-level `system` parameter.
        ///
        /// There is a limit of 100,000 messages in a single request.
        public var messages: [MessageParam]
        /// The model that will complete your prompt.
        ///
        /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
        /// details and options.
        public var model: ModelParam
        /// Top-level cache control automatically applies a cache_control marker to the last
        /// cacheable block in the request.
        public var cacheControl: CacheControlEphemeralParam??
        /// Container identifier for reuse across requests.
        public var container: MessageCreateParamsContainerParam??
        /// Request-level diagnostics.
        ///
        /// Supply `previous_message_id` to have the response include
        /// `diagnostics.cache_miss_reason` explaining any prompt-cache divergence from that
        /// prior request.
        public var diagnostics: DiagnosticsParam??
        /// Specifies the geographic region for inference processing.
        ///
        /// If not specified, the workspace's `default_inference_geo` is used.
        public var inferenceGeo: String??
        /// An object describing metadata about the request.
        public var metadata: MetadataParam?
        /// Configuration options for the model's output, such as the output format.
        public var outputConfig: OutputConfigParam?
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
        public var thinking: ThinkingConfigParam?
        /// How the model should use the provided tools.
        ///
        /// The model can use a specific tool, any available tool, decide by itself, or not
        /// use tools at all.
        public var toolChoice: ToolChoiceParam?
        /// Definitions of tools that the model may use.
        ///
        /// If you include `tools` in your API request, the model may return `tool_use`
        /// content blocks that represent the model's use of those tools. You can then run
        /// those tools using the tool input generated by the model and then optionally
        /// return results back to the model using `tool_result` content blocks.
        ///
        /// There are two types of tools: **client tools** and **server tools**. The
        /// behavior described below applies to client tools. For
        /// [server tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools),
        /// see their individual documentation as each has its own behavior (e.g., the
        /// [web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool)).
        ///
        /// Each tool definition includes:
        ///
        /// - `name`: Name of the tool.
        /// - `description`: Optional, but strongly-recommended description of the tool.
        /// - `input_schema`: [JSON schema](https://json-schema.org/draft/2020-12) for the
        ///   tool `input` shape that the model will produce in `tool_use` output content
        ///   blocks.
        ///
        /// For example, if you defined `tools` as:
        ///
        /// ```json
        /// [
        ///   {
        ///     "name": "get_stock_price",
        ///     "description": "Get the current stock price for a given ticker symbol.",
        ///     "input_schema": {
        ///       "type": "object",
        ///       "properties": {
        ///         "ticker": {
        ///           "type": "string",
        ///           "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
        ///         }
        ///       },
        ///       "required": ["ticker"]
        ///     }
        ///   }
        /// ]
        /// ```
        ///
        /// And then asked the model "What's the S&P 500 at today?", the model might produce
        /// `tool_use` content blocks in the response like this:
        ///
        /// ```json
        /// [
        ///   {
        ///     "type": "tool_use",
        ///     "id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
        ///     "name": "get_stock_price",
        ///     "input": { "ticker": "^GSPC" }
        ///   }
        /// ]
        /// ```
        ///
        /// You might then run your `get_stock_price` tool with `{"ticker": "^GSPC"}` as an
        /// input, and return the following back to the model in a subsequent `user`
        /// message:
        ///
        /// ```json
        /// [
        ///   {
        ///     "type": "tool_result",
        ///     "tool_use_id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
        ///     "content": "259.75 USD"
        ///   }
        /// ]
        /// ```
        ///
        /// Tools can be used for workflows that include running client-side tools and
        /// functions, or more generally whenever you want the model to produce a particular
        /// JSON structure of output.
        ///
        /// See our
        /// [guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
        /// for more details.
        public var tools: [ToolUnionParam]?
        /// The user profile ID to attribute this request to.
        ///
        /// Use when acting on behalf of a party other than your organization.
        public var userProfileId: String?
        /// Optional header to select the Workspace for this request.
        ///
        /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
        ///
        /// Only needed for credentials that can act on more than one Workspace. A
        /// credential that belongs to a specific Workspace may omit it; if sent, it must
        /// match that Workspace.
        public var workspaceId: String?
        /// Whether to incrementally stream the response using server-sent events.
        ///
        /// When `true`, SDKs return a raw event stream.
        ///
        /// In the TypeScript, Python and Ruby SDKs, the recommended way to stream is
        /// `messages.stream()`. It sets `stream` for you and accumulates the events into
        /// the final message. See
        /// [Streaming with SDKs](https://platform.claude.com/docs/en/build-with-claude/streaming#streaming-with-sdks)
        /// for an example in each language.
        public var stream: Bool?

        public init(maxTokens: Int, messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam?? = nil, container: MessageCreateParamsContainerParam?? = nil, diagnostics: DiagnosticsParam?? = nil, inferenceGeo: String?? = nil, metadata: MetadataParam? = nil, outputConfig: OutputConfigParam? = nil, serviceTier: ServiceTier? = nil, speed: Speed?? = nil, stopSequences: [String]? = nil, system: System? = nil, thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil, userProfileId: String? = nil, workspaceId: String? = nil, stream: Bool? = nil) {
            self.maxTokens = maxTokens
            self.messages = messages
            self.model = model
            self.cacheControl = cacheControl
            self.container = container
            self.diagnostics = diagnostics
            self.inferenceGeo = inferenceGeo
            self.metadata = metadata
            self.outputConfig = outputConfig
            self.serviceTier = serviceTier
            self.speed = speed
            self.stopSequences = stopSequences
            self.system = system
            self.thinking = thinking
            self.toolChoice = toolChoice
            self.tools = tools
            self.userProfileId = userProfileId
            self.workspaceId = workspaceId
            self.stream = stream
        }

        enum CodingKeys: String, CodingKey {
            case maxTokens = "max_tokens"
            case messages
            case model
            case cacheControl = "cache_control"
            case container
            case diagnostics
            case inferenceGeo = "inference_geo"
            case metadata
            case outputConfig = "output_config"
            case serviceTier = "service_tier"
            case speed
            case stopSequences = "stop_sequences"
            case system
            case thinking
            case toolChoice = "tool_choice"
            case tools
            case userProfileId = "user_profile_id"
            case workspaceId = "workspace_id"
            case stream
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
            case textBlockParams([TextBlockParam])
            /// A value that matched none of the known variants.
            case unknown(JSONValue)

            public init(stringLiteral value: String) { self = .string(value) }

            public init(arrayLiteral elements: TextBlockParam...) { self = .textBlockParams(elements) }

            public init(from decoder: Decoder) throws {
                if let v = try? String(from: decoder) { self = .string(v); return }
                if let v = try? [TextBlockParam](from: decoder) { self = .textBlockParams(v); return }
                self = .unknown(try _Coding.raw(decoder))
            }

            public func encode(to encoder: Encoder) throws {
                switch self {
                case .string(let v): try v.encode(to: encoder)
                case .textBlockParams(let v): try v.encode(to: encoder)
                case .unknown(let v): try v.encode(to: encoder)
                }
            }
        }
    }

    public struct MessageCreateParamsStreaming: Codable, Hashable, Sendable {
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
        public var maxTokens: Int
        /// Input messages.
        ///
        /// Our models are trained to operate on alternating `user` and `assistant`
        /// conversational turns. When creating a new `Message`, you specify the prior
        /// conversational turns with the `messages` parameter, and the model then generates
        /// the next `Message` in the conversation. Consecutive `user` or `assistant` turns
        /// in your request will be combined into a single turn.
        ///
        /// Each input message must be an object with a `role` and `content`. You can
        /// specify a single `user`-role message, or you can include multiple `user` and
        /// `assistant` messages.
        ///
        /// If the final message uses the `assistant` role, the response content will
        /// continue immediately from the content in that message. This can be used to
        /// constrain part of the model's response. This is called prefill. On models that
        /// don't support prefill, creating a message that ends with a partial `assistant`
        /// response returns a 400 error. See
        /// [Prefill not supported](https://platform.claude.com/docs/en/api/errors#prefill-not-supported).
        ///
        /// Example with a single `user` message:
        ///
        /// ```json
        /// [{ "role": "user", "content": "Hello, Claude" }]
        /// ```
        ///
        /// Example with multiple conversational turns:
        ///
        /// ```json
        /// [
        ///   { "role": "user", "content": "Hello there." },
        ///   { "role": "assistant", "content": "Hi, I'm Claude. How can I help you?" },
        ///   { "role": "user", "content": "Can you explain LLMs in plain English?" }
        /// ]
        /// ```
        ///
        /// Example with a partially-filled response from Claude, for models that support
        /// prefill:
        ///
        /// ```json
        /// [
        ///   {
        ///     "role": "user",
        ///     "content": "What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun"
        ///   },
        ///   { "role": "assistant", "content": "The best answer is (" }
        /// ]
        /// ```
        ///
        /// Each input message `content` may be either a single `string` or an array of
        /// content blocks, where each block has a specific `type`. Using a `string` for
        /// `content` is shorthand for an array of one content block of type `"text"`. The
        /// following input messages are equivalent:
        ///
        /// ```json
        /// { "role": "user", "content": "Hello, Claude" }
        /// ```
        ///
        /// ```json
        /// { "role": "user", "content": [{ "type": "text", "text": "Hello, Claude" }] }
        /// ```
        ///
        /// See
        /// [input examples](https://platform.claude.com/docs/en/build-with-claude/working-with-messages).
        ///
        /// Note that if you want to include a
        /// [system prompt](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role),
        /// you can use the top-level `system` parameter.
        ///
        /// There is a limit of 100,000 messages in a single request.
        public var messages: [MessageParam]
        /// The model that will complete your prompt.
        ///
        /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
        /// details and options.
        public var model: ModelParam
        /// Top-level cache control automatically applies a cache_control marker to the last
        /// cacheable block in the request.
        public var cacheControl: CacheControlEphemeralParam??
        /// Container identifier for reuse across requests.
        public var container: MessageCreateParamsContainerParam??
        /// Request-level diagnostics.
        ///
        /// Supply `previous_message_id` to have the response include
        /// `diagnostics.cache_miss_reason` explaining any prompt-cache divergence from that
        /// prior request.
        public var diagnostics: DiagnosticsParam??
        /// Specifies the geographic region for inference processing.
        ///
        /// If not specified, the workspace's `default_inference_geo` is used.
        public var inferenceGeo: String??
        /// An object describing metadata about the request.
        public var metadata: MetadataParam?
        /// Configuration options for the model's output, such as the output format.
        public var outputConfig: OutputConfigParam?
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
        public var thinking: ThinkingConfigParam?
        /// How the model should use the provided tools.
        ///
        /// The model can use a specific tool, any available tool, decide by itself, or not
        /// use tools at all.
        public var toolChoice: ToolChoiceParam?
        /// Definitions of tools that the model may use.
        ///
        /// If you include `tools` in your API request, the model may return `tool_use`
        /// content blocks that represent the model's use of those tools. You can then run
        /// those tools using the tool input generated by the model and then optionally
        /// return results back to the model using `tool_result` content blocks.
        ///
        /// There are two types of tools: **client tools** and **server tools**. The
        /// behavior described below applies to client tools. For
        /// [server tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools),
        /// see their individual documentation as each has its own behavior (e.g., the
        /// [web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool)).
        ///
        /// Each tool definition includes:
        ///
        /// - `name`: Name of the tool.
        /// - `description`: Optional, but strongly-recommended description of the tool.
        /// - `input_schema`: [JSON schema](https://json-schema.org/draft/2020-12) for the
        ///   tool `input` shape that the model will produce in `tool_use` output content
        ///   blocks.
        ///
        /// For example, if you defined `tools` as:
        ///
        /// ```json
        /// [
        ///   {
        ///     "name": "get_stock_price",
        ///     "description": "Get the current stock price for a given ticker symbol.",
        ///     "input_schema": {
        ///       "type": "object",
        ///       "properties": {
        ///         "ticker": {
        ///           "type": "string",
        ///           "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
        ///         }
        ///       },
        ///       "required": ["ticker"]
        ///     }
        ///   }
        /// ]
        /// ```
        ///
        /// And then asked the model "What's the S&P 500 at today?", the model might produce
        /// `tool_use` content blocks in the response like this:
        ///
        /// ```json
        /// [
        ///   {
        ///     "type": "tool_use",
        ///     "id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
        ///     "name": "get_stock_price",
        ///     "input": { "ticker": "^GSPC" }
        ///   }
        /// ]
        /// ```
        ///
        /// You might then run your `get_stock_price` tool with `{"ticker": "^GSPC"}` as an
        /// input, and return the following back to the model in a subsequent `user`
        /// message:
        ///
        /// ```json
        /// [
        ///   {
        ///     "type": "tool_result",
        ///     "tool_use_id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
        ///     "content": "259.75 USD"
        ///   }
        /// ]
        /// ```
        ///
        /// Tools can be used for workflows that include running client-side tools and
        /// functions, or more generally whenever you want the model to produce a particular
        /// JSON structure of output.
        ///
        /// See our
        /// [guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
        /// for more details.
        public var tools: [ToolUnionParam]?
        /// The user profile ID to attribute this request to.
        ///
        /// Use when acting on behalf of a party other than your organization.
        public var userProfileId: String?
        /// Optional header to select the Workspace for this request.
        ///
        /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
        ///
        /// Only needed for credentials that can act on more than one Workspace. A
        /// credential that belongs to a specific Workspace may omit it; if sent, it must
        /// match that Workspace.
        public var workspaceId: String?
        /// Whether to incrementally stream the response using server-sent events.
        ///
        /// When `true`, SDKs return a raw event stream.
        ///
        /// In the TypeScript, Python and Ruby SDKs, the recommended way to stream is
        /// `messages.stream()`. It sets `stream` for you and accumulates the events into
        /// the final message. See
        /// [Streaming with SDKs](https://platform.claude.com/docs/en/build-with-claude/streaming#streaming-with-sdks)
        /// for an example in each language.
        public var stream: Bool

        public init(maxTokens: Int, messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam?? = nil, container: MessageCreateParamsContainerParam?? = nil, diagnostics: DiagnosticsParam?? = nil, inferenceGeo: String?? = nil, metadata: MetadataParam? = nil, outputConfig: OutputConfigParam? = nil, serviceTier: ServiceTier? = nil, speed: Speed?? = nil, stopSequences: [String]? = nil, system: System? = nil, thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil, userProfileId: String? = nil, workspaceId: String? = nil, stream: Bool = true) {
            self.maxTokens = maxTokens
            self.messages = messages
            self.model = model
            self.cacheControl = cacheControl
            self.container = container
            self.diagnostics = diagnostics
            self.inferenceGeo = inferenceGeo
            self.metadata = metadata
            self.outputConfig = outputConfig
            self.serviceTier = serviceTier
            self.speed = speed
            self.stopSequences = stopSequences
            self.system = system
            self.thinking = thinking
            self.toolChoice = toolChoice
            self.tools = tools
            self.userProfileId = userProfileId
            self.workspaceId = workspaceId
            self.stream = stream
        }

        enum CodingKeys: String, CodingKey {
            case maxTokens = "max_tokens"
            case messages
            case model
            case cacheControl = "cache_control"
            case container
            case diagnostics
            case inferenceGeo = "inference_geo"
            case metadata
            case outputConfig = "output_config"
            case serviceTier = "service_tier"
            case speed
            case stopSequences = "stop_sequences"
            case system
            case thinking
            case toolChoice = "tool_choice"
            case tools
            case userProfileId = "user_profile_id"
            case workspaceId = "workspace_id"
            case stream
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
            case textBlockParams([TextBlockParam])
            /// A value that matched none of the known variants.
            case unknown(JSONValue)

            public init(stringLiteral value: String) { self = .string(value) }

            public init(arrayLiteral elements: TextBlockParam...) { self = .textBlockParams(elements) }

            public init(from decoder: Decoder) throws {
                if let v = try? String(from: decoder) { self = .string(v); return }
                if let v = try? [TextBlockParam](from: decoder) { self = .textBlockParams(v); return }
                self = .unknown(try _Coding.raw(decoder))
            }

            public func encode(to encoder: Encoder) throws {
                switch self {
                case .string(let v): try v.encode(to: encoder)
                case .textBlockParams(let v): try v.encode(to: encoder)
                case .unknown(let v): try v.encode(to: encoder)
                }
            }
        }
    }

    public indirect enum MessageCreateParams: Codable, Hashable, Sendable {
        case messageCreateParamsNonStreaming(MessageCreateParamsBase.MessageCreateParamsNonStreaming)
        case messageCreateParamsStreaming(MessageCreateParamsBase.MessageCreateParamsStreaming)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if let v = try? MessageCreateParamsBase.MessageCreateParamsNonStreaming(from: decoder) { self = .messageCreateParamsNonStreaming(v); return }
            if let v = try? MessageCreateParamsBase.MessageCreateParamsStreaming(from: decoder) { self = .messageCreateParamsStreaming(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .messageCreateParamsNonStreaming(let v): try v.encode(to: encoder)
            case .messageCreateParamsStreaming(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
