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
    let PColour = [SKColor(1, 0, 0), SKColor(0, 0.95, 0)] // Main Colours for both players
    let PStartColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Colour for the start of the track
    let PGoalColour = [SKColor(0.55, 0.05, 0.05), SKColor(0.05, 0.55, 0.05)] // Colour for the goals
    let PDiceOffColour = [SKColor(0.2, 0, 0), SKColor(0, 0.2, 0)] // Colour for the off dice
    let PDiceColour = [SKColor(0.45, 0.1, 0.1), SKColor(0.1, 0.4, 0.1)] // Colour for the dice box
    let PDiceOnColour = [SKColor(1, 0.1, 0.1), SKColor(0.3, 0.95, 0.3)] // Colour for the on dice
    let BGColour = SKColor(0.1, 0.12, 0.6) // Background colour
    //let StrokeColour: SKColor = SKColor(0, 0.4, 0.8) // Stroke colour for tiles on board
    let StrokeColour = SKColor(0.1, 0.12, 0.6)
    let TileColour = SKColor(0.9, 0.9, 0.9)
    //let PTileColour = [SKColor(1, 0.93, 0.95), SKColor(0.9, 1, 0.93)] // Tile colours for both players
    let PTileColour = [SKColor(0.9, 0.7, 0.5), SKColor(0.7, 0.9, 0.5)] // Tile colours for both players
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
    let errorSound = SKAction.playSoundFileNamed("Sound/error", waitForCompletion: false)
    let rosetta = SKTexture(imageNamed: "Rosetta")
    let boost = SKTexture(imageNamed: "boost")
    var musicPlayer = AVAudioPlayer()
    let debugMode = false
    
    required init(coder: NSCoder) {
        fatalError("coder is not used in this app")
    }
    
    init(size: CGSize, data: GameData) {
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
            emitters.append(BGEmitter(size: scrSize!))
        }
        
        super.init(size: size)
        
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
        
        //self.addChild(addIndicator)
        
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
    
    func addRosette(rank: Int, side: Int) {
        let sprite = SKSpriteNode(texture: rosetta)
        //let sprite = SKSpriteNode(imageNamed: "Stock Tkn P1")
        let arrow = SKSpriteNode(texture: boost)
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
            arrow.texture = SKTexture(imageNamed: "boostP\(side)")
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
        return CGPoint(x: (CGFloat(x)+1/2)*horzShift, y: CGFloat(y)*vertShift)
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
