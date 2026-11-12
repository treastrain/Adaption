// swift-tools-version: 6.4

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Adaption",
    platforms: [.iOS(.v18), .macOS(.v15), .macCatalyst(.v18), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        .library(
            name: "Adaption",
            targets: ["Adaption"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "604.0.0")
    ],
    targets: [
        .target(
            name: "Adaption",
            dependencies: ["AdaptionMacros"]
        ),
        .macro(
            name: "AdaptionMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "AdaptionTests",
            dependencies: ["Adaption"]
        ),
        .testTarget(
            name: "AdaptionMacrosTests",
            dependencies: [
                "AdaptionMacros",
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)

// Ref: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet

extension SwiftSetting {
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")  // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let internalImportsByDefault: Self = .enableUpcomingFeature("InternalImportsByDefault")  // SE-0409, Swift 6.0,  SwiftPM 6.0+
    static let memberImportVisibility: Self = .enableUpcomingFeature("MemberImportVisibility")  // SE-0444, Swift 6.1,  SwiftPM 6.1+
    static let inferIsolatedConformances: Self = .enableUpcomingFeature("InferIsolatedConformances")  // SE-0470, Swift 6.2,  SwiftPM 6.2+
    static let nonisolatedNonsendingByDefault: Self = .enableUpcomingFeature("NonisolatedNonsendingByDefault")  // SE-0461, Swift 6.2,  SwiftPM 6.2+
    static let immutableWeakCaptures: Self = .enableUpcomingFeature("ImmutableWeakCaptures")  // SE-0481, Swift 6.2,  SwiftPM 6.2+
}

extension SwiftSetting: @retroactive CaseIterable {
    public static var allCases: [Self] {
        [
            .existentialAny,
            .internalImportsByDefault,
            .memberImportVisibility,
            .inferIsolatedConformances,
            .nonisolatedNonsendingByDefault,
            .immutableWeakCaptures,
        ]
    }
}

package.targets
    .filter { ![.system, .binary, .plugin].contains($0.type) }
    .forEach { $0.swiftSettings = SwiftSetting.allCases }
