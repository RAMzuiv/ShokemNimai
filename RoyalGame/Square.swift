//
//  Square.swift
//  RoyalGame
//
//  Created by Mikkel on 5/18/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit

class Square: SKSpriteNode {
    var data: GameData! // Reference to the data model for the game
    var number: Int // 1-4 for either player's home row, 5-12 for middle lane, 13-14 for each player's final strech
    var playerSide: Int // -1 for P1, 0 for middle of board, 1 for P2
    //let touchEvent: ((Int, Int, UITouch) -> ())!
    let gameScene: GeneralScene!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        //touchEvent(number, playerSide, touches.first!)
        //print(data.availableTypes)
        gameScene.onSquareTouch(at: number, side: playerSide, touch: touches.first!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        gameScene.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        gameScene.touchesEnded(touches, with: event)
    }
    
    init(scene: GeneralScene, size: CGSize, at pos: Int, side: Int/*, touchEvent: @escaping (_ rank: Int, _ side: Int, _ touch: UITouch) -> ()*/){
        let color = SKColor(red: 0, green: 0, blue: 0, alpha: 0) //Transparent
        self.number = pos
        self.playerSide = side
        //self.touchEvent = touchEvent
        self.gameScene = scene
        super.init(texture: nil, color: color, size: size)
    }
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
}
