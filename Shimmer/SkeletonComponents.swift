//
//  SkeletonComponents.swift
//  Shimmer
//
//  Created by Noman belim on 07/12/25.
//

import SwiftUI

// MARK: - Skeleton Text Placeholder

public struct SkeletonText: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let config: ShimmerConfig
    let active: Bool
    
    public init(width: CGFloat = 150, height: CGFloat = 16, cornerRadius: CGFloat = 8, active: Bool = true, config: ShimmerConfig = .default) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.active = active
        self.config = config
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.25))
            .frame(width: width, height: height)
            .shimmer(active: active, config: config)
    }
}


// MARK: - Skeleton Avatar

public struct SkeletonAvatar: View {
    let size: CGFloat
    let active: Bool
    let config: ShimmerConfig
    
    public init(size: CGFloat = 60, active: Bool = true, config: ShimmerConfig = .default) {
        self.size = size
        self.active = active
        self.config = config
    }
    
    public var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: size, height: size)
            .shimmer(active: active, config: config)
    }
}


// MARK: - Skeleton Card

public struct SkeletonCard: View {
    let active: Bool
    let config: ShimmerConfig
    
    public init(active: Bool = true, config: ShimmerConfig = .default) {
        self.active = active
        self.config = config
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonAvatar(size: 80, active: active, config: config)
            
            SkeletonText(width: 180, active: active, config: config)
            SkeletonText(width: 120, active: active, config: config)
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(16)
        .shimmer(active: active, config: config)
    }
}

 
