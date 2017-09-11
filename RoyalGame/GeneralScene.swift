//
//  GeneralScene.swift
//  RoyalGame
//
//  Created by Mikkel on 7/18/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GeneralScene: SKScene {
    let data: GameData!
    var board: Set<SKSpriteNode>!
    var touchBeginPos: CGPoint? // The beginning of a touch
    var activeSquare: (Int, Int)? // Rank and side of the active square
    
    var frameNum = 0
    var emitters: [BGEmitter] = []
    var PColour = [SKColor(1, 0, 0), SKColor(0, 0.95, 0)] // Main Colours for both players
    var PStartColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Colour for the start of the track
    var PGoalColour = [SKColor(0.55, 0.05, 0.05), SKColor(0.05, 0.55, 0.05)] // Colour for the goals
    var PDiceOffColour = [SKColor(0.2, 0, 0), SKColor(0, 0.2, 0)] // Colour for the off dice
    var PDiceColour = [SKColor(0.45, 0.1, 0.1), SKColor(0.1, 0.4, 0.1)] // Colour for the dice box
    var PDiceOnColour = [SKColor(1, 0.1, 0.1), SKColor(0.3, 0.95, 0.3)] // Colour for the on dice
    let BGColour = SKColor(0.1, 0.12, 0.6) // Background colour
    //let StrokeColour: SKColor = SKColor(0, 0.4, 0.8) // Stroke colour for tiles on board
    let StrokeColour = SKColor(0.1, 0.12, 0.6)
    let TileColour = SKColor(0.9, 0.9, 0.9)
    //let PTileColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Tile colours for both players
    var PTileColour = [SKColor(0.9, 0.7, 0.5), SKColor(0.7, 0.9, 0.5)] // Tile colours for both players
    let TileAlpha: CGFloat = 0.8
    let scrSize: CGSize?
    let TileSize: CGFloat?
    let vertGap: CGFloat!
    let horzShift: CGFloat!
    let vertShift: CGFloat!
    let addIndicator: SKSpriteNode // The indicator to show when an add move is allowed
    let oldIdealTileSize = 114.0 as CGFloat // The ideal size relative to the 9.7 iPad. Don't use this number
    let idealTileSize = 151.77777777 as CGFloat // The ideal size relative to the 12.9. Make assets at 2x the resolution of the 12.9
    var diceValues = [false, false, false, false]
    var stockBoxes: (SKSpriteNode?, SKSpriteNode?)
    var goals: [SKSpriteNode] = []
    var slideIndicator: SKSpriteNode?
    var sliderPos: CGPoint?
    var slideTimer: Timer?
    let errorSound = SKAction.playSoundFileNamed("Sound/error", waitForCompletion: false)
    let rosetta = SKTexture(imageNamed: "Rosetta")
    //let boost = SKTexture(imageNamed: "boost")
    let boost = SKTexture(imageNamed: "boost mask")
    var musicPlayer = AVAudioPlayer()
    let debugMode = false
    var previewMode = false
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
    
    init(size: CGSize, data: GameData, preview: Bool = false) {
        //StrokeColour = BGColour
        self.scrSize = size
        self.TileSize = size.width/9
        self.data = data
        vertGap = TileSize!/4
        horzShift = TileSize!
        vertShift = TileSize!+vertGap
        
        // Create the Add Indicator
        addIndicator = SKSpriteNode(imageNamed: "token P1")
        addIndicator.setScale(1/4 * TileSize!/oldIdealTileSize)
        addIndicator.zPosition = 11
        addIndicator.alpha = 0
        
        for _ in 0..<15 {
            emitters.append(BGEmitter(size: scrSize!, darkMode: preview))
        }
        
        super.init(size: size)
        
        if preview {
            previewMode = true
        }
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.backgroundColor = BGColour // Set the background to the background colour
        
        // Add the background
        /*
        let background = SKSpriteNode(imageNamed: "background")
        background.scale(to: self.scrSize!)
        background.zPosition = -1
        self.addChild(background)
        */
        
        for emitter in emitters {
            for i in [0,1]{
                self.addChild(emitter.blendRects[i])
            }
        }
        
        setColors(scheme: 0)
        
        //self.addChild(addIndicator)
        
        //playBGM()
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
                let y = touch.location(in: self).y
                if (y > 0 && data.activePlayer == 2) || (y < 0 && data.activePlayer == 1) {
                    onSquareTouch(at: 0, side: data.activePlayer, touch: touch)
                } else {
                    invalidMove()
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
                if let sprite = data.tokenAt(at: rank, side: side)?.sprite {
                    let coord = coordForTile(at: rank, side: side)
                    sprite.position = CGPoint(x: coord.x + distx, y: coord.y + disty)
                }
                if (Float(distx) ^^ 2 + Float(disty) ^^ 2) > 600 {
                    var dir = ""
                    if distx > disty {
                        // Down and right
                        if distx > -disty {
                            dir = "right"
                        } else {
                            dir = "down"
                        }
                    } else {
                        // Up and left
                        if -distx > disty {
                            dir = "left"
                        } else {
                            dir = "up"
                        }
                    }
                    onSquareSwipe(at: rank, side: side, dir: dir)
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
        
    }
    
    func onSquareSwipe(at rank: Int, side: Int, dir: String) {
        
    }
    
    func addRosette(rank: Int, side: Int) {
        let sprite = SKSpriteNode(texture: rosetta)
        //let sprite = SKSpriteNode(imageNamed: "Stock Tkn P1")
        let arrow = SKSpriteNode(texture: boost)
        arrow.blendMode = .multiply
        if rank == 4 {
            if side == 1 {
                arrow.zRotation = .pi
            } else {
                arrow.zRotation = 0
            }
        } else if rank == 14 {
            arrow.zRotation = -.pi/2
        }
        sprite.position = coordForTile(at: rank, side: side)
        sprite.setScale(1/2 * TileSize!/oldIdealTileSize)
        arrow.zPosition = 10
        arrow.position = sprite.position
        sprite.zPosition = 13
        arrow.setScale(1/2 * TileSize!/oldIdealTileSize)
        if side == 0 {
            arrow.zRotation = .pi/2
            sprite.name = "Center Rosette"
        } else {
            //arrow.texture = SKTexture(imageNamed: "boostP\(side)")
        }
        self.addChild(sprite)
        self.addChild(arrow)
    }
    
    override func update(_ currentTime: TimeInterval) {
        frameNum += 1
        if !debugMode && frameNum%3 != 0 {
            for i in 0..<emitters.count {
                if i % 2 == frameNum % 3 && ((i + data.moveNum) % 3 >= 1) {
                    let emitter = emitters[i]
                    emitter.update()
                }
            }
        }
    }
    
    func removeToken(_ token: Token) {
        token.sprite?.run(SKAction.removeFromParent())
    }
    
    func invalidMove() {
        run(errorSound)
    }
    
    func updateScreen() {
        
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
        if previewMode {
            if data.activePlayer == 1 {
                return CGPoint(x: (CGFloat(x)+1/2)*horzShift, y: (CGFloat(y) - 0.10)*vertShift)
            } else {
                return CGPoint(x: (CGFloat(x)+1/2)*horzShift, y: (CGFloat(y) + 0.10)*vertShift)
            }
        }
        return CGPoint(x: (CGFloat(x)+1/2)*horzShift, y: CGFloat(y)*vertShift)
    }
    
    func posForStock(num: Int, side: Int) -> CGPoint {
        var xDir: CGFloat = 0.0
        if num == 1 || num == 4 || num == 5 {
            xDir = 0.5
        } else if num == 2 || num == 3 || num == 6 {
            xDir = -0.5
        }
        var yDir: CGFloat = 0.0
        if num == 1 || num == 2 {
            yDir = 1.0
        } else if num == 5 || num == 6 {
            yDir = -1.0
        } else {
            xDir *= 2
        }
        if side == 2 {
            yDir *= -1
        }
        return CGPoint(x: TileSize!/idealTileSize*47*xDir, y: TileSize!/idealTileSize*47*yDir)
        //return CGPoint(x: CGFloat(num - 3)*1*(17/12), y: 0.0)
    }
    
    func posForFinish(num: Int, side: Int) -> CGPoint {
        let angle = .pi * (Float(num) * 2/5 + Float(side) + 1)
        return CGPoint(x: TileSize!/idealTileSize*45 * CGFloat(sin(angle)), y: TileSize!/idealTileSize*45 * CGFloat(cos(angle)))
    }
    
    func posForDie(side: Int) -> CGPoint {
        var y = 2*vertShift + vertGap/4
        if previewMode {
            if data.activePlayer == 1 {
                y += vertGap*1/3
            } else {
                y += vertGap*1/3
            }
        }
        if side == 1 {
            y *= -1
        } else {
            y *= 1
        }
        return CGPoint(x: -2*horzShift, y: y)
    }
    
    func addToken(_ token: Token) {
        //token.sprite = SKSpriteNode(imageNamed: token.spriteName)
        token.sprite = SKSpriteNode(imageNamed: "token P\(token.player)")
        let overlay = SKSpriteNode(imageNamed: token.overlayName)
        overlay.blendMode = .multiply
        overlay.zPosition = 12
        if token.player == 2 {
            overlay.zRotation = .pi
        }
        token.sprite!.addChild(overlay)
        token.sprite!.setScale(1/2 * TileSize!/oldIdealTileSize)
        //token.sprite!.fillColor = Colour
        let coord = self.coordForTile(at: token.position, side: token.player)
        token.sprite!.position = coord
        token.sprite!.zPosition = 11
        self.addChild(token.sprite!)
    }
    
    func addTile(at rank: Int, side: Int, bigTile: Bool = false, withButton: Bool = true) {
        var tileColour = TileColour
        if side != 0 {
            tileColour = PTileColour[side-1] // Make the square the player's colour
        }
        let coords = coordForTile(at: rank, side: side)
        if withButton{
            let button = Square(scene: self, size: CGSize(width: TileSize!-1, height: TileSize!-1), at: rank, side: side)
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
        let inRect = SKSpriteNode(color: tileColour, size: CGSize(width: TileSize!-2, height: TileSize!-2))
        //let inRect = SKShapeNode(rectOf: CGSize(width: TileSize!, height: TileSize!), cornerRadius: 0)
        //inRect.strokeColor = StrokeColour
        //inRect.fillColor = tileColour
        let outRect = SKSpriteNode(color: StrokeColour, size: CGSize(width: TileSize!+1, height: TileSize!+1))
        
        if bigTile {
            //inRect.yScale = (1 + (vertGap/(TileSize!+1) * 2/3))
            inRect.size.height = TileSize!+vertGap*2/3-2
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
        outRect.zPosition = -9
        //inRect.alpha = TileAlpha
        inRect.blendMode = .screen
        self.addChild(inRect)
        self.addChild(outRect)
    }
    
    func addStockCounter(player: Int, below rank: Int = 1) {
        let SBSize = (TileSize!*1, TileSize!*1)
        let stockBoxIn = SKSpriteNode(color: PTileColour[player-1], size: CGSize(width: SBSize.0 - 2, height: SBSize.1 - 2))
        let stockBox = SKSpriteNode(color: StrokeColour, size: CGSize(width: SBSize.0 + 1, height: SBSize.1 + 1))
        //stockBox.alpha = TileAlpha
        stockBox.addChild(stockBoxIn)
        stockBoxIn.zPosition = 10
        stockBoxIn.name = "Stock Box"
        stockBoxIn.blendMode = .screen
        stockBox.zPosition = -9
        let abovePos = coordForTile(at: rank, side: player)
        //stockBox.position = CGPoint(x: -0.5*TileSize!, y: (2*TileSize! + vertGap)*CGFloat(player*2-3))
        stockBox.position = CGPoint(x: abovePos.x, y: abovePos.y + (CGFloat(player)*2 - 3) * TileSize!)
        self.addChild(stockBox)
        for i in 0..<7 {
            let sprite = SKSpriteNode(imageNamed: "Stock Tkn P\(player)")
            sprite.setScale(1/2 * TileSize!/oldIdealTileSize)
            sprite.zPosition = 11
            sprite.name = "Stock P\(player) #\(i)"
            stockBox.addChild(sprite)
            sprite.position = posForStock(num: i, side: player)
        }
        switch player {
        case 1: stockBoxes.0 = stockBox
        case 2: stockBoxes.1 = stockBox
        default: ()
        }
        if previewMode {
            stockBox.alpha = 0
        }
    }
    
    func addGoal(player: Int, at rank: Int = 15) {
        let goal = SKSpriteNode(color: PGoalColour[player-1], size: CGSize(width: TileSize!+vertGap*2/3 - 4, height: TileSize!+vertGap*2/3 - 2))
        let coord = coordForTile(at: rank, side: player)
        goal.position = CGPoint(x: coord.x - vertGap*1/3, y: coord.y + (CGFloat(player)*2 - 3)*vertGap*1/3)
        goal.zPosition = 10
        //goal.alpha = TileAlpha
        for i in 0..<5 {
            let sprite = SKShapeNode(circleOfRadius: TileSize!/idealTileSize*17)
            sprite.fillColor = PDiceOffColour[player - 1]
            sprite.strokeColor = PDiceOffColour[player - 1]
            sprite.alpha = 1
            goal.addChild(sprite)
            sprite.position = posForFinish(num: i, side: player)
            sprite.zPosition = 13
            sprite.name = "Token P\(player) #\(i)"
        }
        self.addChild(goal)
        goals.append(goal)
    }
    
    func setColors(scheme: Int) {
        switch scheme {
        case 0:
            PColour = [SKColor(1, 0, 0), SKColor(0, 0.95, 0)] // Main Colours
            PStartColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Colour for the start of the track
            PGoalColour = [SKColor(0.55, 0.05, 0.05), SKColor(0.05, 0.55, 0.05)] // Colour for the goals
            PDiceOffColour = [SKColor(0.2, 0, 0), SKColor(0, 0.2, 0)] // Colour for the off dice
            PDiceColour = [SKColor(0.45, 0.1, 0.1), SKColor(0.1, 0.4, 0.1)] // Colour for the dice box
            PDiceOnColour = [SKColor(1, 0.1, 0.1), SKColor(0.3, 0.95, 0.3)] // Colour for the on dice
            PTileColour = [SKColor(0.9, 0.7, 0.5), SKColor(0.7, 0.9, 0.5)] // Tile colours
        case 1:
            PColour = [SKColor(0.7, 0.3, 0), SKColor(0.3, 0, 0.7)] // Main Colours
            PStartColour = [SKColor](repeating: TileColour, count: 2) // Colour for the start of the track
            PGoalColour = [SKColor(0.55, 0.05, 0.05), SKColor(0.05, 0.55, 0.05)] // Colour for the goals
            PDiceOffColour = [SKColor(0.2, 0, 0), SKColor(0, 0.2, 0)] // Colour for the off dice
            PDiceColour = [SKColor(0.45, 0.1, 0.1), SKColor(0.1, 0.4, 0.1)] // Colour for the dice box
            PDiceOnColour = [SKColor(1, 0.1, 0.1), SKColor(0.3, 0.95, 0.3)] // Colour for the on dice
            PTileColour = [SKColor](repeating: TileColour, count: 2) // Tile colours
        default: break
        }
    }
    
    func playBGM() {
        let url = Bundle.main.url(forResource: "Sound/The_Cavalry", withExtension: "mp3")
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url!)
            musicPlayer.numberOfLoops = -1
            musicPlayer.setVolume(0.05, fadeDuration: 0)
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func addSlider() {
        slideIndicator = SKSpriteNode(imageNamed: "Slide")
        sliderPos = stockBoxes.0!.position
        slideIndicator!.position = sliderPos!
        slideIndicator!.zPosition = 15
        slideIndicator!.setScale(7/12 * TileSize!/idealTileSize)
        self.addChild(slideIndicator!)
        slideTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(slideSlider), userInfo: nil, repeats: true)
        slideTimer!.fire()
        slideSlider()
    }
    
    func slideSlider() {
        slideIndicator!.alpha = 1
        slideIndicator!.position = sliderPos!
        var newPos = sliderPos!
        if data.activePlayer == 1 {
            newPos.y += TileSize!
        } else {
            newPos.y -= TileSize!
            slideIndicator!.zRotation = -.pi/2
        }
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
