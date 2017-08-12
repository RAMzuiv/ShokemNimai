//
//  GameScene.swift
//  RoyalGame
//
//  Created by Mikkel on 5/13/17.
//  Copyright (c) 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit
import AVFoundation

class TutorialScene: GeneralScene {
    var text = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    var subtext = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    var phase = 0
    var nextSquare: Int?
    var tknSprite: SKSpriteNode?
    var enemy: SKSpriteNode?
    var dice: SKSpriteNode?
    var slideIndicator: SKSpriteNode?
    var diceValue = [true, false, false, true]
    var sliderPos: CGPoint?
    var timer: Timer?
    var splash: SKSpriteNode
    
    required init(coder: NSCoder) {
        splash = SKSpriteNode()
        super.init(coder: coder)
    }
    
    override init(size: CGSize, data: GameData) {
        splash = SKSpriteNode(imageNamed: "Splash")
        
        super.init(size: size, data: data)
        text.fontSize=size.height/8
        text.verticalAlignmentMode = .center
        text.position = CGPoint(x: 0, y: size.height*5/24)
        text.text = ""
        text.fontColor = SKColor(0.7, 0.1, 0.05)
        text.zPosition = 5
        subtext.fontSize=size.height/12
        subtext.verticalAlignmentMode = .center
        subtext.position = CGPoint(x: 0, y: size.height*2/24)
        subtext.text = ""
        subtext.zPosition = 5
        //subtext.fontColor = PGoalColour[0]
        subtext.fontColor = SKColor(0.6, 0.45, 0.0)
        self.addChild(text)
        self.addChild(subtext)
        self.addChild(splash)
    }
    
    func addBoard() {
        // Add the tiles to the board
        for rank in (6...10) {
            addTile(at: rank, side: 0)
        }
        
        // Add the goal
        addGoal(player: 1, at: 11)
        //move the goal slightly
        goals[0].position.x += vertGap*2/3
        goals[0].position.y += vertGap*1/3
        
        // Add the stock
        addStockCounter(player: 1, below: 5)
        stockBoxes.0!.position.y += TileSize!
        
        // Add the rosettes
        for rosette in [9] {
            /*
             if 13 <= rosette || rosette <= 4 {
             let side = 1
             {
             addRosette(rank: rosette, side: side)
             }
             } else {
             addRosette(rank: rosette, side: 0)
             }
             */
            addRosette(rank: rosette, side: 0)
        }
        
        // Add the enemy token
        enemy = SKSpriteNode(imageNamed: "token P2")
        enemy!.setScale(1/2 * TileSize!/oldIdealTileSize)
        let coord = self.coordForTile(at: 7, side: 0)
        enemy!.position = coord
        enemy!.zPosition = 11
        self.addChild(enemy!)
    }
    
