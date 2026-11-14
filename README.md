# Adaption

A lightweight dependency-injection library for Swift, inspired by SwiftUI's `Environment` and `EnvironmentValues`.

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/treastrain/Adaption/blob/main/LICENSE)
![Platform: iOS & iPadOS|macOS|tvOS|watchOS|visionOS|Linux|Windows](https://img.shields.io/badge/Platform-iOS%20%26%20iPadOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)
![Swift: 6.4](https://img.shields.io/badge/Swift-6.4-orange.svg)
[![Swift](https://github.com/treastrain/Adaption/actions/workflows/swift.yml/badge.svg)](https://github.com/treastrain/Adaption/actions/workflows/swift.yml)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager) \
[![X (formerly Twitter): @treastrain](https://img.shields.io/twitter/follow/treastrain?label=%40treastrain&style=social)](https://x.com/treastrain)

Adaption provides two independent dependency containers:

- `AdaptedValues` for `Sendable` dependencies shared safely across concurrency domains.
- `MainActorAdaptedValues` for dependencies that must stay on the main actor, such as UI-related services.

Both containers support global defaults, property-wrapper access, and task-local overrides for scoped work and tests.

## Requirements

- Swift 6.4 or later

## Installation

Add Adaption to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/treastrain/Adaption", from: "x.y.z"),
]
```

Then add the `Adaption` product to the target that uses it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Adaption", package: "Adaption"),
    ]
)
```

In Xcode, choose **File > Add Package Dependencies…** and enter `https://github.com/treastrain/Adaption`.

## Shared dependencies

Declare a `Sendable` dependency on `AdaptedValues` with `@Item`. The macro creates the storage key and accessors; its type may be explicit or inferred from the default value.

```swift
import Adaption

protocol APIClient: Sendable {
    func loadUser() async throws -> User
}

extension AdaptedValues {
    @Item var apiClient: any APIClient = LiveAPIClient()
}
```

Read a dependency with `@Adaptor`. The wrapper always reads the current value, so it also observes later global replacements.

```swift
struct ProfileViewModel {
    @Adaptor(\.apiClient) private var apiClient

    func refresh() async throws -> User {
        try await apiClient.loadUser()
    }
}
```

Set the process-wide value when configuring the app:

```swift
AdaptedValues[\.apiClient] = PreviewAPIClient()
```

### Scoped overrides

Use `withValue` for a task-local override. It takes precedence over the global value, is inherited by child tasks, and is automatically restored when the operation finishes—even when it throws.

```swift
let user = try await AdaptedValues.withValue(\.apiClient, MockAPIClient()) {
    try await ProfileViewModel().refresh()
}
```

Override several values together with `withValues`:

```swift
try await AdaptedValues.withValues {
    $0[override: \.apiClient] = MockAPIClient()
    $0[override: \.analytics] = NoopAnalytics()
} operation: {
    try await runFeature()
}
```

`withValue` also accepts a custom `AdaptionKey` type when an extension property is not appropriate.

```swift
private enum APIClientKey: AdaptionKey {
    static let defaultValue: any APIClient = LiveAPIClient()
}

let client = AdaptedValues[APIClientKey.self]
```

## Main-actor dependencies

For values that are not `Sendable` or must be accessed only on the main actor, use `MainActorAdaptedValues`. It has its own storage and its own task-local scope.

```swift
@MainActor
final class ImageCache {
    // UI-bound cache implementation
}

extension MainActorAdaptedValues {
    @Item var imageCache = ImageCache()
}

@MainActor
struct ImageViewModel {
    @MainActorAdaptor(\.imageCache) private var imageCache
}
```

`@Adaptor(\.imageCache)` is also available in a main-actor context. Use labels when both containers have similarly named properties:

```swift
@MainActor
struct Feature {
    @Adaptor(shared: \.apiClient) private var apiClient
    @Adaptor(mainActor: \.imageCache) private var imageCache
}
```

Scope a main-actor replacement in the same way:

```swift
@MainActor
func makePreview() {
    MainActorAdaptedValues.withValue(\.imageCache, ImageCache()) {
        // Code in this scope reads the replacement cache.
    }
}
```

For a custom main-actor key, conform to `MainActorAdaptionKey` instead of `AdaptionKey`.

## License

Adaption is available under the [MIT License](LICENSE).
