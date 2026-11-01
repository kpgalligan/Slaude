// Transformed from `anthropic.types.beta.beta_web_fetch_url_sources` (beta_web_fetch_url_sources.py).

import Foundation

/// Which sources contribute to the set of URLs web fetch may fetch.
///
/// Each key is a tagged variant: ``user_input`` is ``all`` or ``none``; the
/// two tool filters are ``all``, ``none``, ``only`` (only the named tools'
/// results) or ``except`` (every result but the named tools'). A named tool
/// must be declared in this request's ``tools[]``.
public struct BetaWebFetchURLSources: Codable, Hashable, Sendable {
    /// Which client tools' results contribute fetchable URLs: "all", "none", or an only
    /// or except list of client tool names from tools[].
    public var clientToolResults: BetaWebFetchURLSources.ClientToolResults?
    /// Which server tools' results contribute fetchable URLs: "all", "none", or an only
    /// or except list of server tool names from tools[]; only web_search and web_fetch
    /// results ever contribute.
    public var serverToolResults: BetaWebFetchURLSources.ServerToolResults?
    /// Whether URLs in user messages are fetchable: "all" or "none".
    public var userInput: BetaWebFetchURLSources.UserInput?

    public init(clientToolResults: BetaWebFetchURLSources.ClientToolResults? = nil, serverToolResults: BetaWebFetchURLSources.ServerToolResults? = nil, userInput: BetaWebFetchURLSources.UserInput? = nil) {
        self.clientToolResults = clientToolResults
        self.serverToolResults = serverToolResults
        self.userInput = userInput
    }

    enum CodingKeys: String, CodingKey {
        case clientToolResults = "client_tool_results"
        case serverToolResults = "server_tool_results"
        case userInput = "user_input"
    }
}

extension BetaWebFetchURLSources {

    public indirect enum ClientToolResults: Codable, Hashable, Sendable {
        case all(BetaWebFetchURLSourceAll)
        case none(BetaWebFetchURLSourceNone)
        case only(BetaWebFetchURLSourceOnly)
        case except(BetaWebFetchURLSourceExcept)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "all": self = .all(try BetaWebFetchURLSourceAll(from: decoder))
            case "none": self = .none(try BetaWebFetchURLSourceNone(from: decoder))
            case "only": self = .only(try BetaWebFetchURLSourceOnly(from: decoder))
            case "except": self = .except(try BetaWebFetchURLSourceExcept(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .all(let v): try v.encode(to: encoder)
            case .none(let v): try v.encode(to: encoder)
            case .only(let v): try v.encode(to: encoder)
            case .except(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum ServerToolResults: Codable, Hashable, Sendable {
        case all(BetaWebFetchURLSourceAll)
        case none(BetaWebFetchURLSourceNone)
        case only(BetaWebFetchURLSourceOnly)
        case except(BetaWebFetchURLSourceExcept)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "all": self = .all(try BetaWebFetchURLSourceAll(from: decoder))
            case "none": self = .none(try BetaWebFetchURLSourceNone(from: decoder))
            case "only": self = .only(try BetaWebFetchURLSourceOnly(from: decoder))
            case "except": self = .except(try BetaWebFetchURLSourceExcept(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .all(let v): try v.encode(to: encoder)
            case .none(let v): try v.encode(to: encoder)
            case .only(let v): try v.encode(to: encoder)
            case .except(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum UserInput: Codable, Hashable, Sendable {
        case all(BetaWebFetchURLSourceAll)
        case none(BetaWebFetchURLSourceNone)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "all": self = .all(try BetaWebFetchURLSourceAll(from: decoder))
            case "none": self = .none(try BetaWebFetchURLSourceNone(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .all(let v): try v.encode(to: encoder)
            case .none(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
