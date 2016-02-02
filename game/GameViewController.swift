//
//  GameViewController.swift
//  game
//
//  Created by Vytautas Gudaitis on 19/11/15.
//  Copyright (c) 2015 gd. All rights reserved.
//
//  STUDENT ID: 464617

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
