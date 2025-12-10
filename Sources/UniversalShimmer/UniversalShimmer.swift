//
//  UniversalShimmer.swift
//  Shimmer
//
//  Created by Noman belim on 07/12/25.
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
        baseColor: Color = Color.gray.opacity(0.28),
        highlightColor: Color = Color.white.opacity(0.65),
        speed: Double = 1.0,
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
                            config.highlightColor.opacity(0.8),
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




// MARK: - Public View Extension

public extension View {
    func shimmer(
        active: Bool = true,
        config: ShimmerConfig = .default
    ) -> some View {
        self.modifier(ShimmerModifier(active: active, config: config))
    }
}


 
class ProductViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var products: [String] = []   // Example data
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.products = ["Cream", "Lotion", "Facewash", "Serum"]
            self.isLoading = false
        }
    }
}

public extension View {
    
    /// Shows shimmer when active, and hides the real content.
    @ViewBuilder
    func shimmerPlaceholder(
        active: Bool,
        config: ShimmerConfig = .default
    ) -> some View {
        if active {
            self
                .hidden()        // hide real content
                .shimmer(active: true, config: config)
        } else {
            self                // show real content
        }
    }
}



class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
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
            self
                .hidden()
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(config.baseColor)
                        .modifier(ShimmerModifier(active: true, config: config))
                )
        } else {
            self
        }
    }
}




