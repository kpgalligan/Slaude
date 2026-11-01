// Transformed from `anthropic.types.beta.beta_content_block_param` (beta_content_block_param.py).

import Foundation

public indirect enum BetaContentBlockParam: Codable, Hashable, Sendable {
    case betaTextBlockParam(BetaTextBlockParam)
    case betaImageBlockParam(BetaImageBlockParam)
    case betaRequestDocumentBlockParam(BetaRequestDocumentBlockParam)
    case betaSearchResultBlockParam(BetaSearchResultBlockParam)
    case betaThinkingBlockParam(BetaThinkingBlockParam)
    case betaRedactedThinkingBlockParam(BetaRedactedThinkingBlockParam)
    case betaToolUseBlockParam(BetaToolUseBlockParam)
    case betaToolResultBlockParam(BetaToolResultBlockParam)
    case betaServerToolUseBlockParam(BetaServerToolUseBlockParam)
    case betaWebSearchToolResultBlockParam(BetaWebSearchToolResultBlockParam)
    case betaWebFetchToolResultBlockParam(BetaWebFetchToolResultBlockParam)
    case betaAdvisorToolResultBlockParam(BetaAdvisorToolResultBlockParam)
    case betaCodeExecutionToolResultBlockParam(BetaCodeExecutionToolResultBlockParam)
    case betaBashCodeExecutionToolResultBlockParam(BetaBashCodeExecutionToolResultBlockParam)
    case betaTextEditorCodeExecutionToolResultBlockParam(BetaTextEditorCodeExecutionToolResultBlockParam)
    case betaToolSearchToolResultBlockParam(BetaToolSearchToolResultBlockParam)
    case betaMCPToolUseBlockParam(BetaMCPToolUseBlockParam)
    case betaRequestMCPToolResultBlockParam(BetaRequestMCPToolResultBlockParam)
    case betaContainerUploadBlockParam(BetaContainerUploadBlockParam)
    case betaCompactionBlockParam(BetaCompactionBlockParam)
    case betaRequestToolAdditionBlockParam(BetaRequestToolAdditionBlockParam)
    case betaRequestToolRemovalBlockParam(BetaRequestToolRemovalBlockParam)
    case betaMCPToolListingBlockParam(BetaMCPToolListingBlockParam)
    case betaFallbackBlockParam(BetaFallbackBlockParam)
    case betaContentBlock(BetaContentBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaTextBlockParam(from: decoder) { self = .betaTextBlockParam(v); return }
        if let v = try? BetaImageBlockParam(from: decoder) { self = .betaImageBlockParam(v); return }
        if let v = try? BetaRequestDocumentBlockParam(from: decoder) { self = .betaRequestDocumentBlockParam(v); return }
        if let v = try? BetaSearchResultBlockParam(from: decoder) { self = .betaSearchResultBlockParam(v); return }
        if let v = try? BetaThinkingBlockParam(from: decoder) { self = .betaThinkingBlockParam(v); return }
        if let v = try? BetaRedactedThinkingBlockParam(from: decoder) { self = .betaRedactedThinkingBlockParam(v); return }
        if let v = try? BetaToolUseBlockParam(from: decoder) { self = .betaToolUseBlockParam(v); return }
        if let v = try? BetaToolResultBlockParam(from: decoder) { self = .betaToolResultBlockParam(v); return }
        if let v = try? BetaServerToolUseBlockParam(from: decoder) { self = .betaServerToolUseBlockParam(v); return }
        if let v = try? BetaWebSearchToolResultBlockParam(from: decoder) { self = .betaWebSearchToolResultBlockParam(v); return }
        if let v = try? BetaWebFetchToolResultBlockParam(from: decoder) { self = .betaWebFetchToolResultBlockParam(v); return }
        if let v = try? BetaAdvisorToolResultBlockParam(from: decoder) { self = .betaAdvisorToolResultBlockParam(v); return }
        if let v = try? BetaCodeExecutionToolResultBlockParam(from: decoder) { self = .betaCodeExecutionToolResultBlockParam(v); return }
        if let v = try? BetaBashCodeExecutionToolResultBlockParam(from: decoder) { self = .betaBashCodeExecutionToolResultBlockParam(v); return }
        if let v = try? BetaTextEditorCodeExecutionToolResultBlockParam(from: decoder) { self = .betaTextEditorCodeExecutionToolResultBlockParam(v); return }
        if let v = try? BetaToolSearchToolResultBlockParam(from: decoder) { self = .betaToolSearchToolResultBlockParam(v); return }
        if let v = try? BetaMCPToolUseBlockParam(from: decoder) { self = .betaMCPToolUseBlockParam(v); return }
        if let v = try? BetaRequestMCPToolResultBlockParam(from: decoder) { self = .betaRequestMCPToolResultBlockParam(v); return }
        if let v = try? BetaContainerUploadBlockParam(from: decoder) { self = .betaContainerUploadBlockParam(v); return }
        if let v = try? BetaCompactionBlockParam(from: decoder) { self = .betaCompactionBlockParam(v); return }
        if let v = try? BetaRequestToolAdditionBlockParam(from: decoder) { self = .betaRequestToolAdditionBlockParam(v); return }
        if let v = try? BetaRequestToolRemovalBlockParam(from: decoder) { self = .betaRequestToolRemovalBlockParam(v); return }
        if let v = try? BetaMCPToolListingBlockParam(from: decoder) { self = .betaMCPToolListingBlockParam(v); return }
        if let v = try? BetaFallbackBlockParam(from: decoder) { self = .betaFallbackBlockParam(v); return }
        if let v = try? BetaContentBlock(from: decoder) { self = .betaContentBlock(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaTextBlockParam(let v): try v.encode(to: encoder)
        case .betaImageBlockParam(let v): try v.encode(to: encoder)
        case .betaRequestDocumentBlockParam(let v): try v.encode(to: encoder)
        case .betaSearchResultBlockParam(let v): try v.encode(to: encoder)
        case .betaThinkingBlockParam(let v): try v.encode(to: encoder)
        case .betaRedactedThinkingBlockParam(let v): try v.encode(to: encoder)
        case .betaToolUseBlockParam(let v): try v.encode(to: encoder)
        case .betaToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaServerToolUseBlockParam(let v): try v.encode(to: encoder)
        case .betaWebSearchToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaWebFetchToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaAdvisorToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaCodeExecutionToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaBashCodeExecutionToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaTextEditorCodeExecutionToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaToolSearchToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaMCPToolUseBlockParam(let v): try v.encode(to: encoder)
        case .betaRequestMCPToolResultBlockParam(let v): try v.encode(to: encoder)
        case .betaContainerUploadBlockParam(let v): try v.encode(to: encoder)
        case .betaCompactionBlockParam(let v): try v.encode(to: encoder)
        case .betaRequestToolAdditionBlockParam(let v): try v.encode(to: encoder)
        case .betaRequestToolRemovalBlockParam(let v): try v.encode(to: encoder)
        case .betaMCPToolListingBlockParam(let v): try v.encode(to: encoder)
        case .betaFallbackBlockParam(let v): try v.encode(to: encoder)
        case .betaContentBlock(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
