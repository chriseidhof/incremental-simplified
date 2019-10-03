// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Incremental",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Incremental", targets: ["Incremental"]),
        .library(name: "Resin", targets: ["Resin"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Incremental",
            dependencies: []),
        .target(
            name: "Resin",
            dependencies: ["Incremental"])
    ]
)
