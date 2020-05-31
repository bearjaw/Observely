// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Observely",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "Observely",
            targets: ["Observely"])
    ],
    targets: [
        .target(
            name: "Observely",
            dependencies: []),
        .testTarget(
            name: "ObservelyTests",
            dependencies: ["Observely"])
    ]
)
