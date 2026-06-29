// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Vremena",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        // Pure logic + models — no AppKit UI, fully unit-testable.
        .target(
            name: "VremenaCore",
            path: "Sources/VremenaCore"
        ),
        // The menu bar app itself.
        .executableTarget(
            name: "Vremena",
            dependencies: ["VremenaCore"],
            path: "Sources/Vremena"
        ),
        .testTarget(
            name: "VremenaTests",
            dependencies: ["VremenaCore"],
            path: "Tests/VremenaTests"
        )
    ]
)
