//
//  GameScene.swift
//  RoyalGame
//
//  Created by Mikkel on 5/13/17.
//  Copyright (c) 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: GeneralScene {
    let dice: SKSpriteNode
    var dieSize: CGFloat?
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
    
    override init(size: CGSize, data: GameData) {
        let tSize = size.width/9
        
        // Create the dice sprites
        //dice = SKSpriteNode(color: SKColor.black, size: CGSize(width: dieSize!+1, height: dieSize!+1))
        dice = SKSpriteNode(imageNamed: "P1Dice")
        
        super.init(size: size, data: data)
        
        // Add the tiles to the board
        for side in [1, 2]{
            for rank in (1...4) {
                addTile(at: rank, side: side, bigTile: rank==4)
            }
            for rank in [13, 14] {
                addTile(at: rank, side: side, bigTile: rank==13)
            }
        }
        for rank in (5...12) {
            addTile(at: rank, side: 0, bigTile: (rank==12)||(rank==5))
        }
        
        // Add the stock counters
        for player in [1,2] {
            let SBSize = (TileSize!*3, TileSize!*1)
            let stockBoxIn = SKSpriteNode(color: TileColour, size: CGSize(width: SBSize.0 - 1, height: SBSize.1 - 1))
            let stockBox = SKSpriteNode(color: StrokeColour, size: CGSize(width: SBSize.0 + 1, height: SBSize.1 + 1))
            stockBox.addChild(stockBoxIn)
            stockBoxIn.zPosition = 10
            stockBoxIn.name = "Stock Box"
            stockBox.zPosition = 9
            stockBox.position = CGPoint(x: -2*TileSize!, y: 2.5*TileSize!*CGFloat(player*2-3))
            self.addChild(stockBox)
            //let playerColour = PColour[player-1]
            let tokenSize = SBSize.0*3/32
            for i in 0..<7 {
                //let spriteIn = SKSpriteNode(color: playerColour, size: CGSize(width: tokenSize - 1, height: tokenSize - 1))
                //let sprite = SKSpriteNode(color: UIColor.black, size: CGSize(width: tokenSize + 1, height: tokenSize + 1))
                //let sprite = SKShapeNode(rectOf: CGSize(width: tokenSize + 1, height: tokenSize + 1), cornerRadius: 5)
                //sprite.fillColor = playerColour
                //sprite.strokeColor = UIColor.black
                //spriteIn.zPosition = 13
                let sprite = SKSpriteNode(imageNamed: "Stock Tkn P\(player)")
                sprite.setScale(1/2 * TileSize!/oldIdealTileSize)
                sprite.zPosition = 11
                sprite.name = "Stock P\(player) #\(i)"
                //sprite.addChild(spriteIn)
                stockBox.addChild(sprite)
                sprite.position = CGPoint(x: CGFloat(i-3)*tokenSize*(17/12), y: 0.0)
            }
            switch player {
            case 1: stockBoxes.0 = stockBox
            case 2: stockBoxes.1 = stockBox
            default: ()
            }
        }
        
        // Add the dice
        dieSize = idealTileSize * 7/8
        //let diceColour: SKColor
        //diceColour = PColour[data.activePlayer-1]
        //let inRect = SKSpriteNode(color: diceColour, size: CGSize(width: dieSize!-1, height: dieSize!-1))
        //inRect.name = "Dice In Rect"
        //inRect.position = CGPoint(x: 0, y: 0)
        dice.position = CGPoint(x: 3*horzShift, y: -2*vertShift)
        //inRect.zPosition = 10
        dice.zPosition = 9
        dice.setScale(tSize/idealTileSize)
        //dice.addChild(inRect)
        for i in [0,1] {
            for j in [0,1] {
                let dieNum = j*2+i
                //let die = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(dieSize!*2/7, dieSize!*2/7))
                let die = SKShapeNode(circleOfRadius: dieSize!/7)
                die.fillColor = SKColor.black
                die.strokeColor = SKColor.black
                die.name = "Die \(dieNum)"
                die.position = CGPoint(x: dieSize!*CGFloat(i*2-1)*3/14, y: dieSize!*CGFloat(j*2-1)*3/14)
                die.zPosition = 11
                dice.addChild(die)
            }
        }
        
        // Add the rosettes
        for rosette in data.rosettes {
            if 13 <= rosette || rosette <= 4 {
                for side in [1,2] {
                    addRosette(rank: rosette, side: side)
                }
            } else {
                addRosette(rank: rosette, side: 0)
            }
        }
        
        self.addChild(dice)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        touchBeginPos = touch.location(in: self)
        let touchedNode = self.atPoint(touch.location(in: self))
        if let name = touchedNode.name {
            if name == "Dice In Rect" || name.contains("Die"){
                invalidMove()
            }
            if name == "Stock Box" || name.contains("Stock"){
                invalidMove()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let beginPos = touchBeginPos{
            if activeSquare != nil {
                let rank = activeSquare!.0
                let side = activeSquare!.1
                let touch = touches.first!
                let touchPos = touch.location(in: self)
                let distx = touchPos.x - beginPos.x
                let disty = touchPos.y - beginPos.y
                if let sprite = data.tokenAt(at: rank, side: side)?.sprite {
                    let coord = coordForTile(at: rank, side: side)
                    sprite.position = CGPoint(x: coord.x + distx, y: coord.y + disty)
                }
                if (Float(distx) ^^ 2 + Float(disty) ^^ 2) > 600 {
                    self.data.executeMove(at: rank, side: side)
                    touchBeginPos = nil
                    activeSquare = nil
                }
            } else {
                // Do nothing
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if activeSquare != nil {
            if let token = data.tokenAt(at: activeSquare!.0, side: activeSquare!.1) {
                token.sprite!.position = coordForTile(at: activeSquare!.0, side: activeSquare!.1)
            }
            activeSquare = nil
        }
        touchBeginPos = nil
        activeSquare = nil
    }
    
    override func onSquareTouch(at rank: Int, side: Int, touch: UITouch) {
        //self.data.touch(at: rank, side: side)
        if let moveType = data.typeForMove(at: rank, side: side) {
            if moveType == .add {
                data.executeMove(at: rank, side: side)
            } else {
                if debugMode {
                    data.executeMove(at: rank, side: side)
                } else {
                    touchBeginPos = touch.location(in: self)
                    activeSquare = (rank, side)
                }
            }
        }
    }
    
    func setDieColor(die dieNum: Int, state: Int) { // State 0 is off, 1 is on during rolling, 2 is on normally
        let player = data.activePlayer
        let die = dice.childNode(withName: "Die \(dieNum)") as! SKShapeNode
        var colour = SKColor.black
        //if data.diceState[i] {
        if state == 2 {
            //die.alpha = 1
            colour = PDiceOnColour[player-1]
        } else if state == 1 {
            colour = PDiceOnColour[player-1]
        } else {
            //die.alpha = 0
            colour = PDiceOffColour[player-1]
        }
        die.fillColor = colour
        die.strokeColor = colour
    }
    
    override func updateScreen() {
        let player = data.activePlayer
        // Change the colour of the dice to the appropriate colour
        //let diceColour = PDiceColour[player-1]
        if player == 1 {
            dice.position.y = -2*vertShift
        } else if player == 2 {
            dice.position.y = +2*vertShift
        }
        //let diceInrect = dice.childNode(withName: "Dice In Rect")! as! SKSpriteNode
        //diceInrect.color = diceColour
        dice.texture = SKTexture(imageNamed: "P\(player)Dice")
        
        // Set the individual die to appear or dissappear based on the state of the dice
        diceValues = data.diceState
        for i in 0..<4 {
            var state = 0
            //if data.diceState[i] {
            if diceValues[i] {
                //die.alpha = 1
                state = 2
            } else {
                //die.alpha = 0
                state = 0
            }
            setDieColor(die: i, state: state)
            //let die = dice.childNode(withName: "Die \(i)") as! SKShapeNode
            //die.fillColor = colour
            //die.strokeColor = colour
        }
        
        // Update the indicator for the add move
        if let addMove = data.addMove {
            addIndicator.alpha = 0.3
            addIndicator.texture = SKTexture(imageNamed: "token P\(data.activePlayer)")
            let coord = self.coordForTile(at: addMove.startPos, side: data.activePlayer)
            addIndicator.position = coord
        } else {
            addIndicator.alpha = 0
        }
        
        // Update the rosette
        let rosette = self.childNode(withName: "Center Rosette")! as! SKSpriteNode
        let rTimer = data.rosetteTimer
        if rTimer == 0 {
            rosette.texture = rosetta
        } else if rTimer >= 20 {
            rosette.texture = SKTexture(imageNamed: "RosettaEmpty")
        } else {
            rosette.texture = SKTexture(imageNamed: "RoseT\(rTimer)")
        }
        
        // Update the tokens
        for token in self.data.tokens {
            if let sprite = token.sprite {
                let coord = self.coordForTile(at: token.position, side: token.player)
                sprite.position = coord
            } else {
                // The sprite hasn't been made yet, so make it
                
                //let Colour = PColour[token.player-1]
                //token.sprite = SKShapeNode(rectOf: CGSize(width: self.TileSize!*13/16, height: self.TileSize!*13/16), cornerRadius: 10)
                //token.sprite = SKSpriteNode(imageNamed: "token P\(token.player)")
                token.sprite = SKSpriteNode(imageNamed: token.spriteName)
                token.sprite!.setScale(1/2 * TileSize!/oldIdealTileSize)
                //token.sprite!.fillColor = Colour
                let coord = self.coordForTile(at: token.position, side: token.player)
                token.sprite!.position = coord
                token.sprite!.zPosition = 11
                self.addChild(token.sprite!)
            }
        }
        
        // Update the stock boxes
        for player in [1,2] {
            let stockbox: SKSpriteNode?
            switch player {
            case 1: stockbox = stockBoxes.0
            case 2: stockbox = stockBoxes.1
            default: stockbox = nil
            }
            for i in 0..<7 {
                if let token = stockbox?.childNode(withName: "Stock P\(player) #\(i)") {
                    if i < data.tokenStock[player-1] {
                        token.alpha = 1
                    } else {
                        token.alpha = 0
                    }
                }
            }
        }
    }
}


















