// Transformed from `anthropic.types.anthropic_beta_param` (anthropic_beta_param.py).

import Foundation

public enum AnthropicBetaParam: OpenEnum, CaseIterable {
    case messageBatches2024_09_24
    case promptCaching2024_07_31
    case computerUse2024_10_22
    case computerUse2025_01_24
    case pdfs2024_09_25
    case tokenCounting2024_11_01
    case tokenEfficientTools2025_02_19
    case output128k2025_02_19
    case filesApi2025_04_14
    case mcpClient2025_04_04
    case mcpClient2025_11_20
    case devFullThinking2025_05_14
    case interleavedThinking2025_05_14
    case codeExecution2025_05_22
    case extendedCacheTtl2025_04_11
    case context1m2025_08_07
    case contextManagement2025_06_27
    case modelContextWindowExceeded2025_08_26
    case skills2025_10_02
    case fastMode2026_02_01
    case output300k2026_03_24
    case userProfiles2026_03_24
    case userProfiles2026_08_18
    case userProfiles2026_09_04
    case advisorTool2026_03_01
    case managedAgents2026_04_01
    case cacheDiagnosis2026_04_07
    case dreaming2026_04_21
    case thinkingTokenCount2026_05_13
    case serverSideFallback2026_06_01
    case serverSideFallback2026_07_01
    case fallbackCredit2026_06_01
    case fallbackCredit2026_07_01
    case agentMemory2026_07_22
    case midConversationToolChanges2026_07_01
    case compact2026_01_12
    case computerUse2025_11_24
    case mcpTunnels2026_06_22
    case structuredOutputs2025_11_13
    case taskBudgets2026_03_13
    case thinkingDisplayUpdates2026_08_18
    case ceUserManagement2026_07_13
    case midConversationOutputConfig2026_07_01
    case thinkingBindingControls2026_08_01
    case midConversationSystemClearAt2026_08_21
    case compact2026_09_04
    case inlineTools2026_09_15
    case mcpClient2026_09_15
    case cePlugins2026_09_01
    case spendLimitReads2026_09_26
    case telemetryDestinations2026_08_11
    case webhooks2026_10_07
    case messageThreads2026_08_12
    case analyticsUsageCost2026_08_24
    case experimentalClaudeTag2026_10_21
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [AnthropicBetaParam] = [.messageBatches2024_09_24, .promptCaching2024_07_31, .computerUse2024_10_22, .computerUse2025_01_24, .pdfs2024_09_25, .tokenCounting2024_11_01, .tokenEfficientTools2025_02_19, .output128k2025_02_19, .filesApi2025_04_14, .mcpClient2025_04_04, .mcpClient2025_11_20, .devFullThinking2025_05_14, .interleavedThinking2025_05_14, .codeExecution2025_05_22, .extendedCacheTtl2025_04_11, .context1m2025_08_07, .contextManagement2025_06_27, .modelContextWindowExceeded2025_08_26, .skills2025_10_02, .fastMode2026_02_01, .output300k2026_03_24, .userProfiles2026_03_24, .userProfiles2026_08_18, .userProfiles2026_09_04, .advisorTool2026_03_01, .managedAgents2026_04_01, .cacheDiagnosis2026_04_07, .dreaming2026_04_21, .thinkingTokenCount2026_05_13, .serverSideFallback2026_06_01, .serverSideFallback2026_07_01, .fallbackCredit2026_06_01, .fallbackCredit2026_07_01, .agentMemory2026_07_22, .midConversationToolChanges2026_07_01, .compact2026_01_12, .computerUse2025_11_24, .mcpTunnels2026_06_22, .structuredOutputs2025_11_13, .taskBudgets2026_03_13, .thinkingDisplayUpdates2026_08_18, .ceUserManagement2026_07_13, .midConversationOutputConfig2026_07_01, .thinkingBindingControls2026_08_01, .midConversationSystemClearAt2026_08_21, .compact2026_09_04, .inlineTools2026_09_15, .mcpClient2026_09_15, .cePlugins2026_09_01, .spendLimitReads2026_09_26, .telemetryDestinations2026_08_11, .webhooks2026_10_07, .messageThreads2026_08_12, .analyticsUsageCost2026_08_24, .experimentalClaudeTag2026_10_21]

