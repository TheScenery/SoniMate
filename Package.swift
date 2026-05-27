// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MicMonitor",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MicMonitor",
            dependencies: [],
            path: "Sources/MicMonitor",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Info.plist"])
            ]
        ),
        .testTarget(
            name: "MicMonitorTests",
            dependencies: ["MicMonitor"],
            path: "Tests/MicMonitorTests"
        )
    ]
)
