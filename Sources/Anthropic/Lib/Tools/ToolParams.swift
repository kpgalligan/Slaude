// Port of `anthropic/lib/tools/_tool_params.py`: serializing SDK tool objects into `tools[]` entries.

import Foundation

/// A `tools[]` entry, or an object that serializes to one (`BetaToolLike`).
///
/// Function tools, builtin tools and toolsets conform, as do the raw definitions: the generated
/// `BetaToolUnionParam` / `BetaToolParam` params, and a `JSONValue` object for a definition written by hand.
public protocol BetaToolLike: Sendable {
    /// The `tools[]` entry to send for this tool (`to_dict()`).
    func toToolParam() throws -> JSONValue
    /// The helper telemetry tag the requests that send this tool carry, if any.
    var helperTag: String? { get }
}

extension BetaToolLike {
    public var helperTag: String? { nil }
}

extension BetaToolUnionParam: BetaToolLike {
    public func toToolParam() throws -> JSONValue { try JSONValue.from(self) }
}

extension BetaToolParam: BetaToolLike {
    public func toToolParam() throws -> JSONValue { try JSONValue.from(self) }
}

extension JSONValue: BetaToolLike {
    public func toToolParam() throws -> JSONValue { self }
}

/// Replaces every tool object in `tools` with its `tools[]` entry, keeping order (`to_tool_params`).
public func toToolParams(_ tools: [any BetaToolLike]?) throws -> [JSONValue]? {
    guard let tools else { return nil }
    return try tools.map { try $0.toToolParam() }
}

/// Whether `tool` is a raw definition rather than an object the runner runs.
func isRawDefinition(_ tool: any BetaToolLike) -> Bool {
    !(tool is any BetaRunnableTool) && !(tool is BetaRunnableToolset)
}
