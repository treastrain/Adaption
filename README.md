# Adaption

Dependency Injection library for Swift projects inspired by SwiftUI's `Environment` and `EnvironmentValues`.

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/treastrain/Adaption/blob/main/LICENSE)
![Platform: iOS & iPadOS|macOS|tvOS|watchOS|visionOS|Linux|Windows](https://img.shields.io/badge/Platform-iOS%20%26%20iPadOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)
![Swift: 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager) \
[![X (formerly Twitter): @treastrain](https://img.shields.io/twitter/follow/treastrain?label=%40treastrain&style=social)](https://x.com/treastrain)

# Usage

```swift
import Adaption

struct Example1 {
    @Adaptor(\.named) private var named
    
    func run() {
        print(named.name) // "John Appleseed"
        
        AdaptedValues[\.named] = Robot()
        
        print(named.name) // "HAL 9000"
        
        Example2().run()
    }
}

struct Example2 {
    @Adaptor(\.named) private var named
    
    func run() {
        print(named.name) // "HAL 9000"
    }
}
```

<details>

<summary>Protocol and conformance, Definition of <code>AdaptedValues</code></summary>

```swift
protocol Named: Sendable {
    var name: String { get }
}

struct Person: Named {
    let name = "John Appleseed"
}

struct Robot: Named {
    let name = "HAL 9000"
}
```

```swift
import Adaption

extension AdaptedValues {
    var named: any Named {
        get { Self[NamedKey.self] }
        set { Self[NamedKey.self] = newValue }
    }
    
    private struct NamedKey: AdaptionKey {
        typealias Value = any Named
        static var defaultValue: Value { Person() }
    }
}
```

</details>
