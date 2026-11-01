// Transformed from `anthropic.types.beta.beta_packages_params` (beta_packages_params.py).

import Foundation

/// Specify packages (and optionally their versions) available in this environment.
///
/// When versioning, use the version semantics relevant for the package manager, e.g. for `pip` use `package==1.0.0`. You are responsible for validating the package and version exist. Unversioned installs the latest.
///
/// Under `limited` networking, requires `networking.allow_package_managers` to be `true`.
public struct BetaPackagesParams: Codable, Hashable, Sendable {
    /// Ubuntu/Debian packages to install
    public var apt: [String]??
    /// Rust packages to install
    public var cargo: [String]??
    /// Ruby packages to install
    public var gem: [String]??
    /// Go packages to install
    public var go: [String]??
    /// Node.js packages to install
    public var npm: [String]??
    /// Python packages to install
    public var pip: [String]??
    /// Package configuration type
    public var type: String?

    public init(apt: [String]?? = nil, cargo: [String]?? = nil, gem: [String]?? = nil, go: [String]?? = nil, npm: [String]?? = nil, pip: [String]?? = nil, type: String? = nil) {
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
