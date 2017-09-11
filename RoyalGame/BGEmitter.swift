//
//  BGEmitter.swift
//  RoyalGame
//
//  Created by Mikkel on 7/28/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import Foundation
import SpriteKit

class BGEmitter {
    var vel: (CGFloat, CGFloat)! // Velocity
    var angV: CGFloat! // Angular velocity
    let scrSize: CGSize! // The size of the screen
    let maxAngV: CGFloat = 0.0002 // The maximum angular velocity
    let maxVel: CGFloat = 0.6
    let minVel: CGFloat = 0.1
    var blendRects: [SKSpriteNode]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(size: CGSize, darkMode: Bool = false) {
        scrSize = size
        angV = maxAngV*(randFloat()-0.5)*2
        let thetaVel = .pi*2*randFloat() // The initial angle of the velocity
        vel = (maxVel*cos(thetaVel), maxVel*sin(thetaVel))
        blendRects = []
        for i in [0, 1] {
            blendRects.append(SKSpriteNode(texture: nil, color: SKColor(0.1, 0.2, 0.23), size: CGSize(width: 5000, height: 5000)))
            blendRects[i].anchorPoint = CGPoint(x: 0.5, y: 1)
            blendRects[i].blendMode = .screen
            blendRects[i].zPosition = 0
            blendRects[i].alpha = 0.45
            if darkMode {
                blendRects[i].alpha = 0.3
            }
        }
        //let xpos = scrSize.width*CGFloat(arc4random())/CGFloat(UINT32_MAX) - scrSize.width/2
        //let ypos = scrSize.height*CGFloat(arc4random())/CGFloat(UINT32_MAX) - scrSize.height/2
        let xpos = scrSize.width*randFloat() - scrSize.width/2
        let ypos = scrSize.height*randFloat() - scrSize.height/2
        blendRects[0].position = CGPoint(x: xpos, y: ypos)
        blendRects[0].zRotation = 2 * .pi * randFloat()
        blendRects[1].position = CGPoint(x: -xpos, y: -ypos)
        blendRects[1].zRotation = blendRects[0].zRotation + .pi
    }
    
    func update() {
        blendRects[0].zRotation += angV // Apply the angular velocity
        blendRects[1].zRotation = blendRects[0].zRotation + .pi
        blendRects[0].position.x += vel.0 // Apply the positional velocity
        blendRects[0].position.y += vel.1 // Apply position velocity
        blendRects[1].position.x = -blendRects[0].position.x
        blendRects[1].position.y = -blendRects[0].position.y
        // If the particle gets close to the edge of the screen, push it back towards the center
        if blendRects[0].position.x < scrSize.width * -9 / 20 { // -9/20 is close to -1/2, which is the left side of the screen
            vel.0 += 0.05
        } else if blendRects[0].position.x > scrSize.width * 9 / 20 { // 9/20 is close to 1/2, which is the right side of the screen
            vel.0 -= 0.05
        }
        if blendRects[0].position.y < scrSize.height * -9 / 20 { // -9/20 is close to -1/2, which is the left side of the screen
            vel.1 += 0.05
        } else if blendRects[0].position.y > scrSize.height * 9 / 20 { // 9/20 is close to 1/2, which is the right side of the screen
            vel.1 -= 0.05
        }
        let speed = Float(vel.0)^^2 + Float(vel.1)^^2
        if speed > Float(maxVel)^^2 {
            vel.0 *= 0.95
            vel.1 *= 0.95
        }
    }
    
    /*
    func randFloat() -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UINT32_MAX)
    }
     */
}
