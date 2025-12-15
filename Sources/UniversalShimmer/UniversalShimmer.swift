//
//  UniversalShimmer.swift
//  DeliveryTrackingSystem
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
        highlightColor: Color = Color.white.opacity(0.8),
        speed: Double = 1.4,
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


// MARK: - FINAL PERFECT SHIMMER MODIFIER (Facebook / YouTube Style)

public struct ShimmerModifier: ViewModifier {
    
    @State private var move: CGFloat = -1
    let active: Bool
    let config: ShimmerConfig

    public func body(content: Content) -> some View {
        content
            .overlay(
                active ? shimmerLayer(content: content) : nil
            )
    }

    private func shimmerLayer(content: Content) -> some View {
        GeometryReader { geo in
            let size = geo.size

            // Wide diagonal highlight band
            let gradient = LinearGradient(
                gradient: Gradient(colors: [
                    config.baseColor.opacity(0.2),
                    config.highlightColor.opacity(0.7),
                    config.highlightColor,
                    config.highlightColor.opacity(0.7),
                    config.baseColor.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Rectangle()
                .fill(gradient)
                .frame(width: size.width * 2.2, height: size.height * 2.2)
                .rotationEffect(.degrees(25))
                .offset(x: size.width * move, y: size.height * move)
                .animation(
                    .linear(duration: config.speed)
                        .repeatForever(autoreverses: false),
                    value: move
                )
                .mask(content)
                .onAppear { move = 1.6 }
        }
    }
}


// MARK: - Public Modifier

public extension View {
    func shimmerSkeleton(active: Bool, config: ShimmerConfig = .default) -> some View {
        modifier(ShimmerModifier(active: active, config: config))
    }
}


// MARK: - Network Monitor (unchanged)

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
