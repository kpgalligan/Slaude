import Foundation

/// What a page needs to request the next one (`_base_client.PageInfo`).
public enum PageInfo: Sendable, CustomStringConvertible {
    case params([String: JSONValue])
    case url(URL)
    case json([String: JSONValue])

    public var description: String {
        switch self {
        case .params(let p): return "PageInfo(params=\(JSONValue.object(p)))"
        case .url(let u): return "PageInfo(url=\(u))"
        case .json(let j): return "PageInfo(json=\(JSONValue.object(j)))"
        }
    }
}

/// The client and options a page was fetched with.
public struct PageContext: Sendable {
    let client: BaseClient
    public let options: FinalRequestOptions
}

/// The interface shared by every page type (`BasePage` + `BaseAsyncPage`).
///
/// A page is an `AsyncSequence` over its items *and every following page's items*
/// (auto-pagination), like `async for item in await client.models.list()` in Python.
public protocol AsyncPage: Decodable, Sendable, AsyncSequence where Element == Item {
    associatedtype Item: Decodable & Sendable
    /// The items on this page.
    var items: [Item] { get }
    func nextPageInfo() -> PageInfo?
    func hasNextPage() -> Bool
    var context: PageContext? { get set }
}

extension AsyncPage {
    /// The default `has_next_page`: there are items and a next page can be described.
    public func defaultHasNextPage() -> Bool {
        if items.isEmpty { return false }
        return nextPageInfo() != nil
    }

    /// Fetches the next page. Throws if there isn't one; check `hasNextPage()` first.
    public func getNextPage() async throws -> Self {
        guard let info = nextPageInfo() else {
            throw AnthropicError("No next page expected; please check `.has_next_page()` before calling `.get_next_page()`.")
        }
        guard let context else { throw AnthropicError("This page has no client to fetch the next page with") }
        var options = context.options
        options.stripRawResponseHeader()
        switch info {
        case .params(let p):
            for (k, v) in p.sorted(by: { $0.key < $1.key }) { options.setParam(k, v) }
        case .url(let url):
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            for item in comps?.queryItems ?? [] { options.setParam(item.name, .string(item.value ?? "")) }
            comps?.queryItems = nil
            options.url = comps?.url?.absoluteString ?? url.absoluteString
        case .json(let j):
            if options.jsonData == nil {
                options.jsonData = .object(j)
            } else if case .object(var o)? = options.jsonData {
                for (k, v) in j { o[k] = v }
                options.jsonData = .object(o)
            } else {
                throw ArgumentTypeError("Pagination is only supported with mappings")
            }
        }
        return try await context.client.requestPage(Self.self, options)
    }

