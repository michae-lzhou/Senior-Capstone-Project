// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleRunnerDriver",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SimpleRunnerDriver",
            type: .dynamic,
            targets: ["SimpleRunnerDriver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SimpleRunnerDriver",
            dependencies: [
                "SwiftGodot",
//                .product(name: "SwiftGodot", package: "SwiftGodot")
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "SimpleRunnerDriverTests",
            dependencies: ["SimpleRunnerDriver"]
        ),
    ]
)
