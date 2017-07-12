//
//  WinScene.swift
//  RoyalGame
//
//  Created by Mikkel on 5/29/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit

class WinScene: SKScene {
    let Controller: GameViewController!
    
    let P1Colour = SKColor(red: 0.8, green: 0, blue: 0, alpha: 1) // Red for player 1
    let P2Colour = SKColor(red: 0, green: 0.7, blue: 0, alpha: 1) // Green for player 2
    let P1BG = SKColor(red: 1, green: 0.6, blue: 0.6, alpha: 1)
    let P2BG = SKColor(red: 0.6, green: 1, blue: 0.6, alpha: 1)
    let BGColour = SKColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1) // Background colour
    let TextColour = SKColor.black
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Controller.newGame()
    }
    
    init(winner: Int, size: CGSize, controller: GameViewController) {
        Controller = controller
        
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let text1 = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        text1.fontSize=size.height/8
        text1.verticalAlignmentMode = .center
        text1.position = CGPoint(x: -size.width*3/24, y: size.height*5/24)
        self.addChild(text1)
        
        let text2 = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        text2.fontSize=size.height/8
        text2.verticalAlignmentMode = .center
        text2.zRotation = .pi
        text2.position = CGPoint(x: size.width*3/24, y: -size.height*5/24)
        self.addChild(text2)
        
        self.backgroundColor = BGColour // Set the background to the background colour
        
        var fontColor = TextColour
        if winner == 1 {
            text1.text = "Red Wins!"
            text2.text = "Red Wins!"
            self.backgroundColor = P1BG
            fontColor = P1Colour
        } else if winner == 2 {
            text1.text = "Green Wins!"
            text2.text = "Green Wins!"
            self.backgroundColor = P2BG
            fontColor = P2Colour
        }
        text1.fontColor = fontColor
        text2.fontColor = fontColor
    }
}
