// Transformed from `anthropic.types.bash_code_execution_tool_result_block_param` (bash_code_execution_tool_result_block_param.py).

import Foundation

public struct BashCodeExecutionToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BashCodeExecutionToolResultBlockParam.Content
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??

    public init(content: BashCodeExecutionToolResultBlockParam.Content, toolUseId: String, type: String = "bash_code_execution_tool_result", cacheControl: CacheControlEphemeralParam?? = nil) {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
        case cacheControl = "cache_control"
    }
}

extension BashCodeExecutionToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case bashCodeExecutionToolResultError(BashCodeExecutionToolResultErrorParam)
        case bashCodeExecutionResult(BashCodeExecutionResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "bash_code_execution_tool_result_error": self = .bashCodeExecutionToolResultError(try BashCodeExecutionToolResultErrorParam(from: decoder))
            case "bash_code_execution_result": self = .bashCodeExecutionResult(try BashCodeExecutionResultBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .bashCodeExecutionToolResultError(let v): try v.encode(to: encoder)
            case .bashCodeExecutionResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
