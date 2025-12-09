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


// MARK: - Shimmer Modifier (Core Engine)

public struct ShimmerModifier: ViewModifier {
    
    @State private var progress: CGFloat = -1
    private let isActive: Bool
    private let config: ShimmerConfig
    
    public init(active: Bool, config: ShimmerConfig) {
        self.isActive = active
        self.config = config
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            if isActive {
                content.hidden()
                shimmerMask.mask(content)
                    .onAppear { animate() }
            } else {
                content
            }
        }
    }
    
    private var shimmerMask: some View {
        GeometryReader { geo in
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: config.baseColor, location: 0),
                    .init(color: config.highlightColor, location: 0.5),
                    .init(color: config.baseColor, location: 1)
                ]),
                startPoint: gradientStart,
                endPoint: gradientEnd
            )
            .opacity(config.opacity)
            .frame(width: geo.size.width * 3, height: geo.size.height * 3)
            .offset(offset(for: geo.size))
        }
    }
    
    private func animate() {
        withAnimation(.linear(duration: config.speed).repeatForever(autoreverses: false)) {
            progress = 2
        }
    }
    
    // MARK: Direction Handling
    
    private var gradientStart: UnitPoint {
        switch config.direction {
        case .leftToRight: return .leading
        case .rightToLeft: return .trailing
        case .topToBottom: return .top
        case .bottomToTop: return .bottom
        }
    }
    
    private var gradientEnd: UnitPoint {
        switch config.direction {
        case .leftToRight: return .trailing
        case .rightToLeft: return .leading
        case .topToBottom: return .bottom
        case .bottomToTop: return .top
        }
    }
    
    private func offset(for size: CGSize) -> CGSize {
        switch config.direction {
        case .leftToRight:
            return CGSize(width: -size.width * 2 + (size.width * progress), height: 0)
        case .rightToLeft:
            return CGSize(width: size.width * 2 - (size.width * progress), height: 0)
        case .topToBottom:
            return CGSize(width: 0, height: -size.height * 2 + (size.height * progress))
        case .bottomToTop:
            return CGSize(width: 0, height: size.height * 2 - (size.height * progress))
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
