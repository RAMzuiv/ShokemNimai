//
//  Button.swift
//  RoyalGame
//
//  Created by Mikkel on 10/9/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
    var action = ""
    let gameScene: TutorialScene!
    let textColor = SKColor(red: 100, green: 100, blue: 0, alpha: 100)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if action == "play" {
            gameScene.newGame()
        } else if action == "tutorial" {
            gameScene.nextphase()
        } else if action == "about" {
            gameScene.aboutScreen()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        
    }
    
    init(scene: TutorialScene, size: CGSize, pos: CGPoint, label: String, action: String){
        let color = SKColor(red: 100, green: 0, blue: 0, alpha: 100)
        self.gameScene = scene
        super.init(texture: nil, color: color, size: size)
        
        self.texture = SKTexture(imageNamed: "token menu")
        
        let text = SKLabelNode(fontNamed: "Futura")
        let txtLen = label.characters.count
        if txtLen <= 5 {
            text.fontSize = size.height/17 * 4
        } else {
            text.fontSize = size.height/17 * 3
        }
        text.verticalAlignmentMode = .center
        text.position = CGPoint(x: 0, y: 0)
        text.text = label
        text.fontColor = textColor
        text.zPosition = 5
        self.addChild(text)
        
        self.position = pos
        self.action = action
    }
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
}
