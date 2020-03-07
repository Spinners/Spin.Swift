// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spin.Swift",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Spin.Swift",
            targets: ["Spin.Swift"]),
        .library(
            name: "Spin.Combine",
            targets: ["Spin.Combine"]),
        .library(
            name: "Spin.ReactiveSwift",
            targets: ["Spin.ReactiveSwift"]),
        .library(
            name: "Spin.RxSwift",
            targets: ["Spin.RxSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift", from: "6.2.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.1.0"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Spin.Swift",
            dependencies: [],
            path: "Sources/Spin.Swift"),
        .target(
            name: "Spin.Combine",
            dependencies: ["Spin.Swift"],
            path: "Sources/Spin.Combine"),
        .target(
            name: "Spin.ReactiveSwift",
            dependencies: ["Spin.Swift", "ReactiveSwift"],
            path: "Sources/Spin.ReactiveSwift"),
        .target(
            name: "Spin.RxSwift",
            dependencies: ["Spin.Swift", "RxSwift", "RxRelay"],
            path: "Sources/Spin.RxSwift"),
        .testTarget(
            name: "Spin.SwiftTests",
            dependencies: ["Spin.Swift"]),
        .testTarget(
            name: "Spin.CombineTests",
            dependencies: ["Spin.Combine"]),
        .testTarget(
            name: "Spin.ReactiveSwiftTests",
            dependencies: ["Spin.ReactiveSwift"]),
        .testTarget(
            name: "Spin.RxSwiftTests",
            dependencies: ["Spin.RxSwift", "RxRelay", "RxBlocking"]),
    ]
)
