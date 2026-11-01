// Transformed from `anthropic.types.input_json_delta` (input_json_delta.py).

import Foundation

public struct InputJSONDelta: Codable, Hashable, Sendable {
    public var partialJson: String
    public var type: String

    public init(partialJson: String, type: String = "input_json_delta") {
        self.partialJson = partialJson
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case partialJson = "partial_json"
        case type
    }
}

extension InputJSONDelta {

    public typealias InputJsonDelta = InputJSONDelta
}
