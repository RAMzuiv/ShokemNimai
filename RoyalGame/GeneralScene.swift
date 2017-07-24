//
//  GeneralScene.swift
//  RoyalGame
//
//  Created by Mikkel on 7/18/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit
import AVFoundation

class GeneralScene: SKScene {
    var board: Set<SKSpriteNode>!
    var touchBeginPos: CGPoint? // The beginning of a touch
    var activeSquare: (Int, Int)? // Rank and side of the active square
    
    let PColour = [SKColor(1, 0, 0), SKColor(0, 0.95, 0)] // Main Colours for both players
    let PTileColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Tile colours for both players
    let PDiceOffColour = [SKColor(0.2, 0, 0), SKColor(0, 0.2, 0)] // Colour for the off dice
    let PDiceColour = [SKColor(0.45, 0.1, 0.1), SKColor(0.1, 0.4, 0.1)] // Colour for the dice box
    let PDiceOnColour = [SKColor(1, 0.1, 0.1), SKColor(0.3, 0.95, 0.3)] // Colour for the on dice
    let BGColour = SKColor(0.53, 0.81, 0.92) // Background colour
    let StrokeColour: SKColor = SKColor(0, 0.4, 0.8) // Stroke colour for tiles on board
    let TileColour = SKColor(1, 1, 1)
    let scrSize: CGSize?
    let TileSize: CGFloat?
    let vertGap: CGFloat!
    let horzShift: CGFloat!
    let vertShift: CGFloat!
    let addIndicator: SKSpriteNode // The indicator to show when an add move is allowed
    let oldIdealTileSize = 114.0 as CGFloat // The ideal size relative to the 9.7 iPad. Don't use this number
    let idealTileSize = 152.0 as CGFloat // The ideal size relative to the 12.9. Make assets at 2x the resolution of the 12.9
    var diceValues = [false, false, false, false]
    var stockBoxes: (SKSpriteNode?, SKSpriteNode?)
    let errorSound = SKAction.playSoundFileNamed("Sound/error", waitForCompletion: false)
    let rosetta = SKTexture(imageNamed: "Rosetta")
    var musicPlayer = AVAudioPlayer()
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
    
    override init(size: CGSize) {
        //StrokeColour = BGColour
        self.scrSize = size
        self.TileSize = size.width/9
        vertGap = TileSize!/4
        horzShift = TileSize!
        vertShift = TileSize!+vertGap
        
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
        
        //playBGM()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func onSquareTouch(at rank: Int, side: Int, touch: UITouch) {
        
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
        return CGPoint(x: (CGFloat(x)+1/2)*horzShift, y: CGFloat(y)*vertShift)
    }
    
    func addTile(at rank: Int, side: Int, bigTile: Bool = false, withButton: Bool = true) {
        
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
}
