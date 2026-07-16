// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PhilonetReadingTimer",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PhilonetReadingTimer",
            dependencies: [],
            resources: []
        ),
        .testTarget(
            name: "PhilonetReadingTimerTests",
            dependencies: ["PhilonetReadingTimer"]
        )
    ]
)
