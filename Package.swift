// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SoniMate",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "SoniMate",
            dependencies: [],
            path: "Sources/SoniMate",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Info.plist"])
            ]
        ),
        .testTarget(
            name: "SoniMateTests",
            dependencies: ["SoniMate"],
            path: "Tests/SoniMateTests"
        )
    ]
)
