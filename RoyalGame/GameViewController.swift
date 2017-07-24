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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        skView.preferredFramesPerSecond = 60
        
        data = GameData(controller: self)

        gameScene = GameScene(size: skView.bounds.size, data: data)
        data.scene = gameScene
        data.newGame()
        
        let tutorialScene = TutorialScene(size: skView.bounds.size)

        // Configure the view.
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        gameScene.scaleMode = .aspectFill
            
        skView.presentScene(gameScene)
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
