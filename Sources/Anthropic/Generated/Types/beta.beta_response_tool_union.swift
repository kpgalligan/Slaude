// Transformed from `anthropic.types.beta.beta_response_tool_union` (beta_response_tool_union.py).

import Foundation

public indirect enum BetaResponseToolUnion: Codable, Hashable, Sendable {
    case betaResponseTool(BetaResponseTool)
    case betaToolBash20241022(BetaToolBash20241022)
    case betaToolBash20250124(BetaToolBash20250124)
    case betaCodeExecutionTool20250522(BetaCodeExecutionTool20250522)
    case betaCodeExecutionTool20250825(BetaCodeExecutionTool20250825)
    case betaCodeExecutionTool20260120(BetaCodeExecutionTool20260120)
    case betaCodeExecutionTool20260521(BetaCodeExecutionTool20260521)
    case betaBrowserToolset20260801(BetaBrowserToolset20260801)
    case betaToolComputerUse20241022(BetaToolComputerUse20241022)
    case betaMemoryTool20250818(BetaMemoryTool20250818)
    case betaToolComputerUse20250124(BetaToolComputerUse20250124)
    case betaToolTextEditor20241022(BetaToolTextEditor20241022)
    case betaToolComputerUse20251124(BetaToolComputerUse20251124)
    case betaComputerToolset20260801(BetaComputerToolset20260801)
    case betaToolTextEditor20250124(BetaToolTextEditor20250124)
    case betaToolTextEditor20250429(BetaToolTextEditor20250429)
    case betaToolTextEditor20250728(BetaToolTextEditor20250728)
    case betaWebSearchTool20250305(BetaWebSearchTool20250305)
    case betaWebFetchTool20250910(BetaWebFetchTool20250910)
    case betaWebSearchTool20260209(BetaWebSearchTool20260209)
    case betaWebFetchTool20260209(BetaWebFetchTool20260209)
    case betaWebFetchTool20260309(BetaWebFetchTool20260309)
    case betaWebSearchTool20260318(BetaWebSearchTool20260318)
    case betaWebFetchTool20260318(BetaWebFetchTool20260318)
    case betaAdvisorTool20260301(BetaAdvisorTool20260301)
    case betaToolSearchToolBm25_20251119(BetaToolSearchToolBm25_20251119)
    case betaToolSearchToolRegex20251119(BetaToolSearchToolRegex20251119)
    case betaMCPToolset(BetaMCPToolset)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaResponseTool(from: decoder) { self = .betaResponseTool(v); return }
        if let v = try? BetaToolBash20241022(from: decoder) { self = .betaToolBash20241022(v); return }
        if let v = try? BetaToolBash20250124(from: decoder) { self = .betaToolBash20250124(v); return }
        if let v = try? BetaCodeExecutionTool20250522(from: decoder) { self = .betaCodeExecutionTool20250522(v); return }
        if let v = try? BetaCodeExecutionTool20250825(from: decoder) { self = .betaCodeExecutionTool20250825(v); return }
        if let v = try? BetaCodeExecutionTool20260120(from: decoder) { self = .betaCodeExecutionTool20260120(v); return }
        if let v = try? BetaCodeExecutionTool20260521(from: decoder) { self = .betaCodeExecutionTool20260521(v); return }
        if let v = try? BetaBrowserToolset20260801(from: decoder) { self = .betaBrowserToolset20260801(v); return }
        if let v = try? BetaToolComputerUse20241022(from: decoder) { self = .betaToolComputerUse20241022(v); return }
        if let v = try? BetaMemoryTool20250818(from: decoder) { self = .betaMemoryTool20250818(v); return }
        if let v = try? BetaToolComputerUse20250124(from: decoder) { self = .betaToolComputerUse20250124(v); return }
        if let v = try? BetaToolTextEditor20241022(from: decoder) { self = .betaToolTextEditor20241022(v); return }
        if let v = try? BetaToolComputerUse20251124(from: decoder) { self = .betaToolComputerUse20251124(v); return }
        if let v = try? BetaComputerToolset20260801(from: decoder) { self = .betaComputerToolset20260801(v); return }
        if let v = try? BetaToolTextEditor20250124(from: decoder) { self = .betaToolTextEditor20250124(v); return }
        if let v = try? BetaToolTextEditor20250429(from: decoder) { self = .betaToolTextEditor20250429(v); return }
        if let v = try? BetaToolTextEditor20250728(from: decoder) { self = .betaToolTextEditor20250728(v); return }
        if let v = try? BetaWebSearchTool20250305(from: decoder) { self = .betaWebSearchTool20250305(v); return }
        if let v = try? BetaWebFetchTool20250910(from: decoder) { self = .betaWebFetchTool20250910(v); return }
        if let v = try? BetaWebSearchTool20260209(from: decoder) { self = .betaWebSearchTool20260209(v); return }
        if let v = try? BetaWebFetchTool20260209(from: decoder) { self = .betaWebFetchTool20260209(v); return }
        if let v = try? BetaWebFetchTool20260309(from: decoder) { self = .betaWebFetchTool20260309(v); return }
        if let v = try? BetaWebSearchTool20260318(from: decoder) { self = .betaWebSearchTool20260318(v); return }
        if let v = try? BetaWebFetchTool20260318(from: decoder) { self = .betaWebFetchTool20260318(v); return }
        if let v = try? BetaAdvisorTool20260301(from: decoder) { self = .betaAdvisorTool20260301(v); return }
        if let v = try? BetaToolSearchToolBm25_20251119(from: decoder) { self = .betaToolSearchToolBm25_20251119(v); return }
        if let v = try? BetaToolSearchToolRegex20251119(from: decoder) { self = .betaToolSearchToolRegex20251119(v); return }
        if let v = try? BetaMCPToolset(from: decoder) { self = .betaMCPToolset(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaResponseTool(let v): try v.encode(to: encoder)
        case .betaToolBash20241022(let v): try v.encode(to: encoder)
        case .betaToolBash20250124(let v): try v.encode(to: encoder)
        case .betaCodeExecutionTool20250522(let v): try v.encode(to: encoder)
        case .betaCodeExecutionTool20250825(let v): try v.encode(to: encoder)
        case .betaCodeExecutionTool20260120(let v): try v.encode(to: encoder)
        case .betaCodeExecutionTool20260521(let v): try v.encode(to: encoder)
        case .betaBrowserToolset20260801(let v): try v.encode(to: encoder)
        case .betaToolComputerUse20241022(let v): try v.encode(to: encoder)
        case .betaMemoryTool20250818(let v): try v.encode(to: encoder)
        case .betaToolComputerUse20250124(let v): try v.encode(to: encoder)
        case .betaToolTextEditor20241022(let v): try v.encode(to: encoder)
        case .betaToolComputerUse20251124(let v): try v.encode(to: encoder)
        case .betaComputerToolset20260801(let v): try v.encode(to: encoder)
        case .betaToolTextEditor20250124(let v): try v.encode(to: encoder)
        case .betaToolTextEditor20250429(let v): try v.encode(to: encoder)
        case .betaToolTextEditor20250728(let v): try v.encode(to: encoder)
        case .betaWebSearchTool20250305(let v): try v.encode(to: encoder)
        case .betaWebFetchTool20250910(let v): try v.encode(to: encoder)
        case .betaWebSearchTool20260209(let v): try v.encode(to: encoder)
        case .betaWebFetchTool20260209(let v): try v.encode(to: encoder)
        case .betaWebFetchTool20260309(let v): try v.encode(to: encoder)
        case .betaWebSearchTool20260318(let v): try v.encode(to: encoder)
        case .betaWebFetchTool20260318(let v): try v.encode(to: encoder)
        case .betaAdvisorTool20260301(let v): try v.encode(to: encoder)
        case .betaToolSearchToolBm25_20251119(let v): try v.encode(to: encoder)
        case .betaToolSearchToolRegex20251119(let v): try v.encode(to: encoder)
        case .betaMCPToolset(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
