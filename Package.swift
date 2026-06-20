// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DockOwl",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "DockOwl",
            path: "Sources/DockOwl"
        ),
    ]
)
