import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Port of `anthropic/lib/credentials/_cache.py`.

/// Skip advisory refreshes for this many seconds after a failure, so a token-endpoint outage
/// isn't hammered at request rate.
let ADVISORY_REFRESH_BACKOFF_SECONDS: Double = 5

/// A one-shot event that tasks can wait on (`anyio.Event`).
final class AsyncEvent: @unchecked Sendable {
    private let lock = NSLock()
    private var isSet = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func set() {
        let pending: [CheckedContinuation<Void, Never>] = lock.withLock {
            isSet = true
            defer { waiters = [] }
            return waiters
        }
        for w in pending { w.resume() }
    }

    func wait() async {
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            let resumeNow: Bool = lock.withLock {
                if isSet { return true }
                waiters.append(c)
                return false
            }
            if resumeNow { c.resume() }
        }
    }
}

/// Caches the token of an `AccessTokenProvider` with two-tier proactive refresh and
/// single-flight semantics (`TokenCache`).
///
/// Refresh policy on each `getToken()` call:
///
/// * No cached token → call the provider, cache, return.
/// * Cached with `expiresAt == nil` → return cached forever (never refresh).
/// * More than `advisoryRefreshSeconds` remaining → return cached.
/// * Between `mandatoryRefreshSeconds` and `advisoryRefreshSeconds` remaining (advisory window) →
///   try the provider; on success swap the cache; on failure log a warning and return the stale
///   cached token. If another caller is already refreshing, the advisory caller just returns the
///   cached token — no second refresh, no waiting.
/// * Less than `mandatoryRefreshSeconds` remaining or already expired (mandatory window) → call the
///   provider; on failure throw. Concurrent mandatory callers wait on a shared event so exactly one
///   provider call is in flight.
/// * Cached with `expiresAt == 0` → never served. The provider does its own caching, so every call
///   asks it again, concurrently for concurrent callers. After a 401 empties the cache, one caller
///   makes the `forceRefresh: true` call and callers that arrive after the 401 wait for it.
///
/// The lock is released before the provider call, so a slow token exchange doesn't serialize
/// unrelated callers.
public final class TokenCache: @unchecked Sendable {
    public let provider: any AccessTokenProvider
    let advisory: Double
    let mandatory: Double
    let timeSource: @Sendable () -> Double

    private let lock = NSLock()
    private var cached: AccessToken?
    /// Set while a single-flight refresh is in flight; mandatory-window callers wait on it.
    private var refreshEvent: AsyncEvent?
    /// One-shot: `invalidate()` sets it; the next single-flight leader passes `forceRefresh: true`.
    private var nextForce = false
    /// Time of the last advisory-refresh failure.
    private var lastAdvisoryFailureTime: Double = 0

    public init(_ provider: any AccessTokenProvider, advisoryRefreshSeconds: Int = ADVISORY_REFRESH_SECONDS,
                mandatoryRefreshSeconds: Int = MANDATORY_REFRESH_SECONDS,
                timeSource: @escaping @Sendable () -> Double = { Date().timeIntervalSince1970 })
    {
        self.provider = provider
        self.advisory = Double(advisoryRefreshSeconds)
        self.mandatory = Double(mandatoryRefreshSeconds)
        self.timeSource = timeSource
    }

    struct Refresh {
        /// The single-flight event this caller created and must release; `nil` for a per-request
        /// caller (cached `expiresAt == 0`), because nobody waits for it.
        let ownedEvent: AsyncEvent?
        /// Whether to pass `forceRefresh: true`. Only the single-flight leader ever forces.
        let force: Bool
        /// The cached token to serve if this is an advisory refresh and it fails.
        let advisoryFallback: AccessToken?
        let remainingSeconds: Int
    }

    enum Step {
        case token(String)
        case wait(AsyncEvent)
        case refresh(Refresh)
    }

