// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_event_type` (beta_managed_agents_session_event_type.py).

import Foundation

public enum BetaManagedAgentsSessionEventType: OpenEnum, CaseIterable {
    case userMessage
    case userInterrupt
    case userToolConfirmation
    case userCustomToolResult
    case agentCustomToolUse
    case agentMessage
    case agentThinking
    case agentMcpToolUse
    case agentMcpToolResult
    case agentToolUse
    case agentToolResult
    case agentThreadMessageReceived
    case agentThreadMessageSent
    case agentThreadContextCompacted
    case sessionError
    case sessionStatusRescheduled
    case sessionStatusRunning
    case sessionStatusIdle
    case sessionStatusTerminated
    case sessionThreadCreated
    case spanOutcomeEvaluationStart
    case spanOutcomeEvaluationEnd
    case spanModelRequestStart
    case spanModelRequestEnd
    case spanOutcomeEvaluationOngoing
    case userDefineOutcome
    case sessionThreadStatusRunning
    case sessionThreadStatusIdle
    case sessionThreadStatusTerminated
    case userToolResult
    case sessionThreadStatusRescheduled
    case sessionUpdated
    case systemMessage
    case sessionUsage
    case workflowRunCreated
    case workflowRunStatusRunning
    case workflowRunStatusIdle
    case workflowRunStatusEnded
    case workflowRunError
    case workflowRunPhaseStarted
    case workflowRunPhaseEnded
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsSessionEventType] = [.userMessage, .userInterrupt, .userToolConfirmation, .userCustomToolResult, .agentCustomToolUse, .agentMessage, .agentThinking, .agentMcpToolUse, .agentMcpToolResult, .agentToolUse, .agentToolResult, .agentThreadMessageReceived, .agentThreadMessageSent, .agentThreadContextCompacted, .sessionError, .sessionStatusRescheduled, .sessionStatusRunning, .sessionStatusIdle, .sessionStatusTerminated, .sessionThreadCreated, .spanOutcomeEvaluationStart, .spanOutcomeEvaluationEnd, .spanModelRequestStart, .spanModelRequestEnd, .spanOutcomeEvaluationOngoing, .userDefineOutcome, .sessionThreadStatusRunning, .sessionThreadStatusIdle, .sessionThreadStatusTerminated, .userToolResult, .sessionThreadStatusRescheduled, .sessionUpdated, .systemMessage, .sessionUsage, .workflowRunCreated, .workflowRunStatusRunning, .workflowRunStatusIdle, .workflowRunStatusEnded, .workflowRunError, .workflowRunPhaseStarted, .workflowRunPhaseEnded]

    public init(rawValue: String) {
        switch rawValue {
        case "user.message": self = .userMessage
        case "user.interrupt": self = .userInterrupt
        case "user.tool_confirmation": self = .userToolConfirmation
        case "user.custom_tool_result": self = .userCustomToolResult
        case "agent.custom_tool_use": self = .agentCustomToolUse
        case "agent.message": self = .agentMessage
        case "agent.thinking": self = .agentThinking
        case "agent.mcp_tool_use": self = .agentMcpToolUse
        case "agent.mcp_tool_result": self = .agentMcpToolResult
        case "agent.tool_use": self = .agentToolUse
        case "agent.tool_result": self = .agentToolResult
        case "agent.thread_message_received": self = .agentThreadMessageReceived
        case "agent.thread_message_sent": self = .agentThreadMessageSent
        case "agent.thread_context_compacted": self = .agentThreadContextCompacted
        case "session.error": self = .sessionError
        case "session.status_rescheduled": self = .sessionStatusRescheduled
        case "session.status_running": self = .sessionStatusRunning
        case "session.status_idle": self = .sessionStatusIdle
        case "session.status_terminated": self = .sessionStatusTerminated
        case "session.thread_created": self = .sessionThreadCreated
        case "span.outcome_evaluation_start": self = .spanOutcomeEvaluationStart
        case "span.outcome_evaluation_end": self = .spanOutcomeEvaluationEnd
        case "span.model_request_start": self = .spanModelRequestStart
        case "span.model_request_end": self = .spanModelRequestEnd
        case "span.outcome_evaluation_ongoing": self = .spanOutcomeEvaluationOngoing
        case "user.define_outcome": self = .userDefineOutcome
        case "session.thread_status_running": self = .sessionThreadStatusRunning
        case "session.thread_status_idle": self = .sessionThreadStatusIdle
        case "session.thread_status_terminated": self = .sessionThreadStatusTerminated
        case "user.tool_result": self = .userToolResult
        case "session.thread_status_rescheduled": self = .sessionThreadStatusRescheduled
        case "session.updated": self = .sessionUpdated
        case "system.message": self = .systemMessage
        case "session.usage": self = .sessionUsage
        case "workflow_run.created": self = .workflowRunCreated
        case "workflow_run.status_running": self = .workflowRunStatusRunning
        case "workflow_run.status_idle": self = .workflowRunStatusIdle
        case "workflow_run.status_ended": self = .workflowRunStatusEnded
        case "workflow_run.error": self = .workflowRunError
        case "workflow_run.phase_started": self = .workflowRunPhaseStarted
        case "workflow_run.phase_ended": self = .workflowRunPhaseEnded
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .userMessage: return "user.message"
        case .userInterrupt: return "user.interrupt"
        case .userToolConfirmation: return "user.tool_confirmation"
        case .userCustomToolResult: return "user.custom_tool_result"
        case .agentCustomToolUse: return "agent.custom_tool_use"
        case .agentMessage: return "agent.message"
        case .agentThinking: return "agent.thinking"
        case .agentMcpToolUse: return "agent.mcp_tool_use"
        case .agentMcpToolResult: return "agent.mcp_tool_result"
        case .agentToolUse: return "agent.tool_use"
        case .agentToolResult: return "agent.tool_result"
        case .agentThreadMessageReceived: return "agent.thread_message_received"
        case .agentThreadMessageSent: return "agent.thread_message_sent"
        case .agentThreadContextCompacted: return "agent.thread_context_compacted"
        case .sessionError: return "session.error"
        case .sessionStatusRescheduled: return "session.status_rescheduled"
        case .sessionStatusRunning: return "session.status_running"
        case .sessionStatusIdle: return "session.status_idle"
        case .sessionStatusTerminated: return "session.status_terminated"
        case .sessionThreadCreated: return "session.thread_created"
        case .spanOutcomeEvaluationStart: return "span.outcome_evaluation_start"
        case .spanOutcomeEvaluationEnd: return "span.outcome_evaluation_end"
        case .spanModelRequestStart: return "span.model_request_start"
        case .spanModelRequestEnd: return "span.model_request_end"
        case .spanOutcomeEvaluationOngoing: return "span.outcome_evaluation_ongoing"
        case .userDefineOutcome: return "user.define_outcome"
        case .sessionThreadStatusRunning: return "session.thread_status_running"
        case .sessionThreadStatusIdle: return "session.thread_status_idle"
        case .sessionThreadStatusTerminated: return "session.thread_status_terminated"
        case .userToolResult: return "user.tool_result"
        case .sessionThreadStatusRescheduled: return "session.thread_status_rescheduled"
        case .sessionUpdated: return "session.updated"
        case .systemMessage: return "system.message"
        case .sessionUsage: return "session.usage"
        case .workflowRunCreated: return "workflow_run.created"
        case .workflowRunStatusRunning: return "workflow_run.status_running"
        case .workflowRunStatusIdle: return "workflow_run.status_idle"
        case .workflowRunStatusEnded: return "workflow_run.status_ended"
        case .workflowRunError: return "workflow_run.error"
        case .workflowRunPhaseStarted: return "workflow_run.phase_started"
        case .workflowRunPhaseEnded: return "workflow_run.phase_ended"
        case .unknown(let value): return value
        }
    }
}
