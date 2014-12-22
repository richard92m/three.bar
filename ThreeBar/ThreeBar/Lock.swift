//
//  Lock.swift
//  ThreeBar
//
//  Created by Marquez, Richard A on 12/21/14.
//  Copyright (c) 2014 Richard Marquez. All rights reserved.
//

import Foundation
import SpriteKit

class Lock: SKSpriteNode {
    var open = false
    
    override init() {
        let width = _magic.get("lockWidth") as CGFloat
        let height = _magic.get("lockHeight") as CGFloat
        let color = UIColor.purpleColor()
        
        super.init(texture: nil, color: color, size: CGSize(width: width, height: height))

    }
    
    func unlock() {
        open = true
        color = UIColor.greenColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}