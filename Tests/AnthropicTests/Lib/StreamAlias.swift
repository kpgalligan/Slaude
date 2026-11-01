@testable import Anthropic

/// `Stream` is ambiguous with `Foundation.Stream` in files that import Foundation.
typealias SSEStream<E: Decodable & Sendable> = Stream<E>
