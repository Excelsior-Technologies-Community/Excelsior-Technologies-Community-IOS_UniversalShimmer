//
//  UniversalShimmer.swift
//  DeliveryTrackingSystem
//
//  Created by Noman belim on 11/12/25.
//
import SwiftUI
import Network 

// MARK: - Shimmer Configuration Model

public struct ShimmerConfig: Equatable {
    
    public enum Direction {
        case leftToRight, rightToLeft, topToBottom, bottomToTop
    }
    
    public var baseColor: Color
    public var highlightColor: Color
    public var speed: Double
    public var opacity: Double
    public var direction: Direction
    
    public init(
        baseColor: Color = Color.gray.opacity(0.25),
        highlightColor: Color = Color.white.opacity(0.7),
        speed: Double = 1.2,
        opacity: Double = 1.0,
        direction: Direction = .leftToRight
    ) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.speed = speed
        self.opacity = opacity
        self.direction = direction
    }
    
    public static let `default` = ShimmerConfig()
}


// MARK: - Shimmer Modifier (FIXED LOGIC)

public struct ShimmerModifier: ViewModifier {
    
    // Start at -1.0 (gradient off-screen left/top), End at 1.0 (gradient off-screen right/bottom)
    @State private var phase: CGFloat = -1.0
    
    let active: Bool
    let config: ShimmerConfig

    public func body(content: Content) -> some View {
        // The base content is rendered first
        content
            // Then the full-sized shimmer overlay is placed on top
            .overlay(
                Group {
                    if active {
                        shimmerOverlay()
                            .onAppear { startAnimation() }
                            // Only set the mask if we are actively shimmering
                            .mask(content)
                    }
                }
            )
    }

    private func shimmerOverlay() -> some View {
        GeometryReader { geo in
            let size = geo.size
            let gradientStartPoint: UnitPoint
            let gradientEndPoint: UnitPoint
            let isHorizontal: Bool
            
            switch config.direction {
            case .leftToRight, .rightToLeft:
                isHorizontal = true
                gradientStartPoint = .leading
                gradientEndPoint = .trailing
            case .topToBottom, .bottomToTop:
                isHorizontal = false
                gradientStartPoint = .top
                gradientEndPoint = .bottom
            }

            // 1. Base color fills the entire area
            Rectangle()
                .fill(config.baseColor)
                .overlay(
                    // 2. The moving Linear Gradient (The "highlight" beam)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            config.baseColor.opacity(0.0), // Transparent edge
                            config.highlightColor.opacity(0.9), // Bright center
                            config.baseColor.opacity(0.0) // Transparent edge
                        ]),
                        startPoint: gradientStartPoint,
                        endPoint: gradientEndPoint
                    )
                    // The frame of the gradient needs to be larger than the view to ensure
                    // the highlight beam is always visible when moving.
                    .frame(
                        width: isHorizontal ? size.width * 2 : size.width,
                        height: isHorizontal ? size.height : size.height * 2
                    )
                    // 3. Offset the gradient based on the animation phase
                    .offset(x: isHorizontal ? size.width * phase : 0,
                            y: isHorizontal ? 0 : size.height * phase)
                    .blendMode(.screen) // A blend mode that makes the highlight look brighter
                    .opacity(config.opacity)
                )
        }
    }
    
    private func startAnimation() {
        // Determine start and end points based on direction
        let start: CGFloat
        let end: CGFloat
        
        switch config.direction {
        case .leftToRight, .topToBottom:
            // Starts off-screen left/top (-1.0) and moves to off-screen right/bottom (1.0)
            start = -1.0
            end = 1.0
        case .rightToLeft, .bottomToTop:
            // Starts off-screen right/bottom (1.0) and moves to off-screen left/top (-1.0)
            start = 1.0
            end = -1.0
        }
        
        // Ensure the initial state is set
        DispatchQueue.main.async {
            self.phase = start
            // Animation moves the phase from start to end repeatedly
            withAnimation(.linear(duration: config.speed).repeatForever(autoreverses: false)) {
                self.phase = end
            }
        }
    }
}


// MARK: - View Extension (Simplified)

public extension View {
    @ViewBuilder
    func shimmerSkeleton(
        active: Bool,
        config: ShimmerConfig = .default
    ) -> some View {
        // Use the modifier directly on 'self' if active is true
        if active {
            self.modifier(ShimmerModifier(active: true, config: config))
        } else {
            self // Return the original view when inactive
        }
    }
}


// MARK: - Network Monitor (Retained)

public class NetworkMonitor: ObservableObject {
    @Published public var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    public init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
