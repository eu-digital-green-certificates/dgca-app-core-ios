// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftDGC",
  defaultLocalization: "en",
  platforms: [.iOS(.v12), .macOS(.v10_14)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "SwiftDGC",
      targets: ["SwiftDGC"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/unrelentingtech/SwiftCBOR", from: "0.4.3"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.1"),
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.3"),
    .package(name: "JSONSchema", url: "https://github.com/jnewc/JSONSchema.swift", .branch("master"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SwiftDGC",
      dependencies: [
        "SwiftCBOR",
        "SwiftyJSON",
        "JSONSchema",
        "Alamofire"
      ],
      path: "Sources"),
    .testTarget(
      name: "SwiftDGCTests",
      dependencies: ["SwiftDGC"])
  ]
)
