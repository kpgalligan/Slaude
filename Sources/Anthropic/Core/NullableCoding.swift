import Foundation

extension KeyedDecodingContainer {
    /// Decodes a not-required, nullable field (`X??`) keeping the distinction the Python SDK makes
    /// between an absent key (`nil`, i.e. `omit`) and an explicit `null` (`.some(nil)`, i.e. `None`).
    ///
    /// The standard library's `decodeIfPresent` maps both to `nil`; being more specific, this overload
    /// is the one synthesized `Codable` conformances pick for `X??` properties.
    public func decodeIfPresent<T: Decodable>(_ type: T?.Type, forKey key: Key) throws -> T?? {
        guard contains(key) else { return nil }
        if try decodeNil(forKey: key) { return .some(nil) }
        return .some(try decode(T.self, forKey: key))
    }
}
