// Transformed from `anthropic.types.model_capabilities` (model_capabilities.py).

import Foundation

/// Model capability information.
public struct ModelCapabilities: Codable, Hashable, Sendable {
    /// Whether the model supports the Batch API.
    public var batch: CapabilitySupport
    /// Whether the model supports citation generation.
    public var citations: CapabilitySupport
    /// Whether code that the model runs in the code execution tool can call the
    /// request's other tools, as in programmatic tool calling and dynamic filtering for
    /// web search and web fetch. Support for the code execution tool itself is in
    /// `server_tools.code_execution`.
    public var codeExecution: CapabilitySupport
    /// Context management support and available strategies.
    public var contextManagement: ContextManagementCapability
    /// Effort (reasoning_effort) support and available levels.
    public var effort: EffortCapability
    /// Whether the model accepts image content blocks.
    public var imageInput: CapabilitySupport
    /// Whether the model accepts PDF content blocks.
    public var pdfInput: CapabilitySupport
    /// Whether this model supports the web search and code execution server tools.
    ///
    /// `supported` is true when the model supports at least one of the tools. A
    /// supported tool can still be rejected for your organization, for example when an
    /// admin has turned web search off.
    public var serverTools: ServerToolsCapability
    /// Whether the model supports structured output / JSON mode / strict tool schemas.
    public var structuredOutputs: CapabilitySupport
    /// Thinking capability and supported type configurations.
    public var thinking: ThinkingCapability

    public init(batch: CapabilitySupport, citations: CapabilitySupport, codeExecution: CapabilitySupport, contextManagement: ContextManagementCapability, effort: EffortCapability, imageInput: CapabilitySupport, pdfInput: CapabilitySupport, serverTools: ServerToolsCapability, structuredOutputs: CapabilitySupport, thinking: ThinkingCapability) {
        self.batch = batch
        self.citations = citations
        self.codeExecution = codeExecution
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
        case contextManagement = "context_management"
        case effort
        case imageInput = "image_input"
        case pdfInput = "pdf_input"
        case serverTools = "server_tools"
        case structuredOutputs = "structured_outputs"
        case thinking
    }
}
