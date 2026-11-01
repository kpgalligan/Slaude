// Transformed from `anthropic.types.beta.beta_response_tool_input_schema` (beta_response_tool_input_schema.py).

import Foundation

/// [JSON schema](https://json-schema.org/draft/2020-12) for this tool's input.
///
/// This defines the shape of the `input` that your tool accepts and that the model will produce.
public struct BetaResponseToolInputSchema: Codable, Hashable, Sendable {
    public var type: String
    public var properties: [String: JSONValue]?
    public var required: [String]?

    public init(type: String = "object", properties: [String: JSONValue]? = nil, required: [String]? = nil) {
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
