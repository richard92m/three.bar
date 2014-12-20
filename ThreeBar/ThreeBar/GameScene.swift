//
//  GameScene.swift
//  ThreeBar
//
//  Created by Marquez, Richard A on 12/13/14.
//  Copyright (c) 2014 Richard Marquez. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let hero       = Hero()
    var mobs       = [Mob]()
    var score: Int = 0
    let scoreLabel = SKLabelNode()
    let startTime  = NSDate()
    
    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onMotionShake:", name:"MotionShake", object: nil)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        addHero()
        addScoreLabel()
        addMoveControl()
        
        populateWithMobs()
    }
    
    func addMoveControl() {
        let moveControl = SKSpriteNode(texture: SKTexture(imageNamed: _magic.get("controlImage") as String),
            color: UIColor.yellowColor(),
            size: CGSize(width: _magic.get("heroSize") as CGFloat, height: _magic.get("heroSize") as CGFloat))
        
        moveControl.position = CGPoint(x: _magic.get("controlCenter") as CGFloat, y: _magic.get("controlCenter") as CGFloat)
        
        addChild(moveControl)
    }
    

    func getRandomPosition(fromPoint: CGPoint = CGPoint(), minDistance: CGFloat = 0.0) -> CGPoint {
        var possiblePosition: CGPoint
        var possibleLength: CGFloat
        var currentLength = fromPoint.length()
        var distance: CGFloat = 0.0
        
        do {
            possiblePosition = CGPoint(x: CGFloat(size.width) * (CGFloat(arc4random()) / CGFloat(UInt32.max)),
                y: CGFloat(size.height) * (CGFloat(arc4random()) / CGFloat(UInt32.max)))
            
            possibleLength = possiblePosition.length()
            distance = abs(currentLength - possibleLength)
        } while distance < CGFloat(minDistance)
        
        return possiblePosition
    }
    
    func addHero() {
        hero.position = getRandomPosition()
        
        addChild(hero)
    }
    
    func populateWithMobs() {
        let m1 = Mob()
        m1.position = getRandomPosition(fromPoint: hero.position, minDistance: _magic.get("mobMinDistance") as CGFloat)
        
        let m2 = Mob()
        m2.position = getRandomPosition(fromPoint: hero.position, minDistance: _magic.get("mobMinDistance") as CGFloat)
        
        let m3 = Mob()
        m3.position = getRandomPosition(fromPoint: hero.position, minDistance: _magic.get("mobMinDistance") as CGFloat)
        
        mobs.append(m1)
        mobs.append(m2)
        mobs.append(m3)
        
        for mob in mobs {
            addChild(mob)
        }
        
    }
    
    func changeScore(changeBy: Int) {
        score += changeBy
        scoreLabel.text = String(score)
    }
    
    func addScoreLabel() {
        scoreLabel.fontName = _magic.get("scoreFont") as String
        scoreLabel.name     = "scoreLabel"
        scoreLabel.text     = String(score)
        scoreLabel.fontSize = _magic.get("scoreSize") as CGFloat
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: 10)
        
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            // Move if left side touched
            if location.x < size.width / 2 {
                hero.moving = true
                hero.facing = getFacingDirection(location)
            } else {
                // Shoot if right side touched
                hero.shoot(self)
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            // Stop moving hero when control no longer held
            if location.x < size.width / 2 {
                hero.moving = false
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            // Continuously move hero if touch is held on left side
            if location.x < size.width / 2 {
                hero.facing = getFacingDirection(location)
            }
        }
    }
    
    // Teleport hero on shake
    func onMotionShake(notification: NSNotification) {
        hero.teleport(self)
    }
    
    func getFacingDirection(touchLocation: CGPoint) -> CGPoint {
        let controlCenter = CGPoint(x: _magic.get("controlCenter") as CGFloat, y: _magic.get("controlCenter") as CGFloat)
        
        let facingDirection = (touchLocation - controlCenter).normalized()
        
        return facingDirection
    }
    
    func heroDidCollideWithMob(mob: Mob) {
        endgame()
    }
    
    func laserDidCollideWithHero(laser: Laser) {
        laser.removeFromParent()
    }
    
    func laserDidCollideWithMob(laser: Laser, mob: Mob) {
        killMob(mob)
        laser.removeFromParent()
    }
    
    func laserDidCollideWithWall(laser: Laser) {
        laser.physicsBody?.categoryBitMask = PhysicsCategory.ReturnLaser
        laser.comeBack(hero, map: self)
    }
    
    func killMob(mob: Mob) {
        mob.removeFromParent()
        
        var i = 0
        for inArray in mobs {
            if inArray == mob {
                mobs.removeAtIndex(i)
                
                changeScore(100)
                
                if mobs.count == 0 {
                    endgame()
                }
            }
            
            ++i
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Put bodies in ascending PhysicsCategory order
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // First, ensure both nodes are valid
        switch (firstBody.node?, secondBody.node?) {
        case let (.Some(firstNode), .Some(secondNode)):
            
            switch firstBody.categoryBitMask {
                
            case PhysicsCategory.Hero:
                switch secondBody.categoryBitMask {
                case PhysicsCategory.Mob:
                    heroDidCollideWithMob(secondNode as Mob)
                    
                case PhysicsCategory.ReturnLaser:
                    laserDidCollideWithHero(secondNode as Laser)
                    
                default:
                    println("No matches for hero contact")
                }
                
            case PhysicsCategory.Mob:
                switch secondBody.categoryBitMask {
                case PhysicsCategory.Laser:
                    laserDidCollideWithMob(secondNode as Laser, mob: firstNode as Mob)
                    
                default:
                    println("No matches for mob contact")
                }
                
            case PhysicsCategory.Wall:
                switch secondBody.categoryBitMask {
                case PhysicsCategory.Laser:
                    laserDidCollideWithWall(secondNode as Laser)
                    
                default:
                    println("No matches for laser contact")
                }
                
            default:
                break
            }

            
        default:
            break
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if hero.moving {
            hero.move(self)
        }
    }
    
    func endgame() {
        hero.kill()
        
        if let scene = EndgameScene.unarchiveFromFile("EndgameScene") as? EndgameScene {
            if let skView = self.view {
                scene.score = score
                scene.startTime = startTime
                
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .AspectFill
                
                skView.presentScene(scene)
            }
        }
    }

}




