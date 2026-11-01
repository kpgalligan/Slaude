import Foundation
import Testing
@testable import Anthropic

// Port of `TestTokenCache`, the cache tests of `TestAsyncAccessTokenProvider` and
// `TestTokenCacheDeadlock` from `tests/lib/test_credentials.py`. Python's thread-based
// concurrency tests run as concurrent tasks here.

/// A provider built from a closure.
func provider(_ body: @escaping @Sendable (Bool) async throws -> AccessToken) -> AccessTokenProviderFunction {
    AccessTokenProviderFunction(body)
}

/// Polls `condition` until it holds or `timeout` passes; returns whether it held.
func eventually(timeout: TimeInterval = 2, _ condition: @Sendable () -> Bool) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(nanoseconds: 1_000_000)
    }
    return condition()
}

/// Runs `body` with a time limit, failing the test (rather than hanging) on a deadlock.
func withDeadline<T: Sendable>(_ seconds: TimeInterval = 5, _ body: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T?.self) { group in
        group.addTask { try await body() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            return nil
        }
        let first = try await group.next()!
        group.cancelAll()
        guard let value = first else { throw ValueError("timed out (deadlock?)") }
        return value
    }
}

@Suite struct TokenCacheTests {
    @Test func firstCallFetches() async throws {
        let p = CountingProvider([AccessToken(token: "a", expiresAt: 2000)])
        let cache = TokenCache(p, timeSource: FakeClock(1000).source)
        #expect(try await cache.getToken() == "a")
        #expect(p.calls == 1)
    }

    @Test func noExpiryNeverRefreshes() async throws {
        let p = CountingProvider([AccessToken(token: "a", expiresAt: nil)])
        let clock = FakeClock(1000)
        let cache = TokenCache(p, timeSource: clock.source)
        _ = try await cache.getToken()
        clock.now = 999999
        _ = try await cache.getToken()
        _ = try await cache.getToken()
        #expect(p.calls == 1)
    }

    @Test func freshTokenNotRefetched() async throws {
        let p = CountingProvider([AccessToken(token: "a", expiresAt: 1000 + 600)])
        let cache = TokenCache(p, timeSource: FakeClock(1000).source)
        for _ in 0..<3 { _ = try await cache.getToken() }
        #expect(p.calls == 1)
    }

    @Test func advisoryRefreshSuccess() async throws {
        let clock = FakeClock(1000)
        let p = CountingProvider([AccessToken(token: "a", expiresAt: 1600), AccessToken(token: "b", expiresAt: 2200)])
        let cache = TokenCache(p, timeSource: clock.source)
        #expect(try await cache.getToken() == "a")
        clock.now = 1000 + 600 - 60  // 60s remaining: advisory window (30 < 60 < 120)
        #expect(try await cache.getToken() == "b")
        #expect(p.calls == 2)
    }

