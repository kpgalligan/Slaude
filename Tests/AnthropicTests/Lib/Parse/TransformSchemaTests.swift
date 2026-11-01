import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/_parse/test_transform.py. Leftover keywords are listed in sorted order in the
// description (`JSONValue` objects are unordered; Python keeps insertion order).

@Suite struct TransformSchemaTests {
    @Test func refSchema() throws {
        #expect(try transformSchema(["$ref": "#/components/schemas/SomeSchema"]) == ["$ref": "#/components/schemas/SomeSchema"])
    }

    @Test func refSchemaWithDefs() throws {
        let schema: JSONValue = [
            "$ref": "#/$defs/Tier",
            "$defs": ["Tier": ["type": "string", "enum": ["free", "pro", "enterprise"], "title": "Tier"]],
        ]
        #expect(try transformSchema(schema) == [
            "$defs": ["Tier": ["type": "string", "enum": ["free", "pro", "enterprise"], "title": "Tier"]],
            "$ref": "#/$defs/Tier",
        ])
    }

    @Test func anyOfSchema() throws {
        let schema: JSONValue = ["anyOf": [["type": "string"], ["type": "integer", "minimum": 1]]]
        #expect(try transformSchema(schema) == ["anyOf": [["type": "string"], ["type": "integer", "description": "{minimum: 1}"]]])
    }

    @Test func enumSchema() throws {
        #expect(try transformSchema(["type": "string", "enum": ["foo", "bar"]]) == ["type": "string", "enum": ["foo", "bar"]])
    }

    @Test func allOf() throws {
        let schema: JSONValue = [
            "allOf": [
                ["type": "object", "properties": ["name": ["type": "string"]]],
                ["type": "object", "properties": ["age": ["type": "integer", "minimum": 0]]],
            ],
        ]
        #expect(try transformSchema(schema) == [
            "allOf": [
                ["type": "object", "properties": ["name": ["type": "string"]], "additionalProperties": false],
                ["type": "object", "properties": ["age": ["type": "integer", "description": "{minimum: 0}"]], "additionalProperties": false],
            ],
        ])
    }

    @Test func objectSchema() throws {
        let schema: JSONValue = [
            "type": "object",
            "properties": ["name": ["type": "string", "default": "John"], "age": ["type": "integer", "minimum": 0]],
            "required": ["name"], "description": "Person object",
        ]
        #expect(try transformSchema(schema) == [
            "type": "object", "description": "Person object",
            "properties": ["name": ["type": "string", "description": "{default: John}"], "age": ["type": "integer", "description": "{minimum: 0}"]],
            "additionalProperties": false, "required": ["name"],
        ])
    }

    @Test func arraySchema() throws {
        let schema: JSONValue = ["type": "array", "items": ["type": "string"], "minItems": 2, "description": "A list of strings"]
        #expect(try transformSchema(schema) == ["type": "array", "description": "A list of strings\n\n{minItems: 2}", "items": ["type": "string"]])
    }

    @Test func arraySchemaKeepsMinItemsZeroOrOne() throws {
        #expect(try transformSchema(["type": "array", "minItems": 1]) == ["type": "array", "minItems": 1])
    }

    @Test func stringSchemaWithFormatAndDefault() throws {
        let schema: JSONValue = ["type": "string", "format": "email", "default": "user@example.com", "description": "User email"]
        #expect(try transformSchema(schema) == ["type": "string", "description": "User email\n\n{default: user@example.com}", "format": "email"])
    }

    @Test func stringSchemaWithUnsupportedFormat() throws {
        #expect(try transformSchema(["type": "string", "format": "binary"]) == ["type": "string", "description": "{format: binary}"])
    }

    @Test func stringSchemaWithoutFormat() throws {
        #expect(try transformSchema(["type": "string"]) == ["type": "string"])
    }

    @Test func integerSchemaWithMinMaxExclusive() throws {
        let schema: JSONValue = [
            "type": "integer", "minimum": 1, "maximum": 10, "exclusiveMinimum": 0, "exclusiveMaximum": 20, "description": "A number",
        ]
        #expect(try transformSchema(schema) == [
            "type": "integer",
            "description": "A number\n\n{exclusiveMaximum: 20, exclusiveMinimum: 0, maximum: 10, minimum: 1}",
        ])
    }

    @Test func booleanSchema() throws {
        #expect(try transformSchema(["type": "boolean", "description": "A flag"]) == ["type": "boolean", "description": "A flag"])
    }

    @Test func nullSchema() throws {
        #expect(try transformSchema(["type": "null"]) == ["type": "null"])
    }

    @Test func unsupportedTypeThrows() {
        #expect(throws: ValueError.self) { try transformSchema(["type": "unsupported"]) }
    }

    @Test func schemaWithoutTypeThrows() {
        #expect(throws: ValueError.self) { try transformSchema(["description": "x"]) }
    }

    @Test func originalSchemaNotMutated() throws {
        // `JSONValue` is a value type: the input cannot be mutated.
        let original: JSONValue = [
            "type": "object", "properties": ["name": ["type": "string", "default": "John"]], "additionalProperties": true,
        ]
        let backup = original
        _ = try transformSchema(original)
        #expect(original == backup)
    }
}
