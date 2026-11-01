// Transformed from `anthropic.types.web_fetch_tool_result_block_param` (web_fetch_tool_result_block_param.py).

import Foundation

public struct WebFetchToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: WebFetchToolResultBlockParam.Content
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var caller: WebFetchToolResultBlockParam.Caller?

    public init(content: WebFetchToolResultBlockParam.Content, toolUseID: String, type: String = "web_fetch_tool_result", cacheControl: CacheControlEphemeralParam?? = nil, caller: WebFetchToolResultBlockParam.Caller? = nil) {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
        self.cacheControl = cacheControl
        self.caller = caller
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
        case cacheControl = "cache_control"
        case caller
    }
}

extension WebFetchToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case webFetchToolResultError(WebFetchToolResultErrorBlockParam)
        case webFetchResult(WebFetchBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "web_fetch_tool_result_error": self = .webFetchToolResultError(try WebFetchToolResultErrorBlockParam(from: decoder))
            case "web_fetch_result": self = .webFetchResult(try WebFetchBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .webFetchToolResultError(let v): try v.encode(to: encoder)
            case .webFetchResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum Caller: Codable, Hashable, Sendable {
        case direct(DirectCallerParam)
        case codeExecution20250825(ServerToolCallerParam)
        case codeExecution20260120(ServerToolCaller20260120Param)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "direct": self = .direct(try DirectCallerParam(from: decoder))
            case "code_execution_20250825": self = .codeExecution20250825(try ServerToolCallerParam(from: decoder))
            case "code_execution_20260120": self = .codeExecution20260120(try ServerToolCaller20260120Param(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .direct(let v): try v.encode(to: encoder)
            case .codeExecution20250825(let v): try v.encode(to: encoder)
            case .codeExecution20260120(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