    @Test func advisoryRefreshFailureServesStale() async throws {
        let clock = FakeClock(1000)
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 { return AccessToken(token: "a", expiresAt: 1600) }
            throw WorkloadIdentityError("backend down")
        }, timeSource: clock.source)
        #expect(try await cache.getToken() == "a")
        clock.now = 1000 + 600 - 60
        try await withCapturedLogs { logs in
            let token = try await cache.getToken()
            #expect(token == "a")  // stale served
            #expect(logs.warnings.contains { $0.contains("Advisory token refresh failed (60s remaining)") })
        }
        #expect(calls.count == 2)
    }

    @Test func mandatoryRefreshFailureRaises() async throws {
        let clock = FakeClock(1000)
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 { return AccessToken(token: "a", expiresAt: 1600) }
            throw WorkloadIdentityError("backend down")
        }, timeSource: clock.source)
        _ = try await cache.getToken()
        clock.now = 1000 + 600 - 10  // mandatory window
        await expectThrows(WorkloadIdentityError.self, "backend down") { _ = try await cache.getToken() }
    }

    @Test func expiredIsMandatory() async throws {
        let clock = FakeClock(1000)
        let p = CountingProvider([AccessToken(token: "a", expiresAt: 1600), AccessToken(token: "b", expiresAt: 2200)])
        let cache = TokenCache(p, timeSource: clock.source)
        _ = try await cache.getToken()
        clock.now = 1000 + 700
        #expect(try await cache.getToken() == "b")
        #expect(p.calls == 2)
    }

    @Test func invalidate() async throws {
        let p = CountingProvider([AccessToken(token: "a"), AccessToken(token: "b")])
        let cache = TokenCache(p)
        #expect(try await cache.getToken() == "a")
        #expect(try await cache.getToken() == "a")
        #expect(p.calls == 1)
        cache.invalidate()
        #expect(try await cache.getToken() == "b")
        #expect(p.calls == 2)
    }

    @Test func retriesOnceOn401FromTokenEndpoint() async throws {
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 { throw WorkloadIdentityError("token exchange failed", statusCode: 401, body: "unauthorized") }
            return AccessToken(token: "fresh")
        })
        #expect(try await cache.getToken() == "fresh")
        #expect(calls.count == 2)
    }

    @Test func noRetryOnNon401Error() async {
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            _ = calls.next()
            throw WorkloadIdentityError("bad request", statusCode: 400, body: "invalid")
        })
        await expectThrows(WorkloadIdentityError.self, "bad request") { _ = try await cache.getToken() }
        #expect(calls.count == 1)
    }

    @Test func retryOn401StillFailsRaises() async {
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            _ = calls.next()
            throw WorkloadIdentityError("still unauthorized", statusCode: 401, body: "unauthorized")
        })
        await expectThrows(WorkloadIdentityError.self, "still unauthorized") { _ = try await cache.getToken() }
        #expect(calls.count == 2)
    }

    @Test func concurrentMandatoryRefreshSingleFlight() async throws {
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            _ = calls.next()
            // Hold the refresh long enough for the other callers to queue up.
            try await Task.sleep(nanoseconds: 100_000_000)
            return AccessToken(token: "fresh")
        })
        let results = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<8 { group.addTask { try await cache.getToken() } }
            var out: [String] = []
            for try await r in group { out.append(r) }
            return out
        }
        #expect(calls.count == 1)
        #expect(results == Array(repeating: "fresh", count: 8))
    }

    /// Only exactly `expiresAt == 0` opts out of single-flight; any other past value is expired.
    @Test(arguments: [1, 1000 - 5])
    func expiredButNonzeroExpiryKeepsSingleFlight(expiresAt: Int) async throws {
        let calls = Counter()
        let release = AsyncEvent()
        let cache = TokenCache(provider { _ in
            let n = calls.next() + 1
            if n == 2 { await release.wait() }
            return AccessToken(token: "tok-\(n)", expiresAt: n < 3 ? expiresAt : nil)
        }, timeSource: FakeClock(1000).source)
        #expect(try await cache.getToken() == "tok-1")
        let tokens = try await withDeadline {
            try await withThrowingTaskGroup(of: String.self) { group in
                for _ in 0..<3 { group.addTask { try await cache.getToken() } }
                _ = await eventually { calls.count >= 2 }
                release.set()
                var out: [String] = []
                for try await r in group { out.append(r) }
                return out
            }
        }
        // One caller at a time: tok-2 is expired too, so the next leader fetches tok-3, which is cached.
        #expect(tokens.sorted() == ["tok-2", "tok-3", "tok-3"])
    }

    @Test func zeroExpiryTokenIsNotReused() async throws {
        let p = CountingProvider([AccessToken(token: "a", expiresAt: 0), AccessToken(token: "b", expiresAt: 0), AccessToken(token: "c", expiresAt: 1600)])
        let cache = TokenCache(p, timeSource: FakeClock(1000).source)
        var got: [String] = []
        for _ in 0..<4 { got.append(try await cache.getToken()) }
        #expect(got == ["a", "b", "c", "c"])
        #expect(p.calls == 3)
    }

    /// Callers don't queue behind each other for a token that can't be shared.
    @Test func zeroExpiryTokensAreFetchedConcurrently() async throws {
        let calls = Counter()
        let arrived = Counter()
        let cache = TokenCache(provider { _ in
            let n = calls.next() + 1
            if n > 1 {
                _ = arrived.next()
                // A barrier for the three callers: it times out if they queued.
                guard await eventually({ arrived.count >= 3 }) else { throw ValueError("callers queued behind each other") }
            }
            return AccessToken(token: "tok-\(n)", expiresAt: 0)
        })
        #expect(try await cache.getToken() == "tok-1")
        let tokens = try await withDeadline {
            try await withThrowingTaskGroup(of: String.self) { group in
                for _ in 0..<3 { group.addTask { try await cache.getToken() } }
                var out: [String] = []
                for try await r in group { out.append(r) }
                return out
            }
        }
        #expect(tokens.sorted() == ["tok-2", "tok-3", "tok-4"])
    }

    /// An advisory-window caller neither starts a second refresh nor waits for a running one.
    @Test func advisoryCallerSkipsWhenRefreshInFlight() async throws {
        let clock = FakeClock(1000)
        let tokens = [AccessToken(token: "a", expiresAt: 1600), AccessToken(token: "b", expiresAt: 2800)]
        let calls = Counter()
        let started = Box(false)
        let release = AsyncEvent()
        let cache = TokenCache(provider { _ in
            let n = calls.next()
            if n > 0 {
                started.value = true
                await release.wait()
            }
            return tokens[n]
        }, timeSource: clock.source)
        #expect(try await cache.getToken() == "a")

        clock.now = 1000 + 600 - 60
        let leader = Task { try await cache.getToken() }
        #expect(await eventually { started.value })

        let t0 = Date()
        let observed = try await cache.getToken()
        let elapsed = Date().timeIntervalSince(t0)
        #expect(observed == "a")
        #expect(elapsed < 1.0, "advisory caller waited for leader (\(elapsed)s)")

        release.set()
        _ = try await leader.value
        #expect(calls.count == 2)
    }

    @Test func invalidateForcesProviderRefresh() async throws {
        let p = CountingProvider([AccessToken(token: "a"), AccessToken(token: "b")])
        let cache = TokenCache(p)
        #expect(try await cache.getToken() == "a")
        cache.invalidate()
        #expect(try await cache.getToken() == "b")
        #expect(p.forces == [false, true], "forceRefresh must be true on the post-invalidate call")
    }

    @Test func nextForcePreservedOnProviderFailure() async throws {
        let forces = Box<[Bool]>([])
        let cache = TokenCache(provider { force in
            forces.mutate { $0.append(force) }
            if forces.value.count == 1 { throw ValueError("transient") }
            return AccessToken(token: "ok")
        })
        cache.invalidate()
        await expectThrows(ValueError.self) { _ = try await cache.getToken() }
        #expect(try await cache.getToken() == "ok")
        #expect(forces.value == [true, true], "force flag must survive provider failure")
    }

    @Test func perRequestModeStillForcesAfterInvalidate() async throws {
        let forces = Box<[Bool]>([])
        let cache = TokenCache(provider { force in
            forces.mutate { $0.append(force) }
            return AccessToken(token: "tok-\(forces.value.count)", expiresAt: 0)
        })
        _ = try await cache.getToken()
        _ = try await cache.getToken()
        cache.invalidate()
        _ = try await cache.getToken()
        _ = try await cache.getToken()
        #expect(forces.value == [false, false, true, false])
    }

    @Test func concurrentInvalidateSurvivesNonForcedCall() async throws {
        let forces = Box<[Bool]>([])
        let cacheBox = Box<TokenCache?>(nil)
        let cache = TokenCache(provider { force in
            forces.mutate { $0.append(force) }
            if forces.value.count == 2 { cacheBox.value?.invalidate() }  // another request's 401 arriving now
            return AccessToken(token: "tok-\(forces.value.count)", expiresAt: 0)
        })
        cacheBox.value = cache
        _ = try await cache.getToken()  // switch to per-request mode
        _ = try await cache.getToken()
        _ = try await cache.getToken()
        #expect(forces.value == [false, false, true])
    }

    /// The token may be the one the API just rejected, so it serves this request only.
    @Test func unforcedResultIsNotCachedAfterAConcurrentInvalidate() async throws {
        let forces = Box<[Bool]>([])
        let cacheBox = Box<TokenCache?>(nil)
        let cache = TokenCache(provider { force in
            forces.mutate { $0.append(force) }
            if forces.value.count == 1 { cacheBox.value?.invalidate() }
            return AccessToken(token: "tok-\(forces.value.count)")
        })
        cacheBox.value = cache
        #expect(try await cache.getToken() == "tok-1")
        #expect(try await cache.getToken() == "tok-2")
        #expect(try await cache.getToken() == "tok-2")
        #expect(forces.value == [false, true])
    }

    @Test func latePerRequestResultDoesNotReplaceCachedExpiringToken() async throws {
        let forces = Box<[Bool]>([])
        let pIn = Box(false)
        let pRelease = AsyncEvent()
        let cache = TokenCache(provider { force in
            forces.mutate { $0.append(force) }
            let n = forces.value.count
            if n == 2 {  // the late per-request caller "P"
                pIn.value = true
                await pRelease.wait()
                return AccessToken(token: "tok-late", expiresAt: 0)
            }
            if force { return AccessToken(token: "tok-forced", expiresAt: 1000 + 3600) }
            return AccessToken(token: "tok-\(n)", expiresAt: 0)
        }, timeSource: FakeClock(1000).source)
        #expect(try await cache.getToken() == "tok-1")  // per-request mode
        let late = Task { try await cache.getToken() }
        #expect(await eventually { pIn.value })
        cache.invalidate()
        #expect(try await cache.getToken() == "tok-forced")  // cached with a real expiry
        pRelease.set()
        #expect(try await withDeadline { try await late.value } == "tok-late")  // its own token, for its request
        #expect(try await cache.getToken() == "tok-forced")  // served from cache, no provider call
        #expect(forces.value == [false, false, true])
    }

    @Test func advisoryRefreshBackoffAfterFailure() async throws {
        let clock = FakeClock(1000)
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 { return AccessToken(token: "a", expiresAt: 1600) }
            throw WorkloadIdentityError("token endpoint down", statusCode: 503)
        }, timeSource: clock.source)
        #expect(try await cache.getToken() == "a")
        clock.now = 1000 + 600 - 60
        #expect(try await cache.getToken() == "a")
        #expect(calls.count == 2)

        clock.now += 3
        #expect(try await cache.getToken() == "a")
        #expect(calls.count == 2, "provider must not be retried within backoff window")

        clock.now += 3
        #expect(try await cache.getToken() == "a")
        #expect(calls.count == 3, "provider must be retried after backoff window")
    }

    // -- from TestAsyncAccessTokenProvider

    @Test func calledAgainAfterExpiry() async throws {
        let clock = FakeClock(1000)
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            let n = calls.next() + 1
            return AccessToken(token: "tok-\(n)", expiresAt: Int(clock.now) + 600)
        }, timeSource: clock.source)
        #expect(try await cache.getToken() == "tok-1")
        clock.now += 601
        #expect(try await cache.getToken() == "tok-2")
        #expect(try await cache.getToken() == "tok-2")
    }

    /// P0 is a per-request call that starts before `invalidate()` and finishes after it.
    @Test func oneForcedCallPerInvalidateInPerRequestMode() async throws {
        let forces = Box<[Bool]>([])
        let p0In = Box(false), leaderIn = Box(false)
        let p0Release = AsyncEvent(), releaseLeader = AsyncEvent()
        let cache = TokenCache(provider { force in
            var n = 0
            forces.mutate {
                $0.append(force)
                n = $0.count
            }
            if n == 2 {
                p0In.value = true
                await p0Release.wait()
            } else if force {
                leaderIn.value = true
                await releaseLeader.wait()
            }
            return AccessToken(token: "tok-\(n)", expiresAt: 0)
        })
        #expect(try await cache.getToken() == "tok-1")
        let p0 = Task { try await cache.getToken() }
        #expect(await eventually { p0In.value })
        cache.invalidate()
        let leader = Task { try await cache.getToken() }
        #expect(await eventually { leaderIn.value })  // the forced call is in flight
        p0Release.set()
        #expect(try await withDeadline { try await p0.value } == "tok-2")  // P0 still uses its own token
        let others = (0..<5).map { _ in Task { try await cache.getToken() } }
        try await Task.sleep(nanoseconds: 50_000_000)  // let them find the refresh in flight
        #expect(forces.value.count == 3)  // none of them has called the provider
        releaseLeader.set()
        #expect(try await withDeadline { try await leader.value } == "tok-3")
        var rest: [String] = []
        for t in others { rest.append(try await withDeadline { try await t.value }) }
        #expect(rest.sorted() == (4...8).map { "tok-\($0)" })
        #expect(forces.value == [false, false, true, false, false, false, false, false])
    }

    @Test func concurrentColdCallsShareOneProviderCall() async throws {
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            _ = calls.next()
            try await Task.sleep(nanoseconds: 50_000_000)
            return AccessToken(token: "tok")
        })
        let results = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<8 { group.addTask { try await cache.getToken() } }
            var out: [String] = []
            for try await r in group { out.append(r) }
            return out
        }
        #expect(results == Array(repeating: "tok", count: 8))
        #expect(calls.count == 1)
    }

    @Test func advisoryFailureServesCachedAndMandatoryFailureRaises() async throws {
        let clock = FakeClock(1000)
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            if calls.next() > 0 { throw AnthropicError("token service unavailable") }
            return AccessToken(token: "a", expiresAt: 1600)
        }, timeSource: clock.source)
        #expect(try await cache.getToken() == "a")
        clock.now = 1000 + 600 - 60
        #expect(try await cache.getToken() == "a")
        clock.now = 1000 + 600 - 10
        await expectThrows(AnthropicError.self, "unavailable") { _ = try await cache.getToken() }
        #expect(calls.count == 3)
    }

    @Test func cancelledLeaderReleasesWaiters() async throws {
        let calls = Counter()
        let started = Box(false)
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 {
                started.value = true
                try await Task.sleep(nanoseconds: 3_600_000_000_000)
            }
            return AccessToken(token: "tok")
        })
        let leader = Task { try await cache.getToken() }
        #expect(await eventually { started.value })
        let waiter = Task { try await cache.getToken() }
        try await Task.sleep(nanoseconds: 50_000_000)  // let the waiter find the refresh in flight
        #expect(calls.count == 1)
        leader.cancel()
        #expect(try await withDeadline { try await waiter.value } == "tok")
        await expectThrows(CancellationError.self) { _ = try await leader.value }
        #expect(calls.count == 2)
    }

    // -- from TestTokenCacheDeadlock

    /// An error outside the SDK's hierarchy from the leader still releases concurrent waiters.
    @Test func nonAnthropicErrorFromProviderReleasesWaiters() async throws {
        let calls = Counter()
        let ready = Box(false)
        let releaseLeader = AsyncEvent()
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 {
                ready.value = true
                await releaseLeader.wait()
                throw ValueError("programmer error from a custom provider")
            }
            return AccessToken(token: "fresh")
        })
        let leader = Task { try await cache.getToken() }
        #expect(await eventually { ready.value })
        let waiter = Task { try await cache.getToken() }
        try await Task.sleep(nanoseconds: 20_000_000)
        releaseLeader.set()
        await expectThrows(ValueError.self) { _ = try await withDeadline { try await leader.value } }
        #expect(try await withDeadline { try await waiter.value } == "fresh")
        #expect(try await cache.getToken() == "fresh")
    }

    @Test func valueErrorFromProviderPropagatesCleanly() async throws {
        let calls = Counter()
        let cache = TokenCache(provider { _ in
            if calls.next() == 0 { throw ValueError("malformed assertion") }
            return AccessToken(token: "ok")
        })
        await expectThrows(ValueError.self, "malformed assertion") { _ = try await cache.getToken() }
        #expect(try await cache.getToken() == "ok")
    }
}