    func nextphase() {
        switch phase {
        case 0:
            let box = SKSpriteNode(color: SKColor.white, size: CGSize(width: scrSize!.width*0.95, height: scrSize!.height*0.2))
            box.alpha = 0.7
            box.position = CGPoint(x: 0, y: scrSize!.height*0.17)
            box.zPosition = 1
            self.addChild(box)
            phase = 1
            addBoard()
            slideIndicator = SKSpriteNode(imageNamed: "Slide")
            sliderPos = stockBoxes.0!.position
            slideIndicator!.position = sliderPos!
            slideIndicator?.zPosition = 15
            slideIndicator?.setScale(7/12 * TileSize!/idealTileSize)
            self.addChild(slideIndicator!)
            timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(slideSlider), userInfo: nil, repeats: true)
            timer!.fire()
            slideSlider()
            text.text = "Shokem Nimai is played by 2 rivals facing eye-to-eye"
            text.fontSize = scrSize!.height/20
            subtext.text = "Slide a piece onto the board to begin"
            subtext.fontSize = scrSize!.height/24
            subtext.position.y = scrSize!.height*3/24
            nextSquare = 0
            splash.alpha = 0
        case 1:
            phase = 2
            nextSquare = 6
            text.text = "Get your pieces around the board - first to 5 wins"
            subtext.text = "Land on an enemy piece to capture it"
            tknSprite = SKSpriteNode(imageNamed: "token P1")
            tknSprite!.setScale(1/2 * TileSize!/oldIdealTileSize)
            let coord = self.coordForTile(at: 6, side: 0)
            sliderPos = coord
            tknSprite!.position = coord
            tknSprite!.zPosition = 11
            self.addChild(tknSprite!)
        case 2:
            phase = 3
            nextSquare = 7
            enemy!.alpha = 0
            tknSprite!.position = coordForTile(at: 7, side: 0)
            sliderPos = coordForTile(at: 7, side: 0)
            text.text = "The Dice governs all play"
            subtext.text = "You can move one piece exactly as far as the dice says per turn"
            // Add the dice
            dice = SKSpriteNode(imageNamed: "P1Dice")
            let dieSize = idealTileSize * 7/8 * 1
            //dice.position = CGPoint(x: 3*horzShift, y: -2*vertShift - vertGap)
            dice!.position = posForDie(side: 1)
            dice!.zPosition = 9
            dice!.setScale(1.2 * TileSize!/idealTileSize)
            for i in [0,1] {
                for j in [0,1] {
                    let dieNum = j*2+i
                    let die = SKShapeNode(circleOfRadius: dieSize/7)
                    die.fillColor = SKColor.black
                    die.strokeColor = SKColor.black
                    die.name = "Die \(dieNum)"
                    die.position = CGPoint(x: dieSize*CGFloat(i*2-1)*3/14, y: dieSize*CGFloat(j*2-1)*3/14)
                    die.zPosition = 11
                    dice!.addChild(die)
                }
            }
            updateDice()
            self.addChild(dice!)
        case 3:
            phase = 4
            nextSquare = 9
            tknSprite!.position = coordForTile(at: 9, side: 0)
            sliderPos = coordForTile(at: 9, side: 0)
            diceValue = [true, true, false, false]
            updateDice()
            text.text = "Landing on a boost pad gives an extra turn"
            subtext.text = "It will also protect you from enemy attacks, for a while"
        case 4:
            phase = 5
            nextSquare = nil
            tknSprite!.alpha = 0
            diceValue = [false, false, false, false]
            timer!.invalidate()
            updateDice()
            text.text = "That's all there is to it!"
            subtext.text = "So grab a friend, and have fun!"
            let icon = goals[0].childNode(withName: "Token P\(1) #\(0)") as! SKShapeNode
            icon.fillColor = PDiceOnColour[0]
            icon.strokeColor = PDiceOnColour[0]
        default:
            print("default")
        }
    }
    
    override func onSquareTouch(at rank: Int, side: Int, touch: UITouch) {
        if nextSquare != nil && nextSquare! == rank {
            touchBeginPos = touch.location(in: self)
            activeSquare = (rank, side)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if phase == 0 {
            nextphase()
        } else if phase == 5 {
            data.Controller.newGame()
        } else {
            let touch = touches.first!
            touchBeginPos = touch.location(in: self)
            let touchedNode = self.atPoint(touch.location(in: self))
            if let name = touchedNode.name {
                if name == "Stock Box" || name.contains("Stock"){
                    onSquareTouch(at: 0, side: data.activePlayer, touch: touch)
                }
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
                
                //if let sprite = data.tokenAt(at: rank, side: side)?.sprite {
                if let sprite = tknSprite {
                    let coord = coordForTile(at: rank, side: side)
                    sprite.position = CGPoint(x: coord.x + distx, y: coord.y + disty)
                }
                if (Float(distx) ^^ 2 + Float(disty) ^^ 2) > 600 {
                    nextphase()
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
            if let sprite = tknSprite {
                sprite.position = coordForTile(at: activeSquare!.0, side: activeSquare!.1)
            }
            activeSquare = nil
        }
        touchBeginPos = nil
        activeSquare = nil
    }
    
    override func coordForTile(at rank: Int, side: Int) -> CGPoint {
        var coord = super.coordForTile(at: rank, side: side)
        coord.y -= TileSize!/2
        coord.x += TileSize!/2
        return coord
    }
    
    func updateDice() {
        for i in 0..<4 {
            var state = 0
            //if data.diceState[i] {
            if diceValue[i] {
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
    }
    
    func setDieColor(die dieNum: Int, state: Int) { // State 0 is off, 1 is on during rolling, 2 is on normally
        let player = data.activePlayer
        let die = dice!.childNode(withName: "Die \(dieNum)") as! SKShapeNode
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
    
    override func posForDie(side: Int) -> CGPoint {
        return CGPoint(x: 0, y: TileSize!/idealTileSize*380)
    }
    
    func slideSlider() {
        slideIndicator!.alpha = 1
        slideIndicator!.position = sliderPos!
        var newPos = slideIndicator!.position
        newPos.x += TileSize!
        let duration: TimeInterval = 2
        let moveAnim = SKAction.move(to: newPos, duration: duration)
        let fadeAnim = SKAction.fadeOut(withDuration: duration * 0.5)
        fadeAnim.timingMode = SKActionTimingMode.easeOut
        moveAnim.timingMode = SKActionTimingMode.easeOut
        let fadeComp = SKAction.sequence([SKAction.wait(forDuration: duration*0.5), fadeAnim])
        let compAnim = SKAction.group([fadeComp, moveAnim])
        
        slideIndicator!.run(compAnim)
    }
}


















