// Transformed from `anthropic.types.beta.message_count_tokens_params` (message_count_tokens_params.py).

import Foundation

public struct BetaMessageCountTokensParams: Codable, Hashable, Sendable {
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
    public var messages: [BetaMessageParam]
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: ModelParam
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
    /// Context management configuration.
    ///
    /// This allows you to control how Claude manages context across multiple requests,
    /// such as whether to clear function results or not.
    public var contextManagement: BetaContextManagementConfigParam??
    /// MCP servers to be utilized in this request
    public var mcpServers: [BetaRequestMCPServerURLDefinitionParam]?
    /// Configuration options for the model's output, such as the output format.
    public var outputConfig: BetaOutputConfigParam?
    /// The inference speed mode for this request.
    ///
    /// `"fast"` enables high output-tokens-per-second inference.
    ///
    /// Some models require the `fast-mode-2026-02-01` beta header for any `speed`
    /// value. See
    /// [fast mode](https://platform.claude.com/docs/en/build-with-claude/fast-mode) for
    /// which models.
    public var speed: Speed??
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
    public var tools: [BetaMessageCountTokensParams.Tool]?
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

    public init(messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, outputConfig: BetaOutputConfigParam? = nil, speed: Speed?? = nil, system: System? = nil, thinking: BetaThinkingConfigParam? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaMessageCountTokensParams.Tool]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil) {
        self.messages = messages
        self.model = model
        self.cacheControl = cacheControl
        self.compaction = compaction
        self.contextManagement = contextManagement
        self.mcpServers = mcpServers
        self.outputConfig = outputConfig
        self.speed = speed
        self.system = system
        self.thinking = thinking
        self.toolChoice = toolChoice
        self.tools = tools
        self.betas = betas
        self.userProfileID = userProfileID
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case messages
        case model
        case cacheControl = "cache_control"
        case compaction
        case contextManagement = "context_management"
        case mcpServers = "mcp_servers"
        case outputConfig = "output_config"
        case speed
        case system
        case thinking
        case toolChoice = "tool_choice"
        case tools
        case betas
        case userProfileID = "user_profile_id"
        case workspaceID = "workspace_id"
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

extension BetaMessageCountTokensParams {

    public indirect enum Tool: Codable, Hashable, Sendable {
        case betaToolParam(BetaToolParam)
        case betaToolBash20241022Param(BetaToolBash20241022Param)
        case betaToolBash20250124Param(BetaToolBash20250124Param)
        case betaCodeExecutionTool20250522Param(BetaCodeExecutionTool20250522Param)
        case betaCodeExecutionTool20250825Param(BetaCodeExecutionTool20250825Param)
        case betaCodeExecutionTool20260120Param(BetaCodeExecutionTool20260120Param)
        case betaCodeExecutionTool20260521Param(BetaCodeExecutionTool20260521Param)
        case betaBrowserToolset20260801Param(BetaBrowserToolset20260801Param)
        case betaToolComputerUse20241022Param(BetaToolComputerUse20241022Param)
        case betaMemoryTool20250818Param(BetaMemoryTool20250818Param)
        case betaToolComputerUse20250124Param(BetaToolComputerUse20250124Param)
        case betaToolTextEditor20241022Param(BetaToolTextEditor20241022Param)
        case betaToolComputerUse20251124Param(BetaToolComputerUse20251124Param)
        case betaComputerToolset20260801Param(BetaComputerToolset20260801Param)
        case betaToolTextEditor20250124Param(BetaToolTextEditor20250124Param)
        case betaToolTextEditor20250429Param(BetaToolTextEditor20250429Param)
        case betaToolTextEditor20250728Param(BetaToolTextEditor20250728Param)
        case betaWebSearchTool20250305Param(BetaWebSearchTool20250305Param)
        case betaWebFetchTool20250910Param(BetaWebFetchTool20250910Param)
        case betaWebSearchTool20260209Param(BetaWebSearchTool20260209Param)
        case betaWebFetchTool20260209Param(BetaWebFetchTool20260209Param)
        case betaWebFetchTool20260309Param(BetaWebFetchTool20260309Param)
        case betaWebSearchTool20260318Param(BetaWebSearchTool20260318Param)
        case betaWebFetchTool20260318Param(BetaWebFetchTool20260318Param)
        case betaAdvisorTool20260301Param(BetaAdvisorTool20260301Param)
        case betaToolSearchToolBm25_20251119Param(BetaToolSearchToolBm25_20251119Param)
        case betaToolSearchToolRegex20251119Param(BetaToolSearchToolRegex20251119Param)
        case betaMCPToolsetParam(BetaMCPToolsetParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if let v = try? BetaToolParam(from: decoder) { self = .betaToolParam(v); return }
            if _Coding.constantsMatch(decoder, ["name": "bash", "type": "bash_20241022"]), let v = try? BetaToolBash20241022Param(from: decoder) { self = .betaToolBash20241022Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "bash", "type": "bash_20250124"]), let v = try? BetaToolBash20250124Param(from: decoder) { self = .betaToolBash20250124Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20250522"]), let v = try? BetaCodeExecutionTool20250522Param(from: decoder) { self = .betaCodeExecutionTool20250522Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20250825"]), let v = try? BetaCodeExecutionTool20250825Param(from: decoder) { self = .betaCodeExecutionTool20250825Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20260120"]), let v = try? BetaCodeExecutionTool20260120Param(from: decoder) { self = .betaCodeExecutionTool20260120Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20260521"]), let v = try? BetaCodeExecutionTool20260521Param(from: decoder) { self = .betaCodeExecutionTool20260521Param(v); return }
            if _Coding.constantsMatch(decoder, ["type": "browser_toolset_20260801"]), let v = try? BetaBrowserToolset20260801Param(from: decoder) { self = .betaBrowserToolset20260801Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "computer", "type": "computer_20241022"]), let v = try? BetaToolComputerUse20241022Param(from: decoder) { self = .betaToolComputerUse20241022Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "memory", "type": "memory_20250818"]), let v = try? BetaMemoryTool20250818Param(from: decoder) { self = .betaMemoryTool20250818Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "computer", "type": "computer_20250124"]), let v = try? BetaToolComputerUse20250124Param(from: decoder) { self = .betaToolComputerUse20250124Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "str_replace_editor", "type": "text_editor_20241022"]), let v = try? BetaToolTextEditor20241022Param(from: decoder) { self = .betaToolTextEditor20241022Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "computer", "type": "computer_20251124"]), let v = try? BetaToolComputerUse20251124Param(from: decoder) { self = .betaToolComputerUse20251124Param(v); return }
            if _Coding.constantsMatch(decoder, ["type": "computer_toolset_20260801"]), let v = try? BetaComputerToolset20260801Param(from: decoder) { self = .betaComputerToolset20260801Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "str_replace_editor", "type": "text_editor_20250124"]), let v = try? BetaToolTextEditor20250124Param(from: decoder) { self = .betaToolTextEditor20250124Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "str_replace_based_edit_tool", "type": "text_editor_20250429"]), let v = try? BetaToolTextEditor20250429Param(from: decoder) { self = .betaToolTextEditor20250429Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "str_replace_based_edit_tool", "type": "text_editor_20250728"]), let v = try? BetaToolTextEditor20250728Param(from: decoder) { self = .betaToolTextEditor20250728Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_search", "type": "web_search_20250305"]), let v = try? BetaWebSearchTool20250305Param(from: decoder) { self = .betaWebSearchTool20250305Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20250910"]), let v = try? BetaWebFetchTool20250910Param(from: decoder) { self = .betaWebFetchTool20250910Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_search", "type": "web_search_20260209"]), let v = try? BetaWebSearchTool20260209Param(from: decoder) { self = .betaWebSearchTool20260209Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20260209"]), let v = try? BetaWebFetchTool20260209Param(from: decoder) { self = .betaWebFetchTool20260209Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20260309"]), let v = try? BetaWebFetchTool20260309Param(from: decoder) { self = .betaWebFetchTool20260309Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_search", "type": "web_search_20260318"]), let v = try? BetaWebSearchTool20260318Param(from: decoder) { self = .betaWebSearchTool20260318Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20260318"]), let v = try? BetaWebFetchTool20260318Param(from: decoder) { self = .betaWebFetchTool20260318Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "advisor", "type": "advisor_20260301"]), let v = try? BetaAdvisorTool20260301Param(from: decoder) { self = .betaAdvisorTool20260301Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "tool_search_tool_bm25"]), let v = try? BetaToolSearchToolBm25_20251119Param(from: decoder) { self = .betaToolSearchToolBm25_20251119Param(v); return }
            if _Coding.constantsMatch(decoder, ["name": "tool_search_tool_regex"]), let v = try? BetaToolSearchToolRegex20251119Param(from: decoder) { self = .betaToolSearchToolRegex20251119Param(v); return }
            if _Coding.constantsMatch(decoder, ["type": "mcp_toolset"]), let v = try? BetaMCPToolsetParam(from: decoder) { self = .betaMCPToolsetParam(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .betaToolParam(let v): try v.encode(to: encoder)
            case .betaToolBash20241022Param(let v): try v.encode(to: encoder)
            case .betaToolBash20250124Param(let v): try v.encode(to: encoder)
            case .betaCodeExecutionTool20250522Param(let v): try v.encode(to: encoder)
            case .betaCodeExecutionTool20250825Param(let v): try v.encode(to: encoder)
            case .betaCodeExecutionTool20260120Param(let v): try v.encode(to: encoder)
            case .betaCodeExecutionTool20260521Param(let v): try v.encode(to: encoder)
            case .betaBrowserToolset20260801Param(let v): try v.encode(to: encoder)
            case .betaToolComputerUse20241022Param(let v): try v.encode(to: encoder)
            case .betaMemoryTool20250818Param(let v): try v.encode(to: encoder)
            case .betaToolComputerUse20250124Param(let v): try v.encode(to: encoder)
            case .betaToolTextEditor20241022Param(let v): try v.encode(to: encoder)
            case .betaToolComputerUse20251124Param(let v): try v.encode(to: encoder)
            case .betaComputerToolset20260801Param(let v): try v.encode(to: encoder)
            case .betaToolTextEditor20250124Param(let v): try v.encode(to: encoder)
            case .betaToolTextEditor20250429Param(let v): try v.encode(to: encoder)
            case .betaToolTextEditor20250728Param(let v): try v.encode(to: encoder)
            case .betaWebSearchTool20250305Param(let v): try v.encode(to: encoder)
            case .betaWebFetchTool20250910Param(let v): try v.encode(to: encoder)
            case .betaWebSearchTool20260209Param(let v): try v.encode(to: encoder)
            case .betaWebFetchTool20260209Param(let v): try v.encode(to: encoder)
            case .betaWebFetchTool20260309Param(let v): try v.encode(to: encoder)
            case .betaWebSearchTool20260318Param(let v): try v.encode(to: encoder)
            case .betaWebFetchTool20260318Param(let v): try v.encode(to: encoder)
            case .betaAdvisorTool20260301Param(let v): try v.encode(to: encoder)
            case .betaToolSearchToolBm25_20251119Param(let v): try v.encode(to: encoder)
            case .betaToolSearchToolRegex20251119Param(let v): try v.encode(to: encoder)
            case .betaMCPToolsetParam(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
