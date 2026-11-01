// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Slaude",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
    products: [
        .library(name: "Anthropic", targets: ["Anthropic"]),
    ],
    targets: [
        .target(
            name: "Anthropic",
            path: "Sources/Anthropic"
        ),
        .testTarget(
            name: "AnthropicTests",
            dependencies: ["Anthropic"],
            path: "Tests/AnthropicTests"
        ),
    ]
)
