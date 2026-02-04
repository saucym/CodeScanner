// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CodeScanner",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [.library(name: "CodeScanner", targets: ["CodeScanner"])],
    dependencies: [],
    targets: [.target(name: "CodeScanner", dependencies: [])]
)
