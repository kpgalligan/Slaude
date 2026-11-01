// Transformed from `anthropic.types.beta.beta_model_capabilities` (beta_model_capabilities.py).

import Foundation

/// Model capability information.
public struct BetaModelCapabilities: Codable, Hashable, Sendable {
    /// Whether the model supports the Batch API.
    public var batch: BetaCapabilitySupport
    /// Whether the model supports citation generation.
    public var citations: BetaCapabilitySupport
    /// Whether code that the model runs in the code execution tool can call the
    /// request's other tools, as in programmatic tool calling and dynamic filtering for
    /// web search and web fetch. Support for the code execution tool itself is in
    /// `server_tools.code_execution`.
    public var codeExecution: BetaCapabilitySupport
    /// Server-side compaction support (the top-level `compaction` parameter) and the
    /// accepted `compaction.type` values.
    public var compaction: BetaCompactionCapability?
    /// Context management support and available strategies.
    public var contextManagement: BetaContextManagementCapability
    /// Effort (reasoning_effort) support and available levels.
    public var effort: BetaEffortCapability
    /// Whether the model accepts image content blocks.
    public var imageInput: BetaCapabilitySupport
    /// Whether the model accepts PDF content blocks.
    public var pdfInput: BetaCapabilitySupport
    /// Whether this model supports the web search and code execution server tools.
    ///
    /// `supported` is true when the model supports at least one of the tools. A
    /// supported tool can still be rejected for your organization, for example when an
    /// admin has turned web search off.
    public var serverTools: BetaServerToolsCapability
    /// Whether the model supports structured output / JSON mode / strict tool schemas.
    public var structuredOutputs: BetaCapabilitySupport
    /// Thinking capability and supported type configurations.
    public var thinking: BetaThinkingCapability

    public init(batch: BetaCapabilitySupport, citations: BetaCapabilitySupport, codeExecution: BetaCapabilitySupport, compaction: BetaCompactionCapability? = nil, contextManagement: BetaContextManagementCapability, effort: BetaEffortCapability, imageInput: BetaCapabilitySupport, pdfInput: BetaCapabilitySupport, serverTools: BetaServerToolsCapability, structuredOutputs: BetaCapabilitySupport, thinking: BetaThinkingCapability) {
        self.batch = batch
        self.citations = citations
        self.codeExecution = codeExecution
        self.compaction = compaction
        self.contextManagement = contextManagement
        self.effort = effort
        self.imageInput = imageInput
        self.pdfInput = pdfInput
        self.serverTools = serverTools
        self.structuredOutputs = structuredOutputs
        self.thinking = thinking
    }

    enum CodingKeys: String, CodingKey {
        case batch
        case citations
        case codeExecution = "code_execution"
        case compaction
        case contextManagement = "context_management"
        case effort
        case imageInput = "image_input"
        case pdfInput = "pdf_input"
        case serverTools = "server_tools"
        case structuredOutputs = "structured_outputs"
        case thinking
    }
}
