import SwiftUI

@available(iOS 15.0, *)
struct ShimmerEffectView: View {
    let isActive: Bool
    let speed: CGFloat
    let colors: [Color]
    
    @State private var offset: CGFloat = -1
    
    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(20))
            .offset(x: geo.size.width * offset)
            .onAppear {
                if isActive {
                    animate()
                }
            }
            .onChange(of: isActive) { active in
                if active {
                    animate()
                } else {
                    offset = -1
                }
            }
        }
    }
    
    private func animate() {
        withAnimation(
            .linear(duration: speed)
        ) {
            offset = 1.5
        }
    }
}

@available(iOS 15.0, *)
struct UniversalShimmerModifier: ViewModifier {
    let isActive: Bool
    let speed: CGFloat
    let colors: [Color]
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .opacity(0)
                .overlay {
                    ShimmerEffectView(
                        isActive: isActive,
                        speed: speed,
                        colors: colors.isEmpty
                            ? [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.3)
                              ]
                            : colors
                    )
                    .mask(content)
                }
        } else {
            content
        }
    }
}

public extension View {
    /// Universal shimmer that adapts to ANY content shape
    @ViewBuilder
    func universalShimmer(
        _ isActive: Bool,
        speed: CGFloat = 1.2,
        colors: [Color] = []
    ) -> some View {
        if #available(iOS 15.0, *) {
            modifier(
                UniversalShimmerModifier(
                    isActive: isActive,
                    speed: speed,
                    colors: colors
                )
            )
        } else {
            self
        }
    }
}
