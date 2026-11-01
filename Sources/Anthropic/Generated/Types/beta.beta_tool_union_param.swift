// Transformed from `anthropic.types.beta.beta_tool_union_param` (beta_tool_union_param.py).

import Foundation

public indirect enum BetaToolUnionParam: Codable, Hashable, Sendable {
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
        if let v = try? BetaToolBash20241022Param(from: decoder) { self = .betaToolBash20241022Param(v); return }
        if let v = try? BetaToolBash20250124Param(from: decoder) { self = .betaToolBash20250124Param(v); return }
        if let v = try? BetaCodeExecutionTool20250522Param(from: decoder) { self = .betaCodeExecutionTool20250522Param(v); return }
        if let v = try? BetaCodeExecutionTool20250825Param(from: decoder) { self = .betaCodeExecutionTool20250825Param(v); return }
        if let v = try? BetaCodeExecutionTool20260120Param(from: decoder) { self = .betaCodeExecutionTool20260120Param(v); return }
        if let v = try? BetaCodeExecutionTool20260521Param(from: decoder) { self = .betaCodeExecutionTool20260521Param(v); return }
        if let v = try? BetaBrowserToolset20260801Param(from: decoder) { self = .betaBrowserToolset20260801Param(v); return }
        if let v = try? BetaToolComputerUse20241022Param(from: decoder) { self = .betaToolComputerUse20241022Param(v); return }
        if let v = try? BetaMemoryTool20250818Param(from: decoder) { self = .betaMemoryTool20250818Param(v); return }
        if let v = try? BetaToolComputerUse20250124Param(from: decoder) { self = .betaToolComputerUse20250124Param(v); return }
        if let v = try? BetaToolTextEditor20241022Param(from: decoder) { self = .betaToolTextEditor20241022Param(v); return }
        if let v = try? BetaToolComputerUse20251124Param(from: decoder) { self = .betaToolComputerUse20251124Param(v); return }
        if let v = try? BetaComputerToolset20260801Param(from: decoder) { self = .betaComputerToolset20260801Param(v); return }
        if let v = try? BetaToolTextEditor20250124Param(from: decoder) { self = .betaToolTextEditor20250124Param(v); return }
        if let v = try? BetaToolTextEditor20250429Param(from: decoder) { self = .betaToolTextEditor20250429Param(v); return }
        if let v = try? BetaToolTextEditor20250728Param(from: decoder) { self = .betaToolTextEditor20250728Param(v); return }
        if let v = try? BetaWebSearchTool20250305Param(from: decoder) { self = .betaWebSearchTool20250305Param(v); return }
        if let v = try? BetaWebFetchTool20250910Param(from: decoder) { self = .betaWebFetchTool20250910Param(v); return }
        if let v = try? BetaWebSearchTool20260209Param(from: decoder) { self = .betaWebSearchTool20260209Param(v); return }
        if let v = try? BetaWebFetchTool20260209Param(from: decoder) { self = .betaWebFetchTool20260209Param(v); return }
        if let v = try? BetaWebFetchTool20260309Param(from: decoder) { self = .betaWebFetchTool20260309Param(v); return }
        if let v = try? BetaWebSearchTool20260318Param(from: decoder) { self = .betaWebSearchTool20260318Param(v); return }
        if let v = try? BetaWebFetchTool20260318Param(from: decoder) { self = .betaWebFetchTool20260318Param(v); return }
        if let v = try? BetaAdvisorTool20260301Param(from: decoder) { self = .betaAdvisorTool20260301Param(v); return }
        if let v = try? BetaToolSearchToolBm25_20251119Param(from: decoder) { self = .betaToolSearchToolBm25_20251119Param(v); return }
        if let v = try? BetaToolSearchToolRegex20251119Param(from: decoder) { self = .betaToolSearchToolRegex20251119Param(v); return }
        if let v = try? BetaMCPToolsetParam(from: decoder) { self = .betaMCPToolsetParam(v); return }
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
