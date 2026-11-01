// Transformed from `anthropic.types.beta.beta_json_output_format_param` (beta_json_output_format_param.py).

import Foundation

public struct BetaJSONOutputFormatParam: Codable, Hashable, Sendable {
    /// The JSON schema of the format
    public var schema: [String: JSONValue]
    public var type: String

    public init(schema: [String: JSONValue], type: String = "json_schema") {
        self.schema = schema
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case schema
        case type
    }
}