    public init(rawValue: String) {
        switch rawValue {
        case "message-batches-2024-09-24": self = .messageBatches2024_09_24
        case "prompt-caching-2024-07-31": self = .promptCaching2024_07_31
        case "computer-use-2024-10-22": self = .computerUse2024_10_22
        case "computer-use-2025-01-24": self = .computerUse2025_01_24
        case "pdfs-2024-09-25": self = .pdfs2024_09_25
        case "token-counting-2024-11-01": self = .tokenCounting2024_11_01
        case "token-efficient-tools-2025-02-19": self = .tokenEfficientTools2025_02_19
        case "output-128k-2025-02-19": self = .output128k2025_02_19
        case "files-api-2025-04-14": self = .filesApi2025_04_14
        case "mcp-client-2025-04-04": self = .mcpClient2025_04_04
        case "mcp-client-2025-11-20": self = .mcpClient2025_11_20
        case "dev-full-thinking-2025-05-14": self = .devFullThinking2025_05_14
        case "interleaved-thinking-2025-05-14": self = .interleavedThinking2025_05_14
        case "code-execution-2025-05-22": self = .codeExecution2025_05_22
        case "extended-cache-ttl-2025-04-11": self = .extendedCacheTtl2025_04_11
        case "context-1m-2025-08-07": self = .context1m2025_08_07
        case "context-management-2025-06-27": self = .contextManagement2025_06_27
        case "model-context-window-exceeded-2025-08-26": self = .modelContextWindowExceeded2025_08_26
        case "skills-2025-10-02": self = .skills2025_10_02
        case "fast-mode-2026-02-01": self = .fastMode2026_02_01
        case "output-300k-2026-03-24": self = .output300k2026_03_24
        case "user-profiles-2026-03-24": self = .userProfiles2026_03_24
        case "user-profiles-2026-08-18": self = .userProfiles2026_08_18
        case "user-profiles-2026-09-04": self = .userProfiles2026_09_04
        case "advisor-tool-2026-03-01": self = .advisorTool2026_03_01
        case "managed-agents-2026-04-01": self = .managedAgents2026_04_01
        case "cache-diagnosis-2026-04-07": self = .cacheDiagnosis2026_04_07
        case "dreaming-2026-04-21": self = .dreaming2026_04_21
        case "thinking-token-count-2026-05-13": self = .thinkingTokenCount2026_05_13
        case "server-side-fallback-2026-06-01": self = .serverSideFallback2026_06_01
        case "server-side-fallback-2026-07-01": self = .serverSideFallback2026_07_01
        case "fallback-credit-2026-06-01": self = .fallbackCredit2026_06_01
        case "fallback-credit-2026-07-01": self = .fallbackCredit2026_07_01
        case "agent-memory-2026-07-22": self = .agentMemory2026_07_22
        case "mid-conversation-tool-changes-2026-07-01": self = .midConversationToolChanges2026_07_01
        case "compact-2026-01-12": self = .compact2026_01_12
        case "computer-use-2025-11-24": self = .computerUse2025_11_24
        case "mcp-tunnels-2026-06-22": self = .mcpTunnels2026_06_22
        case "structured-outputs-2025-11-13": self = .structuredOutputs2025_11_13
        case "task-budgets-2026-03-13": self = .taskBudgets2026_03_13
        case "thinking-display-updates-2026-08-18": self = .thinkingDisplayUpdates2026_08_18
        case "ce-user-management-2026-07-13": self = .ceUserManagement2026_07_13
        case "mid-conversation-output-config-2026-07-01": self = .midConversationOutputConfig2026_07_01
        case "thinking-binding-controls-2026-08-01": self = .thinkingBindingControls2026_08_01
        case "mid-conversation-system-clear-at-2026-08-21": self = .midConversationSystemClearAt2026_08_21
        case "compact-2026-09-04": self = .compact2026_09_04
        case "inline-tools-2026-09-15": self = .inlineTools2026_09_15
        case "mcp-client-2026-09-15": self = .mcpClient2026_09_15
        case "ce-plugins-2026-09-01": self = .cePlugins2026_09_01
        case "spend-limit-reads-2026-09-26": self = .spendLimitReads2026_09_26
        case "telemetry-destinations-2026-08-11": self = .telemetryDestinations2026_08_11
        case "webhooks-2026-10-07": self = .webhooks2026_10_07
        case "message-threads-2026-08-12": self = .messageThreads2026_08_12
        case "analytics-usage-cost-2026-08-24": self = .analyticsUsageCost2026_08_24
        case "experimental-claude-tag-2026-10-21": self = .experimentalClaudeTag2026_10_21
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .messageBatches2024_09_24: return "message-batches-2024-09-24"
        case .promptCaching2024_07_31: return "prompt-caching-2024-07-31"
        case .computerUse2024_10_22: return "computer-use-2024-10-22"
        case .computerUse2025_01_24: return "computer-use-2025-01-24"
        case .pdfs2024_09_25: return "pdfs-2024-09-25"
        case .tokenCounting2024_11_01: return "token-counting-2024-11-01"
        case .tokenEfficientTools2025_02_19: return "token-efficient-tools-2025-02-19"
        case .output128k2025_02_19: return "output-128k-2025-02-19"
        case .filesApi2025_04_14: return "files-api-2025-04-14"
        case .mcpClient2025_04_04: return "mcp-client-2025-04-04"
        case .mcpClient2025_11_20: return "mcp-client-2025-11-20"
        case .devFullThinking2025_05_14: return "dev-full-thinking-2025-05-14"
        case .interleavedThinking2025_05_14: return "interleaved-thinking-2025-05-14"
        case .codeExecution2025_05_22: return "code-execution-2025-05-22"
        case .extendedCacheTtl2025_04_11: return "extended-cache-ttl-2025-04-11"
        case .context1m2025_08_07: return "context-1m-2025-08-07"
        case .contextManagement2025_06_27: return "context-management-2025-06-27"
        case .modelContextWindowExceeded2025_08_26: return "model-context-window-exceeded-2025-08-26"
        case .skills2025_10_02: return "skills-2025-10-02"
        case .fastMode2026_02_01: return "fast-mode-2026-02-01"
        case .output300k2026_03_24: return "output-300k-2026-03-24"
        case .userProfiles2026_03_24: return "user-profiles-2026-03-24"
        case .userProfiles2026_08_18: return "user-profiles-2026-08-18"
        case .userProfiles2026_09_04: return "user-profiles-2026-09-04"
        case .advisorTool2026_03_01: return "advisor-tool-2026-03-01"
        case .managedAgents2026_04_01: return "managed-agents-2026-04-01"
        case .cacheDiagnosis2026_04_07: return "cache-diagnosis-2026-04-07"
        case .dreaming2026_04_21: return "dreaming-2026-04-21"
        case .thinkingTokenCount2026_05_13: return "thinking-token-count-2026-05-13"
        case .serverSideFallback2026_06_01: return "server-side-fallback-2026-06-01"
        case .serverSideFallback2026_07_01: return "server-side-fallback-2026-07-01"
        case .fallbackCredit2026_06_01: return "fallback-credit-2026-06-01"
        case .fallbackCredit2026_07_01: return "fallback-credit-2026-07-01"
        case .agentMemory2026_07_22: return "agent-memory-2026-07-22"
        case .midConversationToolChanges2026_07_01: return "mid-conversation-tool-changes-2026-07-01"
        case .compact2026_01_12: return "compact-2026-01-12"
        case .computerUse2025_11_24: return "computer-use-2025-11-24"
        case .mcpTunnels2026_06_22: return "mcp-tunnels-2026-06-22"
        case .structuredOutputs2025_11_13: return "structured-outputs-2025-11-13"
        case .taskBudgets2026_03_13: return "task-budgets-2026-03-13"
        case .thinkingDisplayUpdates2026_08_18: return "thinking-display-updates-2026-08-18"
        case .ceUserManagement2026_07_13: return "ce-user-management-2026-07-13"
        case .midConversationOutputConfig2026_07_01: return "mid-conversation-output-config-2026-07-01"
        case .thinkingBindingControls2026_08_01: return "thinking-binding-controls-2026-08-01"
        case .midConversationSystemClearAt2026_08_21: return "mid-conversation-system-clear-at-2026-08-21"
        case .compact2026_09_04: return "compact-2026-09-04"
        case .inlineTools2026_09_15: return "inline-tools-2026-09-15"
        case .mcpClient2026_09_15: return "mcp-client-2026-09-15"
        case .cePlugins2026_09_01: return "ce-plugins-2026-09-01"
        case .spendLimitReads2026_09_26: return "spend-limit-reads-2026-09-26"
        case .telemetryDestinations2026_08_11: return "telemetry-destinations-2026-08-11"
        case .webhooks2026_10_07: return "webhooks-2026-10-07"
        case .messageThreads2026_08_12: return "message-threads-2026-08-12"
        case .analyticsUsageCost2026_08_24: return "analytics-usage-cost-2026-08-24"
        case .experimentalClaudeTag2026_10_21: return "experimental-claude-tag-2026-10-21"
        case .unknown(let value): return value
        }
    }
}
