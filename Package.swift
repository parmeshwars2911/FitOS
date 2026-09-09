// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FitOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "TrainingEngine", targets: ["TrainingEngine"])
    ],
    targets: [
        .target(name: "TrainingEngine"),
        .testTarget(name: "TrainingEngineTests", dependencies: ["TrainingEngine"])
    ]
)
