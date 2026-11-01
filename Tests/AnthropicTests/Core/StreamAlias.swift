// No Foundation import here: Foundation's `Stream` (NSStream) would shadow the SDK's.
@testable import Anthropic

/// The SDK's `Stream<Element>`, unambiguous in files that import Foundation.
typealias SSEStream<Element: Decodable & Sendable> = Stream<Element>
