// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "MagazineLayout",
  platforms: [
    .iOS(.v10),
    .tvOS(.v10),
  ],
  products: [
    .library(name: "MagazineLayout", targets: ["MagazineLayout"])
  ],
  dependencies: [
    .package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.2.0"))
  ],
  targets: [
    .target(
      name: "MagazineLayout",
      path: "MagazineLayout"
    ),
    .testTarget(
      name: "MagazineLayoutTests",
      dependencies: ["MagazineLayout"],
      path: "Tests"
    ),
  ],
  swiftLanguageVersions: [.v5]
)
