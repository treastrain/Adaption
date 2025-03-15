// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Adaption",
    platforms: [.iOS(.v18), .macOS(.v15), .macCatalyst(.v18), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        .library(
            name: "Adaption",
            targets: ["Adaption"]),
    ],
    dependencies: [
        .package(url: "https://github.com/treastrain/prebuilt-swift-syntax", exact: "600.0.1"),
    ],
    targets: [
        .target(
            name: "Adaption",
            dependencies: ["AdaptionMacros"]),
        .macro(
            name: "AdaptionMacros",
            dependencies: [
                .product(name: "PrebuiltSwiftSyntax", package: "prebuilt-swift-syntax"),
            ]
        ),
        .testTarget(
            name: "AdaptionTests",
            dependencies: ["Adaption"]),
    ]
)

/// https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet

extension SwiftSetting {
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                      // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let internalImportsByDefault: Self = .enableUpcomingFeature("InternalImportsByDefault")  // SE-0409, Swift 6.0,  SwiftPM 6.0+
}

extension SwiftSetting: @retroactive CaseIterable {
    public static var allCases: [Self] {[.existentialAny, .internalImportsByDefault]}
}

package.targets
    .filter { ![.system, .binary, .plugin].contains($0.type) }
    .forEach { $0.swiftSettings = SwiftSetting.allCases }
