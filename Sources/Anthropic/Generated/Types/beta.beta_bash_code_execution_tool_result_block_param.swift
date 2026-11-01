// Transformed from `anthropic.types.beta.beta_bash_code_execution_tool_result_block_param` (beta_bash_code_execution_tool_result_block_param.py).

import Foundation

public struct BetaBashCodeExecutionToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BetaBashCodeExecutionToolResultBlockParam.Content
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(content: BetaBashCodeExecutionToolResultBlockParam.Content, toolUseID: String, type: String = "bash_code_execution_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
        case cacheControl = "cache_control"
    }
}

extension BetaBashCodeExecutionToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case bashCodeExecutionToolResultError(BetaBashCodeExecutionToolResultErrorParam)
        case bashCodeExecutionResult(BetaBashCodeExecutionResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "bash_code_execution_tool_result_error": self = .bashCodeExecutionToolResultError(try BetaBashCodeExecutionToolResultErrorParam(from: decoder))
            case "bash_code_execution_result": self = .bashCodeExecutionResult(try BetaBashCodeExecutionResultBlockParam(from: decoder))
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
