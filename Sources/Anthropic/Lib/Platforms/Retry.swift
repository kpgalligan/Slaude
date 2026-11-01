import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Port of `lib/_retry.py`: backoff / jitter / retry classification shared by the runner helpers
/// (the environment poller, the session tool runner, the worker heartbeat).
public enum HelperRetry {
    /// 4xx codes still worth retrying (request timeout, conflict, rate limit), matching the core
    /// client's retry policy.
    static let retryable4xx: Set<Int> = [408, 409, 429]

    /// Exponential backoff for `attempt` (1-indexed), capped at `cap`.
    public static func backoff(attempt: Int, cap: Double, base: Double = 2.0) -> Double {
        min(cap, pow(base, Double(attempt)))
    }

    /// A uniform random delay in `[low, high)`.
    public static func jitter(_ low: Double, _ high: Double) -> Double {
        low < high ? Double.random(in: low..<high) : low
    }

    /// Whether a retry loop should swallow and retry `error`: transport failures and SDK API errors
    /// (`TRANSIENT_ERRORS`). Anything else is a real bug and must propagate.
    public static func isTransient(_ error: Error) -> Bool {
        error is APIError || error is URLError || error is TransportTimeoutError
    }

    /// True for a 4xx that retrying will not fix (bad key, missing resource).
    public static func isFatalStatusError(_ error: Error) -> Bool {
        guard let e = error as? APIStatusError else { return false }
        return (400..<500).contains(e.statusCode) && !retryable4xx.contains(e.statusCode)
    }
}
