//
//  GameScene.swift
//  WireLoop
//
//  Created by Yas Abdolmaleki on 2018-04-17.
//  Copyright © 2018 Yas Marcu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
    let hitSound = SKAction.playSoundFileNamed("HitSound.mp3", waitForCompletion: false)
    var score = Int(0)
    
    // labels
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    
    //  sprite
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    
    // ??
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    //CREATE THE PROBE ATLAS FOR ANIMATION
    let probeAtlas = SKTextureAtlas(named:"player")
    var probeSprites = Array<Any>()
    var probe = SKSpriteNode()
    var repeatActionProbe = SKAction()
    
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        // categoryBitMask: A mask that defines which categories this physics body belongs to.
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        // collisionBitMask: A mask that defines which categories of physics can collide with this physics body.
        self.physicsBody?.collisionBitMask = CollisionBitMask.probeCategory
        // contactTestBitMask: A mask that defines which categories of bodies cause intersection notifications with this physics body.
        self.physicsBody?.contactTestBitMask = CollisionBitMask.probeCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false //prevent the player from falling off the screen
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        // Background side by side
        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
    
        //SET UP THE BIRD SPRITES FOR ANIMATION
        probeSprites.append(probeAtlas.textureNamed("probe1"))
        probeSprites.append(probeAtlas.textureNamed("probe2"))
        probeSprites.append(probeAtlas.textureNamed("probe3"))
        probeSprites.append(probeAtlas.textureNamed("probe4"))
        
        
        self.probe = createProbe()
        self.addChild(probe)
        
        //PREPARE TO ANIMATE THE PROBE AND REPEAT THE ANIMATION FOREVER
        let animateProbe = SKAction.animate(with: self.probeSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionProbe = SKAction.repeatForever(animateProbe)
        
        // add all the sprite: label...
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    override func didMove(to view: SKView) {
        createScene()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.probeCategory && secondBody.categoryBitMask == CollisionBitMask.wireCategory || firstBody.categoryBitMask == CollisionBitMask.wireCategory && secondBody.categoryBitMask == CollisionBitMask.probeCategory || firstBody.categoryBitMask == CollisionBitMask.probeCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.probeCategory{
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if isDied == false {
                isDied = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.probe.removeAllActions()
            }
        }
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameStarted == false {
            //1
            isGameStarted =  true
            probe.physicsBody?.affectedByGravity = true
            createPauseBtn()
            //2
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            //3
            self.probe.run(repeatActionProbe)
            
            
            // add pillars
            //1
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })
            //2
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            //3
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePillars = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePillars, removePillars])
            
        
            probe.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            probe.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        } else {
            //4
            if isDied == false {
                probe.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                probe.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        
        // pause/restart functions
        for touch in touches{
            let location = touch.location(in: self)
            //1
            if isDied == true {
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
            } else {
                //2
                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
        
        
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered base on fps
        if isGameStarted == true {
            if isDied == false {
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    // move background 2 pixels to the left each time
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
        }
    }

}
