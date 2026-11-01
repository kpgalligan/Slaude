// Transformed from `anthropic.types.tool_param` (tool_param.py).

import Foundation

public struct ToolParam: Codable, Hashable, Sendable {
    /// [JSON schema](https://json-schema.org/draft/2020-12) for this tool's input.
    ///
    /// This defines the shape of the `input` that your tool accepts and that the model
    /// will produce.
    public var inputSchema: ToolParam.InputSchema
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var allowedCallers: [AllowedCallers]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// Description of what this tool does.
    ///
    /// Tool descriptions should be as detailed as possible. The more information that
    /// the model has about what the tool is and how to use it, the better it will
    /// perform. You can use natural language descriptions to reinforce important
    /// aspects of the tool input JSON schema.
    public var description: String?
    /// Enable eager input streaming for this tool.
    ///
    /// When true, tool input parameters will be streamed incrementally as they are
    /// generated, and types will be inferred on-the-fly rather than buffering the full
    /// JSON output. When false, streaming is disabled for this tool even if the
    /// fine-grained-tool-streaming beta is active. When null (default), uses the
    /// default behavior based on beta headers.
    public var eagerInputStreaming: Bool??
    public var inputExamples: [[String: JSONValue]]?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?
    public var type: String??

    public init(inputSchema: ToolParam.InputSchema, name: String, allowedCallers: [AllowedCallers]? = nil, cacheControl: CacheControlEphemeralParam?? = nil, deferLoading: Bool? = nil, description: String? = nil, eagerInputStreaming: Bool?? = nil, inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil, type: String?? = nil) {
        self.inputSchema = inputSchema
        self.name = name
        self.allowedCallers = allowedCallers
        self.cacheControl = cacheControl
        self.deferLoading = deferLoading
        self.description = description
        self.eagerInputStreaming = eagerInputStreaming
        self.inputExamples = inputExamples
        self.strict = strict
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case inputSchema = "input_schema"
        case name
        case allowedCallers = "allowed_callers"
        case cacheControl = "cache_control"
        case deferLoading = "defer_loading"
        case description
        case eagerInputStreaming = "eager_input_streaming"
        case inputExamples = "input_examples"
        case strict
        case type
    }

    public enum AllowedCallers: OpenEnum, CaseIterable {
        case direct
        case codeExecution20250825
        case codeExecution20260120
        case codeExecution20260521
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [AllowedCallers] = [.direct, .codeExecution20250825, .codeExecution20260120, .codeExecution20260521]

        public init(rawValue: String) {
            switch rawValue {
            case "direct": self = .direct
            case "code_execution_20250825": self = .codeExecution20250825
            case "code_execution_20260120": self = .codeExecution20260120
            case "code_execution_20260521": self = .codeExecution20260521
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .direct: return "direct"
            case .codeExecution20250825: return "code_execution_20250825"
            case .codeExecution20260120: return "code_execution_20260120"
            case .codeExecution20260521: return "code_execution_20260521"
            case .unknown(let value): return value
            }
        }
    }
}

extension ToolParam {

    /// [JSON schema](https://json-schema.org/draft/2020-12) for this tool's input.
    ///
    /// This defines the shape of the `input` that your tool accepts and that the model will produce.
    public struct InputSchemaTyped: Codable, Hashable, Sendable {
        public var type: String
        public var properties: [String: JSONValue]??
        public var required: [String]??

        public init(type: String = "object", properties: [String: JSONValue]?? = nil, required: [String]?? = nil) {
            self.type = type
            self.properties = properties
            self.required = required
        }

        enum CodingKeys: String, CodingKey {
            case type
            case properties
            case required
        }
    }

    public indirect enum InputSchema: Codable, Hashable, Sendable {
        case inputSchemaTyped(ToolParam.InputSchemaTyped)
        case dictionary([String: JSONValue])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if let v = try? ToolParam.InputSchemaTyped(from: decoder) { self = .inputSchemaTyped(v); return }
            if let v = try? [String: JSONValue](from: decoder) { self = .dictionary(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .inputSchemaTyped(let v): try v.encode(to: encoder)
            case .dictionary(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
