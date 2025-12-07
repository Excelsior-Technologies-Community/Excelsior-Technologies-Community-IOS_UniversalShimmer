// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UniversalShimmer",
    
    // Minimum iOS version your shimmer supports
    platforms: [
        .iOS(.v14)
    ],
    
    // Public product that users import
    products: [
        .library(
            name: "UniversalShimmer",
            targets: ["UniversalShimmer"]
        )
    ],
    
    // Targets describe where the source code lives
    targets: [
        .target(
            name: "UniversalShimmer",
            dependencies: [],
            path: "Sources/UniversalShimmer",   // ← IMPORTANT
            sources: ["."],
            resources: []
        ),
        
        .testTarget(
            name: "UniversalShimmerTests",
            dependencies: ["UniversalShimmer"],
            path: "Tests/UniversalShimmerTests"
        )
    ]
)
