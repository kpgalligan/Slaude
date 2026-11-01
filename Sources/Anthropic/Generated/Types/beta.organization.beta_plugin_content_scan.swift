// Transformed from `anthropic.types.beta.organization.beta_plugin_content_scan` (beta_plugin_content_scan.py).

import Foundation

public struct BetaPluginContentScan: Codable, Hashable, Sendable {
    /// The scan's verdict; set only when `status` is `completed`.
    ///
    /// A `warn` can mean a `fail` that was allowed in claude.ai.
    public var assessment: Assessment?
    /// The primary mechanism behind a `warn` or `fail`, such as `credential-exposure`
    /// or `guardrail-tampering`; a mechanism this API does not yet name reads as
    /// `other`. Null on a `pass`, whenever `assessment` is null, and when no mechanism
    /// is reported for the verdict.
    public var reason: String?
    /// `processing` while a scan runs, `completed` when it ran to completion, `errored`
    /// when it could not run. Once a scan of the version has completed, `content_scan`
    /// describes the newest completed scan, even while a later scan runs. While the
    /// scan outcome cannot be read, `status` is `errored` instead.
    public var status: Status

    public init(assessment: Assessment? = nil, reason: String? = nil, status: Status) {
        self.assessment = assessment
        self.reason = reason
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case assessment
        case reason
        case status
    }

    public enum Assessment: OpenEnum, CaseIterable {
        case fail
        case pass
        case unknown_
        case warn
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Assessment] = [.fail, .pass, .unknown_, .warn]

        public init(rawValue: String) {
            switch rawValue {
            case "fail": self = .fail
            case "pass": self = .pass
            case "unknown": self = .unknown_
            case "warn": self = .warn
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .fail: return "fail"
            case .pass: return "pass"
            case .unknown_: return "unknown"
            case .warn: return "warn"
            case .unknown(let value): return value
            }
        }
    }

    public enum Status: OpenEnum, CaseIterable {
        case completed
        case errored
        case processing
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.completed, .errored, .processing]

        public init(rawValue: String) {
            switch rawValue {
            case "completed": self = .completed
            case "errored": self = .errored
            case "processing": self = .processing
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .completed: return "completed"
            case .errored: return "errored"
            case .processing: return "processing"
            case .unknown(let value): return value
            }
        }
    }
}
