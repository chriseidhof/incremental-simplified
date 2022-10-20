// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Incremental",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Incremental",
            targets: ["Incremental"]),
        .library(name: "Resin",
            targets: ["Resin"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Incremental",
            dependencies: []),
        .target(
            name: "Resin",
            dependencies: ["Incremental"]),
        .testTarget(
            name: "IncrementalTests",
            dependencies: ["Incremental"]),
    ]
)
