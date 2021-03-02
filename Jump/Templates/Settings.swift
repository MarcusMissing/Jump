//
//  Settings.swift
//  Jump
//
//  Created by Marcus Mletzko on 26.02.21.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let squareCategory: UInt32 = 0x1             // 00001
    static let obstacleCategory: UInt32 = 0x1 << 1      // 00010
    static let floorCategory: UInt32 = 0x1 << 2         // 00100
    static let backWallCategory: UInt32 = 0x1 << 3      // 01000
    static let powerUpCategory: UInt32 = 0x1 << 4       // 10000
}

enum ZPositions {
    static let label: CGFloat = 0
    static let floor: CGFloat = 1
    static let obstacles: CGFloat = 2
    static let square: CGFloat = 2
}
