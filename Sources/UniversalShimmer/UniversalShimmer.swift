//
//  UniversalShimmer.swift
//  
//

import SwiftUI
import Network

// MARK: - Shimmer Config

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
        highlightColor: Color = Color.white.opacity(0.85),
        speed: Double = 1.35,
        opacity: Double = 1.0,
        direction: Direction = .leftToRight
    ) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.speed = speed
        this.opacity = opacity
        self.direction = direction
    }
    
    public static let `default` = ShimmerConfig()
}


// MARK: - Perfect Shimmer Modifier (FINAL VERSION)

public struct ShimmerModifier: ViewModifier {
    
    @State private var move: CGFloat = -1
    let active: Bool
    let config: ShimmerConfig

    public func body(content: Content) -> some View {
        ZStack {
            // BASE FILL (Fixes your black color issue)
            content
                .foregroundColor(.clear)
                .background(config.baseColor)

            if active {
                shimmerLayer(content: content)
            }
        }
        .clipped()
    }

    private func shimmerLayer(content: Content) -> some View {
        GeometryReader { geo in
            let size = geo.size

            // Smooth diagonal highlight
            let gradient = LinearGradient(
                gradient: Gradient(colors: [
                    config.baseColor.opacity(0.1),
                    config.highlightColor.opacity(0.6),
                    config.highlightColor.opacity(1),
                    config.highlightColor.opacity(0.6),
                    config.baseColor.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Rectangle()
                .fill(gradient)
                .frame(width: size.width * 2.4, height: size.height * 2.4)
                .rotationEffect(.degrees(25))
                .offset(x: size.width * move, y: size.height * move)
                .animation(
                    .linear(duration: config.speed)
                        .repeatForever(autoreverses: false),
                    value: move
                )
                .mask(content)
                .onAppear { move = 1.8 }
        }
    }
}


// MARK: - Public Shimmer Extension

public extension View {
    func shimmerSkeleton(active: Bool, config: ShimmerConfig = .default) -> some View {
        modifier(ShimmerModifier(active: active, config: config))
    }
}


// MARK: - Network Monitor

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
