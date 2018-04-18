//
//  GameElements.swift
//  WireLoop
//
//  Created by Yas Abdolmaleki on 2018-04-17.
//  Copyright © 2018 Yas Marcu. All rights reserved.
//

import Foundation
import SpriteKit

// physics body in a scene - up to 32 different categories
struct CollisionBitMask {
    static let probeCategory:UInt32 = 0x1 << 0
    static let wireCategory:UInt32 = 0x1 << 1
    static let groundCategory:UInt32 = 0x1 << 0
}

extension GameScene {
}
