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
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(size: CGSize, data: TutorialData) {
        super.init(size: size, data: data)
        
        // Add the tiles to the board
        /*
        let side = 1
        for rank in (1...4) {
            addTile(at: rank, side: side, bigTile: rank==4)
        }
        for rank in [13, 14] {
            addTile(at: rank, side: side, bigTile: rank==13)
        }
        for rank in (5...12) {
            addTile(at: rank, side: 0, bigTile: (rank==12)||(rank==5))
        }
        // Add the rosettes
        for rosette in [4,9,14] {
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
            addRosette(rank: rosette, side: 1)
        }
        */
    }
    
    override func addTile(at rank: Int, side: Int, bigTile: Bool = false, withButton: Bool = true) {
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
        let inRect = SKSpriteNode(color: tileColour, size: CGSize(width: TileSize!-1, height: TileSize!-1))
        let outRect = SKSpriteNode(color: StrokeColour, size: CGSize(width: TileSize!+1, height: TileSize!+1))
        
        if bigTile {
            //inRect.yScale = (1 + (vertGap/(TileSize!+1) * 2/3))
            inRect.size.height = TileSize!+vertGap*1/2-1
            outRect.size.height = TileSize!+vertGap*1/2+1
            if side == 1 {
                inRect.position = CGPoint(x: coords.x, y: coords.y+vertGap/4)
                outRect.position = CGPoint(x: coords.x, y: coords.y+vertGap/4)
            } else if side == 2 {
                inRect.position = CGPoint(x: coords.x, y: coords.y-vertGap/4)
                outRect.position = CGPoint(x: coords.x, y: coords.y-vertGap/4)
            } else if side == 0 {
                inRect.position = CGPoint(x: coords.x, y: coords.y-vertGap/4)
                outRect.position = CGPoint(x: coords.x, y: coords.y-vertGap/4)
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
}


















