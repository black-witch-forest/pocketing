// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pocketing",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Pocketing",
            path: "Pocketing",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
