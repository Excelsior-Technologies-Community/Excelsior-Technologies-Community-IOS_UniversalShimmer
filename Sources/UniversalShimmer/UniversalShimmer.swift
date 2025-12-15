//
//  UniversalShimmer.swift
//  DeliveryTrackingSystem
//
//  Created by Noman belim on 11/12/25.
//

import Foundation
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


// MARK: - Shimmer Modifier

public struct ShimmerModifier: ViewModifier {
    
    @State private var moveTo: CGFloat = -1
    let active: Bool
    let config: ShimmerConfig

    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if active {
                        shimmerOverlay(content: content)
                            .onAppear { start() }
                    }
                }
            )
    }

    private func shimmerOverlay(content: Content) -> some View {
        GeometryReader { geo in
            let size = geo.size
            
            Rectangle()
                .fill(config.baseColor)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            config.baseColor.opacity(0.2),
                            config.highlightColor.opacity(0.9),
                            config.baseColor.opacity(0.2)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: size.width * 1.2)
                    .offset(x: size.width * moveTo)
                    .blendMode(.lighten)
                )
                .mask(content)
        }
    }

    private func start() {
        withAnimation(.linear(duration: config.speed).repeatForever(autoreverses: false)) {
            moveTo = 1.2
        }
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

public extension View {
    @ViewBuilder
    func shimmerSkeleton(
        active: Bool,
        config: ShimmerConfig = .default
    ) -> some View {
        if active {
            ZStack {
                self.hidden()

                Rectangle()
                    .fill(config.baseColor)
                    .modifier(ShimmerModifier(active: true, config: config))
                    .mask(self)
            }
        } else {
            self
        }
    }
}


