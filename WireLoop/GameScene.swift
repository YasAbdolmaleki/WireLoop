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
    var repeatActionBird = SKAction()
    
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
        self.repeatActionBird = SKAction.repeatForever(animateProbe)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
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
