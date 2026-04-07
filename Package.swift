// swift-tools-version: 5.9
import PackageDescription

// NOTE on iOS distribution:
// The OneTrust CMP SDK is distributed via CocoaPods (pod
// "OneTrust-CMP-XCFramework"), which is the path used by MABS / OutSystems.
// The podspec in this repo declares that dependency.
//
// This Package.swift mirrors the diagnostic-capacitor SPM layout for
// structural consistency, but it does NOT pull the OneTrust SDK itself.
// CmpModule.swift uses `#if canImport(OTPublishersHeadlessSDK)` so the Swift
// target compiles cleanly under either path:
//   - Under CocoaPods (with the OneTrust pod): full functionality.
//   - Under bare SPM (without the OneTrust pod): methods reject at runtime
//     with "OneTrust SDK not linked".
//
// If you want first-class SPM support, add the OneTrust SDK as an SPM package
// dependency below and link the product into the OneTrustPlugin target.

let package = Package(
    name: "NoesisOneTrustCapacitor",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NoesisOneTrustCapacitor",
            targets: ["OneTrustPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "OneTrustPluginObjC",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/OneTrustPluginObjC",
            publicHeadersPath: "."
        ),
        .target(
            name: "OneTrustPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                "OneTrustPluginObjC"
            ],
            path: "ios/Sources/OneTrustPlugin"
        )
    ]
)