    /// Iterates over this page and every page after it.
    public func iterPages() -> AsyncThrowingStream<Self, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var page = self
                    while true {
                        continuation.yield(page)
                        if page.hasNextPage() { page = try await page.getNextPage() } else { break }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func makeAsyncIterator() -> AsyncThrowingStream<Item, Error>.AsyncIterator {
        let pages = iterPages()
        return AsyncThrowingStream<Item, Error> { continuation in
            let task = Task {
                do {
                    for try await page in pages {
                        for item in page.items { continuation.yield(item) }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }.makeAsyncIterator()
    }
}

private enum PageKeys: String, CodingKey {
    case data, hasMore = "has_more", firstID = "first_id", lastID = "last_id", nextPage = "next_page",
        prevPage = "prev_page", dataRefreshedAt = "data_refreshed_at"
}

/// `pagination.AsyncPage`: cursor pagination with `after_id` / `before_id`.
public struct Page<Item: Decodable & Sendable>: AsyncPage {
    public typealias Element = Item
    public var data: [Item]
    public var hasMore: Bool?
    public var firstID: String?
    public var lastID: String?
    public var context: PageContext?

    public init(data: [Item], hasMore: Bool? = nil, firstID: String? = nil, lastID: String? = nil) {
        self.data = data
        self.hasMore = hasMore
        self.firstID = firstID
        self.lastID = lastID
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: PageKeys.self)
        data = try c.decodeIfPresent([Item].self, forKey: .data) ?? []
        hasMore = try c.decodeIfPresent(Bool.self, forKey: .hasMore)
        firstID = try c.decodeIfPresent(String.self, forKey: .firstID)
        lastID = try c.decodeIfPresent(String.self, forKey: .lastID)
    }

    public var items: [Item] { data }

    public func hasNextPage() -> Bool {
        if hasMore == false { return false }
        return defaultHasNextPage()
    }

    public func nextPageInfo() -> PageInfo? {
        if let before = context?.options.param("before_id"), before != .null, before != .string("") {
            guard let firstID, !firstID.isEmpty else { return nil }
            return .params(["before_id": .string(firstID)])
        }
        guard let lastID, !lastID.isEmpty else { return nil }
        return .params(["after_id": .string(lastID)])
    }
}

/// `pagination.AsyncTokenPage`: `page_token` pagination.
public struct TokenPage<Item: Decodable & Sendable>: AsyncPage {
    public typealias Element = Item
    public var data: [Item]
    public var hasMore: Bool?
    public var nextPage: String?
    public var context: PageContext?

    public init(data: [Item], hasMore: Bool? = nil, nextPage: String? = nil) {
        self.data = data
        self.hasMore = hasMore
        self.nextPage = nextPage
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: PageKeys.self)
        data = try c.decodeIfPresent([Item].self, forKey: .data) ?? []
        hasMore = try c.decodeIfPresent(Bool.self, forKey: .hasMore)
        nextPage = try c.decodeIfPresent(String.self, forKey: .nextPage)
    }

    public var items: [Item] { data }

    public func hasNextPage() -> Bool {
        if hasMore == false { return false }
        return defaultHasNextPage()
    }

    public func nextPageInfo() -> PageInfo? {
        guard let nextPage, !nextPage.isEmpty else { return nil }
        return .params(["page_token": .string(nextPage)])
    }
}

/// `pagination.AsyncPageCursor`: `page` cursor pagination.
public struct PageCursor<Item: Decodable & Sendable>: AsyncPage {
    public typealias Element = Item
    public var data: [Item]
    public var nextPage: String?
    public var context: PageContext?

    public init(data: [Item], nextPage: String? = nil) {
        self.data = data
        self.nextPage = nextPage
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: PageKeys.self)
        data = try c.decodeIfPresent([Item].self, forKey: .data) ?? []
        nextPage = try c.decodeIfPresent(String.self, forKey: .nextPage)
    }

    public var items: [Item] { data }
    public func hasNextPage() -> Bool { nextPageInfo() != nil }

    public func nextPageInfo() -> PageInfo? {
        guard let nextPage, !nextPage.isEmpty else { return nil }
        return .params(["page": .string(nextPage)])
    }
}

/// `pagination.AsyncBidirectionalPageCursor`.
public struct BidirectionalPageCursor<Item: Decodable & Sendable>: AsyncPage {
    public typealias Element = Item
    public var data: [Item]
    public var nextPage: String?
    public var prevPage: String?
    public var context: PageContext?

    public init(data: [Item], nextPage: String? = nil, prevPage: String? = nil) {
        self.data = data
        self.nextPage = nextPage
        self.prevPage = prevPage
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: PageKeys.self)
        data = try c.decodeIfPresent([Item].self, forKey: .data) ?? []
        nextPage = try c.decodeIfPresent(String.self, forKey: .nextPage)
        prevPage = try c.decodeIfPresent(String.self, forKey: .prevPage)
    }

    public var items: [Item] { data }
    public func hasNextPage() -> Bool { nextPageInfo() != nil }

    public func nextPageInfo() -> PageInfo? {
        guard let nextPage, !nextPage.isEmpty else { return nil }
        return .params(["page": .string(nextPage)])
    }
}

/// `pagination.AsyncReportPageCursor`.
public struct ReportPageCursor<Item: Decodable & Sendable>: AsyncPage {
    public typealias Element = Item
    public var data: [Item]
    public var nextPage: String?
    public var hasMore: Bool?
    public var dataRefreshedAt: Date?
    public var context: PageContext?

    public init(data: [Item], nextPage: String? = nil, hasMore: Bool? = nil, dataRefreshedAt: Date? = nil) {
        self.data = data
        self.nextPage = nextPage
        self.hasMore = hasMore
        self.dataRefreshedAt = dataRefreshedAt
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: PageKeys.self)
        data = try c.decodeIfPresent([Item].self, forKey: .data) ?? []
        nextPage = try c.decodeIfPresent(String.self, forKey: .nextPage)
        hasMore = try c.decodeIfPresent(Bool.self, forKey: .hasMore)
        dataRefreshedAt = try c.decodeIfPresent(Date.self, forKey: .dataRefreshedAt)
    }

    public var items: [Item] { data }

    public func hasNextPage() -> Bool {
        if hasMore == false { return false }
        return nextPageInfo() != nil
    }

    public func nextPageInfo() -> PageInfo? {
        guard let nextPage, !nextPage.isEmpty else { return nil }
        return .params(["page": .string(nextPage)])
    }
}
