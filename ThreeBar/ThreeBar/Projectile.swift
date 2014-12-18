//
//  Projectile.swift
//  ThreeBar
//
//  Created by Marquez, Richard A on 12/17/14.
//  Copyright (c) 2014 Richard Marquez. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile: Actor {
    
    init() {
        super.init(texture: SKTexture(imageNamed: _magic.get("projectileSprite") as String),
            color: UIColor.greenColor(),
            size: CGSize(width: _magic.get("projectileSize") as CGFloat, height: _magic.get("projectileSize") as CGFloat))
        
        zPosition = 1000
        name = "projectileNode"
        physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        
    }
    
    func move(location: CGPoint, map: GameScene) {
        // Get center point of left side of screen
        //let controlCenter = CGPoint(x: (map.size.width / 2) / 2, y: map.size.height / 2)
        let controlCenter = CGPoint(x: _magic.get("controlCenter") as CGFloat, y: _magic.get("controlCenter") as CGFloat)
        
        // Calculate azimuth of location from center
        let magicDistance = CGFloat(500)
        let newLocation = ((location - controlCenter).normalized() * magicDistance) + position
        
        // Using moveTo() rather than manually updating position for smoother animation
        let moveAction = SKAction.moveTo(newLocation, duration: NSTimeInterval(_magic.get("projectileSpeed") as Float))
        runAction(moveAction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}