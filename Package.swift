// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MagazineLayout",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        .library(name: "MagazineLayout", targets: ["MagazineLayout"])
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
        )
    ],
    swiftLanguageVersions: [.v5]
)