    /// Calls the provider, retrying once (forced) on a 401 from the token endpoint.
    func callProvider(force: Bool) async throws -> AccessToken {
        do {
            return try await provider(forceRefresh: force)
        } catch let err as WorkloadIdentityError where err.statusCode == 401 {
            CredentialsLog.debug("Token provider returned 401; retrying once")
            return try await provider(forceRefresh: true)
        }
    }

    /// Returns a valid bearer token, refreshing if necessary (`async_get_token`).
    public func getToken() async throws -> String {
        while true {
            switch nextStep() {
            case .token(let t):
                return t
            case .wait(let event):
                // Re-read the cache afterwards: the refresh may have succeeded, failed, or been
                // invalidated in between.
                await event.wait()
                continue
            case .refresh(let step):
                let fresh: AccessToken
                do {
                    fresh = try await callProvider(force: step.force)
                } catch {
                    if let stale = endFailedRefresh(error, step) { return stale }
                    throw error
                }
                return endRefresh(fresh, step)
            }
        }
    }

    func nextStep() -> Step {
        lock.withLock {
            var advisoryFallback: AccessToken? = nil
            var remainingSeconds = 0
            if let cached {
                guard let expiresAt = cached.expiresAt else { return .token(cached.token) }
                if expiresAt == 0 {
                    return .refresh(Refresh(ownedEvent: nil, force: false, advisoryFallback: nil, remainingSeconds: 0))
                }
                let remaining = Double(expiresAt) - timeSource()
                if remaining > advisory { return .token(cached.token) }
                if remaining > mandatory {
                    if refreshEvent != nil { return .token(cached.token) }
                    if timeSource() - lastAdvisoryFailureTime < ADVISORY_REFRESH_BACKOFF_SECONDS { return .token(cached.token) }
                    advisoryFallback = cached
                    remainingSeconds = Int(remaining)
                }
            }
            if let refreshEvent { return .wait(refreshEvent) }
            // We're the leader. The force flag is read in the same lock hold that elects the
            // leader, so a per-request call that started before an invalidate() can't take it.
            let event = AsyncEvent()
            refreshEvent = event
            return .refresh(Refresh(ownedEvent: event, force: nextForce, advisoryFallback: advisoryFallback,
                                    remainingSeconds: remainingSeconds))
        }
    }

    func endRefresh(_ fresh: AccessToken, _ refresh: Refresh) -> String {
        lock.withLock {
            if refresh.ownedEvent == nil {
                // A per-request caller may only overwrite another per-request token: after
                // invalidate() the cache has to stay empty so the next caller makes the forced call.
                if let c = cached, c.expiresAt == 0 { cached = fresh }
            } else {
                // A leader whose unforced call overlapped an invalidate() may hold the rejected
                // token, so it is used for this request only.
                if refresh.force || !nextForce { cached = fresh }
                if refresh.force { nextForce = false }
                refreshEvent = nil
            }
        }
        refresh.ownedEvent?.set()
        return fresh.token
    }

    /// Releases any waiters. Returns the stale token to serve for a failed advisory refresh, or
    /// `nil` if the caller should rethrow.
    func endFailedRefresh(_ err: Error, _ refresh: Refresh) -> String? {
        if let event = refresh.ownedEvent {
            lock.withLock { refreshEvent = nil }
            event.set()
        }
        guard let fallback = refresh.advisoryFallback, err is AnthropicError || err is URLError else { return nil }
        CredentialsLog.warning("Advisory token refresh failed (\(refresh.remainingSeconds)s remaining); serving cached token: \(err)")
        lock.withLock { lastAdvisoryFailureTime = timeSource() }
        return fallback.token
    }

    /// Clears the cached token so the next `getToken()` re-invokes the provider, and sets a one-shot
    /// `forceRefresh` flag so on-disk providers skip their freshness short-circuit.
    public func invalidate() {
        lock.withLock {
            cached = nil
            nextForce = true
        }
    }
}
