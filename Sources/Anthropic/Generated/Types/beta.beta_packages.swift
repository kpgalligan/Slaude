// Transformed from `anthropic.types.beta.beta_packages` (beta_packages.py).

import Foundation

/// Packages (and their versions) available in this environment.
public struct BetaPackages: Codable, Hashable, Sendable {
    /// Ubuntu/Debian packages to install
    public var apt: [String]
    /// Rust packages to install
    public var cargo: [String]
    /// Ruby packages to install
    public var gem: [String]
    /// Go packages to install
    public var go: [String]
    /// Node.js packages to install
    public var npm: [String]
    /// Python packages to install
    public var pip: [String]
    /// Package configuration type
    public var type: String?

    public init(apt: [String], cargo: [String], gem: [String], go: [String], npm: [String], pip: [String], type: String? = nil) {
        self.apt = apt
        self.cargo = cargo
        self.gem = gem
        self.go = go
        self.npm = npm
        self.pip = pip
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case apt
        case cargo
        case gem
        case go
        case npm
        case pip
        case type
    }
}
