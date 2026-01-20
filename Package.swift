// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ClaudeNotifier",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClaudeNotifier", targets: ["ClaudeNotifier"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ClaudeNotifier",
            dependencies: [],
            path: "ClaudeNotifier",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
