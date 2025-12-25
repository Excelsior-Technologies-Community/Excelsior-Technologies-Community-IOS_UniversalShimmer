import SwiftUI
import Network

// MARK: - Shimmer Configuration Model

public struct ShimmerConfig: Equatable {
    
    public enum Direction: Equatable {
        case leftToRight, rightToLeft, topToBottom, bottomToTop
    }
    
    public var baseColor: Color
    public var highlightColor: Color
    public var speed: Double
    public var opacity: Double
    public var direction: Direction
    public var gradientWidth: CGFloat
    public var blendMode: BlendMode
    
    public init(
        baseColor: Color = Color.gray.opacity(0.3),
        highlightColor: Color = Color.white.opacity(0.8),
        speed: Double = 1.5,
        opacity: Double = 1.0,
        direction: Direction = .leftToRight,
        gradientWidth: CGFloat = 0.3,
        blendMode: BlendMode = .screen
    ) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.speed = speed
        self.opacity = opacity
        self.direction = direction
        self.gradientWidth = gradientWidth
        self.blendMode = blendMode
    }
    
    // Preset configurations for common use cases
    public static let `default` = ShimmerConfig()
    
    public static let subtle = ShimmerConfig(
        baseColor: Color.gray.opacity(0.2),
        highlightColor: Color.white.opacity(0.5),
        speed: 2.0,
        gradientWidth: 0.25
    )
    
    public static let bright = ShimmerConfig(
        baseColor: Color.gray.opacity(0.4),
        highlightColor: Color.white.opacity(1.0),
        speed: 1.2,
        gradientWidth: 0.35
    )
    
    public static let fast = ShimmerConfig(
        speed: 0.8,
        gradientWidth: 0.25
    )
    
    public static let slow = ShimmerConfig(
        speed: 2.5,
        gradientWidth: 0.4
    )
    
    public static let vertical = ShimmerConfig(
        direction: .topToBottom
    )
}

// MARK: - Shimmer Modifier

public struct ShimmerModifier: ViewModifier {
    
    @State private var phase: CGFloat = 0
    let active: Bool
    let config: ShimmerConfig
    
    public init(active: Bool, config: ShimmerConfig = .default) {
        self.active = active
        self.config = config
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if active {
                        shimmerOverlay(content: content)
                    }
                }
            )
            .onAppear {
                if active {
                    startAnimation()
                }
            }
    }

    private func shimmerOverlay(content: Content) -> some View {
        GeometryReader { geometry in
            let (startPoint, endPoint) = gradientPoints
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: config.baseColor.opacity(0), location: 0),
                            .init(color: config.baseColor.opacity(0), location: max(0, phase - config.gradientWidth)),
                            .init(color: config.highlightColor, location: phase),
                            .init(color: config.baseColor.opacity(0), location: min(1, phase + config.gradientWidth)),
                            .init(color: config.baseColor.opacity(0), location: 1)
                        ]),
                        startPoint: startPoint,
                        endPoint: endPoint
                    )
                )
                .blendMode(config.blendMode)
                .opacity(config.opacity)
        }
        .mask(content)
    }
    
    private var gradientPoints: (UnitPoint, UnitPoint) {
        switch config.direction {
        case .leftToRight:
            return (.leading, .trailing)
        case .rightToLeft:
            return (.trailing, .leading)
        case .topToBottom:
            return (.top, .bottom)
        case .bottomToTop:
            return (.bottom, .top)
        }
    }

    private func startAnimation() {
        withAnimation(
            .linear(duration: config.speed)
            .repeatForever(autoreverses: false)
        ) {
            phase = 1
        }
    }
}

// MARK: - Skeleton Shape Modifier

public struct SkeletonModifier: ViewModifier {
    let active: Bool
    let config: ShimmerConfig
    let cornerRadius: CGFloat
    
    public init(active: Bool, config: ShimmerConfig = .default, cornerRadius: CGFloat = 4) {
        self.active = active
        self.config = config
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        if active {
            content
                .redacted(reason: .placeholder)
                .modifier(ShimmerModifier(active: true, config: config))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
        }
    }
}

// MARK: - Network Monitor

public class NetworkMonitor: ObservableObject {
    @Published public var isConnected: Bool = true
    @Published public var connectionType: NWInterface.InterfaceType?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.shimmer.networkmonitor")

    public init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - View Extensions

public extension View {
    
    @ViewBuilder
    func shimmerSkeleton(
        active: Bool,
        config: ShimmerConfig = .default,
        cornerRadius: CGFloat = 4
    ) -> some View {
        modifier(SkeletonModifier(active: active, config: config, cornerRadius: cornerRadius))
    }
     
    func shimmer(
        active: Bool = true,
        config: ShimmerConfig = .default
    ) -> some View {
        modifier(ShimmerModifier(active: active, config: config))
    }
     
    func shimmerWhenOffline(
        networkMonitor: NetworkMonitor,
        config: ShimmerConfig = .default
    ) -> some View {
        shimmerSkeleton(active: !networkMonitor.isConnected, config: config)
    }
}

// MARK: - Shimmer Shape Views (Pre-built Components)

public struct ShimmerShape: View {
    let config: ShimmerConfig
    let cornerRadius: CGFloat
    
    public init(config: ShimmerConfig = .default, cornerRadius: CGFloat = 8) {
        self.config = config
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(config.baseColor)
            .shimmer(config: config)
    }
}

public struct ShimmerCircle: View {
    let config: ShimmerConfig
    
    public init(config: ShimmerConfig = .default) {
        self.config = config
    }
    
    public var body: some View {
        Circle()
            .fill(config.baseColor)
            .shimmer(config: config)
    }
}

public struct ShimmerText: View {
    let lineCount: Int
    let config: ShimmerConfig
    
    public init(lineCount: Int = 3, config: ShimmerConfig = .default) {
        self.lineCount = lineCount
        self.config = config
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<lineCount, id: \.self) { index in
                ShimmerShape(config: config, cornerRadius: 4)
                    .frame(height: 16)
                    .frame(maxWidth: index == lineCount - 1 ? .infinity * 0.7 : .infinity)
            }
        }
    }
}

public struct ShimmerCard: View {
    let config: ShimmerConfig
    let cornerRadius: CGFloat
    
    public init(config: ShimmerConfig = .default, cornerRadius: CGFloat = 12) {
        self.config = config
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ShimmerCircle(config: config)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 6) {
                    ShimmerShape(config: config, cornerRadius: 4)
                        .frame(height: 16)
                    ShimmerShape(config: config, cornerRadius: 4)
                        .frame(height: 14)
                        .frame(maxWidth: .infinity * 0.6)
                }
            }
            
            ShimmerShape(config: config, cornerRadius: 8)
                .frame(height: 120)
            
            ShimmerText(lineCount: 2, config: config)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - List Extensions

public extension View {
    
    func shimmerList<Content: View>(
        count: Int,
        config: ShimmerConfig = .default,
        @ViewBuilder itemBuilder: @escaping () -> Content
    ) -> some View {
        ForEach(0..<count, id: \.self) { _ in
            itemBuilder()
        }
    }
}
