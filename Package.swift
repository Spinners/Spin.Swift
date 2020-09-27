// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spin.Swift",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SpinCommon",
            targets: ["SpinCommon"]),
        .library(
            name: "SpinCombine",
            targets: ["SpinCombine"]),
        .library(
            name: "SpinReactiveSwift",
            targets: ["SpinReactiveSwift"]),
        .library(
            name: "SpinRxSwift",
            targets: ["SpinRxSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift", from: "6.3.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.1.1"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SpinCommon",
            dependencies: [],
            path: "Sources/Common"),
        .target(
            name: "SpinCombine",
            dependencies: ["SpinCommon"],
            path: "Sources/Combine"),
        .target(
            name: "SpinReactiveSwift",
            dependencies: ["SpinCommon", "ReactiveSwift"],
            path: "Sources/ReactiveSwift"),
        .target(
            name: "SpinRxSwift",
            dependencies: ["SpinCommon", "RxSwift", .product(name: "RxRelay", package: "RxSwift")],
            path: "Sources/RxSwift"),
        .testTarget(
            name: "SpinCommonTests",
            dependencies: ["SpinCommon"],
            path: "Tests/CommonTests"),
        .testTarget(
            name: "SpinCombineTests",
            dependencies: ["SpinCombine"],
            path: "Tests/CombineTests"),
        .testTarget(
            name: "SpinReactiveSwiftTests",
            dependencies: ["SpinReactiveSwift"],
            path: "Tests/ReactiveSwiftTests"),
        .testTarget(
            name: "SpinRxSwiftTests",
            dependencies: ["SpinRxSwift", .product(name: "RxBlocking", package: "RxSwift")],
            path: "Tests/RxSwiftTests"
        ),
    ]
)
