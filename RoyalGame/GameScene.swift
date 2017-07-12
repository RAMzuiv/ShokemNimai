//
//  GameScene.swift
//  RoyalGame
//
//  Created by Mikkel on 5/13/17.
//  Copyright (c) 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let data: GameData!
    var board: Set<SKSpriteNode>!
    var touchBeginPos: CGPoint? // The beginning of a touch
    var activeSquare: (Int, Int)? // Rank and side of the active square
    
    let PColour = [SKColor(1, 0, 0), SKColor(0, 0.95, 0)] // Main Colours for both players
    let PTileColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Tile colours for both players
    //let PTileColour = [SKColor(0.75, 0.75, 0.75), SKColor(0.75, 0.75, 0.75)] // Tile colours for both players
    let PDiceOffColour = [SKColor(0.2, 0, 0), SKColor(0, 0.2, 0)] // Colour for the off dice
    let PDiceColour = [SKColor(0.45, 0.1, 0.1), SKColor(0.1, 0.4, 0.1)] // Colour for the dice box
    let PDiceOnColour = [SKColor(1, 0.1, 0.1), SKColor(0.3, 0.95, 0.3)] // Colour for the on dice
    let BGColour = SKColor(0.53, 0.81, 0.92) // Background colour
    //let BGColour = SKColor(0.3, 0.3, 0.3) // Background colour
    //let StrokeColour: SKColor = SKColor(0, 0.44, 1) // Stroke colour for tiles on board
    let StrokeColour: SKColor = SKColor(0, 0.4, 0.8) // Stroke colour for tiles on board
    let TileColour = SKColor(1, 1, 1)
    //let TileColour = SKColor(0.75, 0.75, 0.75)
    let scrSize: CGSize?
    let TileSize: CGFloat?
    let vertGap: CGFloat!
    let horzShift: CGFloat!
    let vertShift: CGFloat!
    let dice: SKSpriteNode
    let dieSize: CGFloat?
    let addIndicator: SKSpriteNode // The indicator to show when an add move is allowed
    let oldIdealTileSize = 114.0 as CGFloat // The ideal size relative to the 9.7 iPad. Don't use this number
    let idealTileSize = 152.0 as CGFloat // The ideal size relative to the 12.9. Make assets at 2x the resolution of the 12.9
    var diceValues = [false, false, false, false]
    var stockBoxes: (SKSpriteNode?, SKSpriteNode?)
    let errorSound = SKAction.playSoundFileNamed("Sound/error", waitForCompletion: false)
    let thunder = SKTexture(imageNamed: "Thunder")
    let hex = SKTexture(imageNamed: "Hex")
    let sqRosetta = SKTexture(imageNamed: "squareRosetta")
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
    
    init(size: CGSize, data: GameData) {
        //StrokeColour = BGColour
        self.data = data
        self.scrSize = size
        self.TileSize = size.width/9
        vertGap = TileSize!/4
        horzShift = TileSize!
        vertShift = TileSize!+vertGap
        dieSize = TileSize!*3/4
        
        // Create the dice sprites
        let diceColour: SKColor
        diceColour = PColour[data.activePlayer-1]
        let inRect = SKSpriteNode(color: diceColour, size: CGSize(width: dieSize!-1, height: dieSize!-1))
        inRect.name = "Dice In Rect"
        dice = SKSpriteNode(color: SKColor.black, size: CGSize(width: dieSize!+1, height: dieSize!+1))
        inRect.position = CGPoint(x: 0, y: 0)
        dice.position = CGPoint(x: 3*horzShift, y: -2*vertShift)
        inRect.zPosition = 10
        dice.zPosition = 9
        dice.addChild(inRect)
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
        
        // Create the Add Indicator
        addIndicator = SKSpriteNode(imageNamed: "token P1")
        addIndicator.setScale(1/4 * TileSize!/oldIdealTileSize)
        addIndicator.zPosition = 11
        addIndicator.alpha = 0
        
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.backgroundColor = BGColour // Set the background to the background colour
        
        // Add the background
        let background = SKSpriteNode(imageNamed: "background")
        background.scale(to: self.scrSize!)
        background.zPosition = -1
        self.addChild(background)
        
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
        
        
        // Add the rosettes
        /*
        for rosette in data.rosettes {
            if 13 <= rosette || rosette <= 4 {
                for side in [1,2] {
                    sprite = SKSpriteNode(texture: thunder)
                    sprite.position = coordForTile(at: rosette, side: side)
                    //sprite.size = CGSize(width: TileSize!*0.8, height: TileSize!*0.8)
                    sprite.zRotation = -.pi * (3 / 24)
                }
            } else {
                sprite = SKSpriteNode(texture: hex)
                sprite.position = coordForTile(at: rosette, side: 0)
                //sprite.size = CGSize(width: TileSize!*0.8, height: TileSize!*0.8)
            }
        }
        */
        for rosette in data.rosettes {
            if 13 <= rosette || rosette <= 4 {
                for side in [1,2] {
                    addRosette(rank: rosette, side: side)
                }
            } else {
                addRosette(rank: rosette, side: 0)
            }
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
        self.addChild(addIndicator)
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
            if name == "Stock Box" {
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
    
    func onSquareTouch(at rank: Int, side: Int, touch: UITouch) {
        //self.data.touch(at: rank, side: side)
        if let moveType = data.typeForMove(at: rank, side: side) {
            if moveType == .add {
                data.executeMove(at: rank, side: side)
            } else {
                touchBeginPos = touch.location(in: self)
                activeSquare = (rank, side)
            }
        }
    }
    
    func addRosette(rank: Int, side: Int) {
        let sprite: SKSpriteNode!
        if 13 <= rank || rank <= 4 {
            sprite = SKSpriteNode(texture: sqRosetta)
            //sprite = SKSpriteNode(texture: hex)
            //sprite.zRotation = -.pi * (3 / 24)
        } else {
            sprite = SKSpriteNode(texture: sqRosetta)
        }
        sprite.position = coordForTile(at: rank, side: side)
        //sprite.setScale(2/3 * TileSize!/oldIdealTileSize) //Use this for the old rosettas
        sprite.setScale(1 * TileSize!/oldIdealTileSize)
        sprite.zPosition = 13
        self.addChild(sprite)
    }
    
    /*
    override func update(_ currentTime: TimeInterval) {
        for i in 0 ..< diceValues.count {
            if arc4random_uniform(10) > 2{
                diceValues[i] = !diceValues[i]
                var state = 0
                if diceValues[i] == true {
                    state = 1
                }
                setDieColor(die: i, state: state)
            }
        }
    }
    */
    
    func removeToken(_ token: Token) {
        token.sprite?.run(SKAction.removeFromParent())
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
    
    func invalidMove() {
        run(errorSound)
    }
    
    func updateScreen() {
        let player = data.activePlayer
        // Change the colour of the dice to the appropriate colour
        let diceColour = PDiceColour[player-1]
        if player == 1 {
            dice.position.y = -2*vertShift
        } else if player == 2 {
            dice.position.y = +2*vertShift
        }
        let diceInrect = dice.childNode(withName: "Dice In Rect")! as! SKSpriteNode
        diceInrect.color = diceColour
        
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
    
    func coordForTile(at rank: Int, side: Int) -> CGPoint {
        var x: Int!
        var y = 0
        if side == 1{
            y = -1
        } else if side == 2 {
            y = 1
        }
        if y == 0 || (rank > 4 && rank < 13) {
            x = rank-9 // In middle of board
            y = 0
        } else {
            if rank <= 4{
                x = -rank // In home row
            } else {
                x = 16-rank // In final stretch
            }
        }
        return CGPoint(x: (CGFloat(x)+1/2)*horzShift, y: CGFloat(y)*vertShift)
    }
    
    func addTile(at rank: Int, side: Int, bigTile: Bool = false, withButton: Bool = true) {
        var tileColour = TileColour
        if side != 0 {
            tileColour = PTileColour[side-1] // Make the square the player's colour
        }
        let coords = coordForTile(at: rank, side: side)
        if withButton{
            let button = Square(scene: self, size: CGSize(width: TileSize!-1, height: TileSize!-1), at: rank, side: side)/*{
                (rank: Int, side: Int, touch: UITouch) -> () in
                //self.data.touch(at: rank, side: side)
                self.onSquareTouch(at: rank, side: side, touch: touch)
            } */
            button.data = data //Give the square access to the data model
            button.isUserInteractionEnabled = true
            button.zPosition = 30
            self.addChild(button)
            if bigTile {
                button.size.height = TileSize!+vertGap*2/3-1
                if side == 1 {
                    button.position = CGPoint(x: coords.x, y: coords.y+vertGap/3)
                } else if side == 2 {
                    button.position = CGPoint(x: coords.x, y: coords.y-vertGap/3)
                } else if side == 0 {
                    button.position = coords
                    button.size.height = TileSize!+vertGap*2/3-1
                }
            } else {
                button.position = coords
            }
        }
        // Make two rectangles at the given location, one with the tile colour, and a bigger one with the stroke colour
        let inRect = SKSpriteNode(color: tileColour, size: CGSize(width: TileSize!-1, height: TileSize!-1))
        //let inRect = SKShapeNode(rectOf: CGSize(width: TileSize!, height: TileSize!), cornerRadius: 0)
        //inRect.strokeColor = StrokeColour
        //inRect.fillColor = tileColour
        let outRect = SKSpriteNode(color: StrokeColour, size: CGSize(width: TileSize!+1, height: TileSize!+1))
        
        if bigTile {
            //inRect.yScale = (1 + (vertGap/(TileSize!+1) * 2/3))
            inRect.size.height = TileSize!+vertGap*2/3-1
            outRect.size.height = TileSize!+vertGap*2/3+1
            if side == 1 {
                inRect.position = CGPoint(x: coords.x, y: coords.y+vertGap/3)
                outRect.position = CGPoint(x: coords.x, y: coords.y+vertGap/3)
            } else if side == 2 {
                inRect.position = CGPoint(x: coords.x, y: coords.y-vertGap/3)
                outRect.position = CGPoint(x: coords.x, y: coords.y-vertGap/3)
            } else if side == 0 {
                inRect.position = coords
                outRect.position = coords
            }
        } else {
            inRect.position = coords
            outRect.position = coords
        }
        
        inRect.zPosition = 10
        outRect.zPosition = 9
        self.addChild(inRect)
        self.addChild(outRect)
    }
    
    func squircle(size: CGFloat) -> SKShapeNode {
        let radius = size/2
        
        let bezierPath = UIBezierPath()
        
        // The corners (Guide points for curve)
        let ULCorner = CGPoint(x: -radius, y: +radius)
        let DLCorner = CGPoint(x: -radius, y: -radius)
        let URCorner = CGPoint(x: +radius, y: +radius)
        let DRCorner = CGPoint(x: +radius, y: -radius)
        
        // The edge midpoints (Start-end points for curve)
        let LeftPoint = CGPoint(x: -radius, y: 0)
        let RightPoint = CGPoint(x: radius, y: 0)
        let UpPoint = CGPoint(x: 0, y: radius)
        let DownPoint = CGPoint(x: 0, y: -radius)
        
        bezierPath.move(to: LeftPoint)
        bezierPath.addCurve(to: UpPoint, controlPoint1: ULCorner, controlPoint2: ULCorner)
        bezierPath.addCurve(to: RightPoint, controlPoint1: URCorner, controlPoint2: URCorner)
        bezierPath.addCurve(to: DownPoint, controlPoint1: DRCorner, controlPoint2: DRCorner)
        bezierPath.addCurve(to: LeftPoint, controlPoint1: DLCorner, controlPoint2: DLCorner)
        bezierPath.close()
        
        let shape = SKShapeNode(path: bezierPath.cgPath)
        //shape.
        return shape
    }
}


















