//
//  GameScene.swift
//  Personal_app
//
//  Created by Zach McDonald on 10/30/18.
//  Copyright © 2018 Maryville App Development. All rights reserved.

//This is the game scene file where all the actions of objects in the game take place


import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
    let keySound = SKAction.playSoundFileNamed("keySound.wav", waitForCompletion: false)
    //^the line above is the sound that plays when you interact with the key
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var obstacles = SKNode()
    var moveAndRemove = SKAction()
    
   
    let playerAtlas = SKTextureAtlas(named:"player")
    var playerSprites = Array<Any>()
    var player = SKSpriteNode()
    var repeatActionplayer = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameStarted == false{
            //testing if the game has been started and creates the pause button
            isGameStarted =  true
            createPauseBtn()
            //gets rid of the logo and tap to play label
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            //starts the player running function
            self.player.run(repeatActionplayer)
            
            //obstacles start spawning in. If I add more obstacles they will also be spawned in here
            let spawn = SKAction.run({
                () in
                self.obstacles = self.createObstacle()
                self.addChild(self.obstacles)
            })
            //This keeps the spawn time the same can be changed for more added challenge
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            //moves the obstacles at a constant pace and removes them from the screen
            let distance = CGFloat(self.frame.width + obstacles.frame.width)
            let moveobstacle = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removeobstacle = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveobstacle, removeobstacle])
            
        
           
        } else {
            //checks if the player is alive and if so he is able to jump
            if isDied == false {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 275)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 275))
            }
        }
        for touch in touches{
            let location = touch.location(in: self)
            //if you are dead it spawns the restart button to start the game over and saves the high score
            if isDied == true{
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
                //if the pause button is touched it pauses the game and the button switches to a play button
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
        // Called before each frame is rendered
        if isGameStarted == true{
            if isDied == false{
                enumerateChildNodes(withName: "ground", using: ({
                    (node, error) in
                    let ground = node as! SKSpriteNode
                    ground.position = CGPoint(x: ground.position.x - 2, y: ground.position.y)
                    if ground.position.x <= -ground.size.width {
                        ground.position = CGPoint(x:ground.position.x + ground.size.width * 2, y:ground.position.y)
                    }
                }))
            }
        }
    }
    //This function here makes everything appear in the game scene
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.white
        for i in 0..<2
        {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.anchorPoint = CGPoint.init(x: 0, y: 0)
            ground.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            ground.name = "ground"
            ground.size = (self.view?.bounds.size)!
            ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: UIScreen.main.bounds.width, height: 250))
            ground.physicsBody?.isDynamic = false
            self.addChild(ground)
        }
        self.player = createplayer()
        self.addChild(player)
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    //when the game starts this function is called and adds collisions between objects
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.obstacleCategory || firstBody.categoryBitMask == CollisionBitMask.obstacleCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory || firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory{
            enumerateChildNodes(withName: "obstacles", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if isDied == false{
                isDied = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.player.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.keyCategory {
            run(keySound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.keyCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory {
            run(keySound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    //finally here is the restart function that removes everthing changes you back to alive and the game hasnt started
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }

}
