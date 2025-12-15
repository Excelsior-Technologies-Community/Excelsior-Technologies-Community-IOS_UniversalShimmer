//
//  UniversalShimmer.swift
//  DeliveryTrackingSystem
//
//  Created by Noman belim on 11/12/25.
//
 
import SwiftUI
import Network

// MARK: - Shimmer Configuration

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


// MARK: - Shimmer Modifier (Improved)

public struct ShimmerModifier: ViewModifier {
    
    @State private var offset: CGFloat = -2
    let active: Bool
    let config: ShimmerConfig

    public func body(content: Content) -> some View {
        content
            .overlay(
                active ? shimmer(content: content) : nil
            )
    }

    private func shimmer(content: Content) -> some View {
        GeometryReader { geo in
            
            let size = geo.size
            
            let gradient = LinearGradient(
                colors: [
                    config.baseColor.opacity(0.3),
                    config.highlightColor.opacity(1),
                    config.baseColor.opacity(0.3),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            let animatedView = gradient
                .frame(width: size.width * 1.6, height: size.height * 1.6)
                .offset(x: xOffset(size), y: yOffset(size))
                .blur(radius: 1.5)
                .opacity(config.opacity)
                .animation(.linear(duration: config.speed).repeatForever(autoreverses: false), value: offset)

            Rectangle()
                .fill(config.baseColor)
                .overlay(animatedView.blendMode(.plusLighter))
                .mask(content)
                .onAppear { startAnimation() }
        }
    }
    
    private func startAnimation() {
        offset = 2
    }
    
    private func xOffset(_ size: CGSize) -> CGFloat {
        switch config.direction {
        case .leftToRight: return -size.width * offset
        case .rightToLeft: return size.width * offset
        case .topToBottom, .bottomToTop: return 0
        }
    }

    private func yOffset(_ size: CGSize) -> CGFloat {
        switch config.direction {
        case .topToBottom: return -size.height * offset
        case .bottomToTop: return size.height * offset
        case .leftToRight, .rightToLeft: return 0
        }
    }
}


// MARK: - Public Shimmer Extension

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
