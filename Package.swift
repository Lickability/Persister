// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "Persister"
let package = Package(
    name: name,
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [.library(name: name, targets: [name])],
    targets: [.target(name: name, resources: [.process("Resources")])]
)
