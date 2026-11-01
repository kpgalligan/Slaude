// Port of `anthropic/lib/tools/_toolsets/_errors.py`.
//
// `ToolsetUsageError` is the only error type the tool runner lets propagate out of a member call: your code used
// the SDK's own interface incorrectly, so the run stops. Every other error a member raises is reported to the model
// as an `is_error` result. The refusals are `ToolError` subclasses, each with the SDK's own text.

import Foundation

/// Your code used a toolset's interface incorrectly.
open class ToolsetUsageError: AnthropicError, @unchecked Sendable {}

/// A construction-time mistake: an option combination the toolset cannot honour (a `ValueError` upstream).
open class ToolsetConfigError: ToolsetUsageError, @unchecked Sendable {}

/// Misuse of the SDK's own interface detected at call time (a `TypeError` upstream).
open class ToolsetContractError: ToolsetUsageError, @unchecked Sendable {}

/// `addTools()` / `removeTools()` was given a toolset, a raw definition of one of the runner's toolsets, or (in
/// `removeTools()`) the name of one. A runner's toolsets are fixed when it is created.
open class ToolsetsFixedError: ToolsetContractError, @unchecked Sendable {
    public enum Action: String, Sendable { case add, replace, remove }

    public init(_ action: Action, _ toolsetName: String) {
        let method = action == .remove ? "remove_tools" : "add_tools"
        let instead = action == .remove ? "build a new runner without it" : "build a new runner to use a different toolset"
        super.init(
            "\(method)() can't \(action.rawValue) the '\(quotedName(toolsetName))' toolset: a tool runner's toolsets are fixed "
                + "when it is created; \(instead)")
    }
}

/// A member call on a toolset you already closed.
open class ToolsetClosedError: ToolsetUsageError, @unchecked Sendable {}

/// The refusal the model reads for a member name the toolset does not have.
open class UnknownMemberError: ToolError, @unchecked Sendable {
    public init(_ name: String, family: String) {
        super.init(.string("Error: unknown \(family) toolset member '\(quotedName(name))'"))
    }
}

/// The refusal the model reads for a member your application's `configs` disabled.
open class DisabledMemberError: ToolError, @unchecked Sendable {
    public init(_ name: String) {
        super.init(.string(
            "The '\(name)' action is not permitted by this application's permissions and cannot be used in this session."))
    }
}

/// The refusal the model reads for a member the driver does not implement.
open class UnavailableMemberError: ToolError, @unchecked Sendable {
    public init(_ name: String, family: String) {
        super.init(.string("The \(family) toolset member '\(name)' is not available in this environment."))
    }
}

/// The refusal the model reads when its `tool_use.input` does not fit the member.
open class InvalidMemberInputError: ToolError, @unchecked Sendable {
    public init(_ name: String, _ problem: String, family: String) {
        super.init(.string("invalid input for \(family) member '\(name)': \(problem)"))
    }
}

/// The refusal the model reads when your `urlPolicy` raised something other than a `ToolError`.
open class URLRefusedError: ToolError, @unchecked Sendable {
    public init(_ reason: String) { super.init(.string(logSafe(reason))) }
}

/// Not raised by the SDK; kept for code that refers to it.
open class TabMissingError: ToolError, @unchecked Sendable {
    public init() {
        super.init(.string(
            "The tab this call was addressed to is not open; nothing was returned. Use list_tabs to see what is open."))
    }
}

/// The refusal the model reads when your `confirm` callable answered `false` for the member `name`.
open class ConfirmDeclinedError: ToolError, @unchecked Sendable {
    public init(_ name: String) {
        super.init(.string("The user did not grant permission to run '\(name)'. Do not retry it unless the user asks you to."))
    }
}

/// The refusal the model reads when your `confirm` callable raised.
open class ConfirmFailedError: ToolError, @unchecked Sendable {
    public init(_ name: String) {
        super.init(.string(
            "Permission to run '\(name)' could not be obtained (the confirmation prompt failed). "
                + "Do not retry it unless the user asks you to."))
    }
}

/// The refusal the model reads for a `file_upload` the file policy, or its absence, does not admit.
open class UploadRefusedError: ToolError, @unchecked Sendable {
    public init(_ reason: String) { super.init(.string(reason)) }
}

open class UploadNoRootsError: UploadRefusedError, @unchecked Sendable {
    public init() { super.init("file_upload has no configured upload roots") }
}

open class UploadOutsideRootsError: UploadRefusedError, @unchecked Sendable {
    public init() { super.init("file_upload path is outside the configured upload roots") }
}
