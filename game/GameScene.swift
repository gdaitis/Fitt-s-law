//
//  GameScene.swift
//  game
//
//  Created by Vytautas Gudaitis on 19/11/15.
//  Copyright (c) 2015 gd. All rights reserved.
//
//  STUDENT ID: 464617

import SpriteKit
import GameplayKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player")
    let monster = SKSpriteNode(imageNamed: "monster")
    var width = CGFloat(0)
    var distance = CGFloat(0)
    let monsterAspectRatio = 0.675
    var animationOngoing: Bool = false
    var touchLocation = CGPointMake(0, 0)
    var label: SKLabelNode!
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    var monstersDead = 0
    var throughput: CGFloat!
    var userThroughput: CGFloat!
    
    func recountParametersForThroughput(throughput: CGFloat) {
        let ID = 1 / throughput
        let distanceToWidthRatio = pow(CGFloat(2), ID) - 1
        width = random(min: 50, max: 100)
        distance = width * distanceToWidthRatio
    }
    
    func countThroughputForTime(time: CGFloat) -> CGFloat {
        return log2((width / distance) + 1) / time
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        
        label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Hellooooo"
        label.fontSize = 5
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: 20)
        addChild(label)
        
        addChild(player)
        addChild(monster)
        
        touchLocation = CGPointMake(size.width/2, size.height/2)
        
        refreshLocations()
    }
    
    func refreshLocations() {
        if (monstersDead < 11) {
            throughput = 1
        } else if monstersDead < 21 && monstersDead > 10 {
            throughput = 0.8
        } else {
            throughput = 0.5
        }
        recountParametersForThroughput(throughput);
        
        player.position = touchLocation
        
        var actualX: CGFloat = 0
        var actualY: CGFloat = 0
        var isOK = false
        while !isOK {
            let angle = CGFloat(Float(arc4random()) * Float((M_PI * 2)) / 0x100000000)
            actualX = player.position.x + distance * cos(angle)
            actualY = player.position.y + distance * sin(angle)
            if 0 < actualX && actualX < size.width && 0 < actualY && actualY < size.height {
                isOK = true
            }
        }
        
        monster.position = CGPoint(x: actualX, y: actualY)
        monster.size = CGSizeMake(width, width / CGFloat(monsterAspectRatio))
        
        if (!timer.valid) {
            timer = NSTimer.scheduledTimerWithTimeInterval(
                0.001,
                target:self,
                selector: Selector("updateCounter"),
                userInfo: nil,
                repeats: true
            )
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        guard animationOngoing == false else {
            return
        }
        
        touchLocation = touch.locationInNode(self)
        
        let deltaX = abs(monster.position.x - touchLocation.x)
        let deltaY = abs(monster.position.y - touchLocation.y)
        if deltaX < monster.size.width/2 && deltaY < monster.size.height/2 {
            print("hello")
            
            monstersDead++
            
            timer.invalidate()
            
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player.position
            
            let offset = touchLocation - projectile.position
            addChild(projectile)
            
            let direction = offset.normalized()
            let shootAmount = direction * 1000
            let realDest = shootAmount + projectile.position
            
            let actionMove = SKAction.moveTo(realDest, duration: 1)
            let actionMoveDone = SKAction.removeFromParent()
            
            if userThroughput < throughput {
                label.fontColor = SKColor.redColor()
            }
            
            animationOngoing = true
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]), completion: { () -> Void in
                self.refreshLocations()
                self.animationOngoing = false
            })
        } else {
            print("nope")
        }
    }
    
    func updateCounter() {
        label.fontColor = SKColor.blackColor()
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let elapsedTime: NSTimeInterval = currentTime - startTime
        let seconds = CGFloat(elapsedTime)
        userThroughput = CGFloat(round(1000*countThroughputForTime(seconds))/1000)
        label.text = "User throughput: \(userThroughput) bit/s; required throughput: \(throughput)"
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF);
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max-min) + min
    }
}


















