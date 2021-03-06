//
//  Actor.swift
//  ThreeBar
//
//  Created by Marquez, Richard A on 12/14/14.
//  Copyright (c) 2014 Richard Marquez. All rights reserved.
//

import Foundation
import SpriteKit

class Actor: SKSpriteNode {
    var facing = CGPoint(x: 1, y: 1)  // Default of 1 ensures projectiles move even if hero has not yet
    
    init(texture: SKTexture!, color: UIColor!, size: CGSize, position: CGPoint = CGPoint(x: 0, y: 0)) {
        super.init(texture: texture, color: color, size: size)
        
        zPosition = CGFloat(ZIndex.Actor.rawValue)
        self.position = position
        
        /*UIGraphicsBeginImageContext(size)
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        
        if size.width <= 0 || size.height <= 0 {
            println("too small...")
            self.size = CGSize(width: texture!.size().width, height: texture!.size().height)
        }*/
        
        setPhysics()
        
    }
    
    private func setPhysics() {
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        
        physicsBody?.dynamic                       = true
        physicsBody?.allowsRotation                = false
        physicsBody?.usesPreciseCollisionDetection = true
        
        physicsBody?.categoryBitMask    = PhysicsCategory.Actor
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile +
                                          PhysicsCategory.Actor +
                                          PhysicsCategory.Hero +
                                          PhysicsCategory.Mob +
                                          PhysicsCategory.Wall +
                                          PhysicsCategory.Lock
        physicsBody?.collisionBitMask   = PhysicsCategory.All   -
                                          PhysicsCategory.Actor -
                                          PhysicsCategory.Hero -
                                          PhysicsCategory.Mob -
                                          PhysicsCategory.Projectile -
                                          PhysicsCategory.Laser -
                                          PhysicsCategory.ReturnLaser -
                                          PhysicsCategory.Lock
    }
    
    func moveActionInDirection(direction: CGPoint, distance: CGFloat, speed: NSTimeInterval) -> SKAction {
        let newLocation = (direction * distance) + position
        
        // Using moveTo() rather than manually updating position for smoother animation
        return SKAction.moveTo(newLocation, duration: speed)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}