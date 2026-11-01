import Foundation

/// A type the model's reply can be parsed into (the Swift counterpart of passing a pydantic model
/// as `output_format=` to `messages.parse` / `messages.stream`).
///
/// Python derives the JSON schema from the type with `pydantic.TypeAdapter`; Swift has no runtime
/// reflection for that, so the type supplies its schema. The SDK runs it through `transformSchema`
/// (making it acceptable to the structured-outputs API) before sending it as
/// `output_config.format`, and decodes the reply text with the SDK's JSON decoder.
///
/// ```swift
/// struct OrderItem: StructuredOutput {
///     var productName: String
///     var price: Double
///     var quantity: Int
///     enum CodingKeys: String, CodingKey { case productName = "product_name", price, quantity }
///     static let jsonSchema: JSONValue = [
///         "type": "object",
///         "properties": [
///             "product_name": ["type": "string"], "price": ["type": "number"], "quantity": ["type": "integer"],
///         ],
///         "required": ["product_name", "price", "quantity"],
///     ]
/// }
/// let message = try await client.messages.parse(maxTokens: 1024, messages: messages, model: model, outputFormat: OrderItem.self)
/// message.parsedOutput?.productName
/// ```
public protocol StructuredOutput: Decodable, Sendable {
    /// The JSON schema replies must match (before `transformSchema` is applied).
    static var jsonSchema: JSONValue { get }
}

/// Port of `lib/_parse/_response.parse_text`: decodes a reply into the output type.
public func parseStructuredOutput<Output: Decodable>(_ text: String, as type: Output.Type) throws -> Output {
    try AnthropicJSON.decoder().decode(Output.self, from: Data(text.utf8))
}

/// The `output_config.format` param that asks for replies matching `Output`'s JSON schema
/// (`lib/_parse/_transform.to_json_output_format`).
public func jsonOutputFormat<Output: StructuredOutput>(_ type: Output.Type) throws -> [String: JSONValue] {
    guard case .object(let schema) = try transformSchema(Output.jsonSchema) else {
        throw ArgumentTypeError("The JSON schema of `\(Output.self)` must be an object")
    }
    return schema
}

/// Rejects a call that passes both `outputFormat` and `outputConfig.format`
/// (`lib/_parse/_transform.validate_output_config_conflict`).
func validateOutputConfigConflict(_ outputConfig: BetaOutputConfigParam?, hasOutputFormat: Bool) throws {
    if hasOutputFormat, let outputConfig, case .some(.some) = outputConfig.format {
        throw AnthropicError(
            "Both output_format and output_config.format were provided. Please use only output_config.format (output_format is deprecated).")
    }
}

// MARK: - transform_schema

let supportedStringFormats: Set<String> = [
    "date-time", "time", "date", "duration", "email", "hostname", "uri", "ipv4", "ipv6", "uuid",
]

/// Transforms a JSON schema to ensure it conforms to the API's expectations
/// (`lib/_parse/_transform.transform_schema`).
///
/// Unsupported keywords are dropped from the schema and appended to its `description` instead, so
/// that the model *might* still follow them:
///
/// ```swift
/// try transformSchema(["type": "integer", "minimum": 1, "maximum": 10, "description": "A number"])
/// // ["type": "integer", "description": "A number\n\n{maximum: 10, minimum: 1}"]
/// ```
///
/// `JSONValue` objects are unordered, so leftover keywords are listed in sorted order (Python lists
/// them in the schema's insertion order).
public func transformSchema(_ jsonSchema: JSONValue) throws -> JSONValue {
    guard case .object(var schema) = jsonSchema else {
        throw ValueError("Schema must be a JSON object.")
    }
    var strict: [String: JSONValue] = [:]

    // $defs must be processed before the $ref early-return below, so that a root-level
    // `{"$ref": "#/$defs/X", "$defs": {...}}` keeps its definitions.
    if let defs = schema.removeValue(forKey: "$defs"), !defs.isNull {
        var strictDefs: [String: JSONValue] = [:]
        for (name, def) in defs.objectValue ?? [:] { strictDefs[name] = try transformSchema(def) }
        strict["$defs"] = .object(strictDefs)
    }

    if let ref = schema.removeValue(forKey: "$ref"), !ref.isNull {
        strict["$ref"] = ref
        return .object(strict)
    }

    let type = schema.removeValue(forKey: "type").flatMap { $0.isNull ? nil : $0 }
    let anyOf = schema.removeValue(forKey: "anyOf")
    let oneOf = schema.removeValue(forKey: "oneOf")
    let allOf = schema.removeValue(forKey: "allOf")

    if let variants = anyOf?.arrayValue {
        strict["anyOf"] = .array(try variants.map(transformSchema))
    } else if let variants = oneOf?.arrayValue {
        strict["anyOf"] = .array(try variants.map(transformSchema))
    } else if let variants = allOf?.arrayValue {
        strict["allOf"] = .array(try variants.map(transformSchema))
    } else {
        guard let type else { throw ValueError("Schema must have a 'type', 'anyOf', 'oneOf', or 'allOf' field.") }
        strict["type"] = type
    }

    if let e = schema.removeValue(forKey: "enum"), e.arrayValue != nil { strict["enum"] = e }
    if let d = schema.removeValue(forKey: "description"), !d.isNull { strict["description"] = d }
    if let t = schema.removeValue(forKey: "title"), !t.isNull { strict["title"] = t }

    switch type?.stringValue {
    case "object"?:
        var properties: [String: JSONValue] = [:]
        for (key, prop) in schema.removeValue(forKey: "properties")?.objectValue ?? [:] {
            properties[key] = try transformSchema(prop)
        }
        strict["properties"] = .object(properties)
        schema.removeValue(forKey: "additionalProperties")
        strict["additionalProperties"] = false
        if let required = schema.removeValue(forKey: "required"), !required.isNull { strict["required"] = required }
    case "string"?:
        if let format = schema.removeValue(forKey: "format"), !format.isNull {
            if let f = format.stringValue, supportedStringFormats.contains(f) {
                strict["format"] = format
            } else if format != .string("") && format != .bool(false) {
                // put it back so it is treated as an extra property and appended to the description
                schema["format"] = format
            }
        }
    case "array"?:
        if let items = schema.removeValue(forKey: "items"), !items.isNull { strict["items"] = try transformSchema(items) }
        if let minItems = schema.removeValue(forKey: "minItems"), !minItems.isNull {
            if minItems.intValue == 0 || minItems.intValue == 1 {
                strict["minItems"] = minItems
            } else {
                schema["minItems"] = minItems
            }
        }
    case "boolean"?, "integer"?, "number"?, "null"?, nil:
        break
    default:
        throw ValueError("Unsupported schema type: \(type.map { pythonStr($0) } ?? "None")")
    }

    // Any keywords left over aren't supported, so they go into the description.
    if !schema.isEmpty {
        let extras = "{" + schema.sorted(by: { $0.key < $1.key }).map { "\($0.key): \(pythonStr($0.value))" }.joined(separator: ", ") + "}"
        if let description = strict["description"]?.stringValue {
            strict["description"] = .string(description + "\n\n" + extras)
        } else {
            strict["description"] = .string(extras)
        }
    }
    return .object(strict)
}

/// Python's `str(value)` for a JSON value: strings render bare, everything else as its `repr`.
func pythonStr(_ value: JSONValue) -> String {
    if case .string(let s) = value { return s }
    return pythonRepr(value)
}
