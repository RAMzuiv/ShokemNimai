//
//  GameViewController.swift
//  RoyalGame
//
//  Created by Mikkel on 5/13/17.
//  Copyright (c) 2017 Mikkel Wilson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var gameScene: GameScene!
    var data: GameData!
    var skView: SKView!
    let previewMode = true // Used for creating screenshots
    let previewPlayer = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        skView.preferredFramesPerSecond = 60
        
        data = GameData(controller: self)
        if previewMode {
            data.activePlayer = previewPlayer
        }

        gameScene = GameScene(size: skView.bounds.size, data: data, preview: previewMode)
        data.scene = gameScene
        data.newGame()
        if previewMode {
            //let rig1 = [(1, 1), (7, 1), (11, 1), (2, 2), (5, 2), (9, 2)]
            //let rig2 = [(1, 2), (2, 1), (4, 2), (10, 2), (9, 1), (11, 1)]
            let rig3 = [(4, 1), (9, 1), (10, 1), (2, 2), (6, 2), (13, 2)]
            data.rig(tokens: rig3, player: previewPlayer, score: [4, 3])
            gameScene.presentText(message: "")
        }
        
        //let tutData = TutorialData(controller: self)
        let tutorialScene = TutorialScene(size: skView.bounds.size, data: data)

        // Configure the view.
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        gameScene.scaleMode = .aspectFill
            
        //skView.presentScene(gameScene)
        if !previewMode {
            skView.presentScene(tutorialScene)
        } else {
            skView.presentScene(gameScene)
        }
        //print("done!")
    }
    
    func winScreen(winner: Int) {
        let winscreen = WinScene(winner: winner, size: skView.bounds.size, controller: self)
        skView.presentScene(winscreen)
    }
    
    func newGame() {
        data.newGame()
        skView.presentScene(gameScene)
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
