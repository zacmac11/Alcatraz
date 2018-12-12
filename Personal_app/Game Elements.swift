//
//  Game Elements.swift
//  Personal_app
//
//  Created by Zach McDonald on 12/5/18.
//  Copyright © 2018 Maryville App Development. All rights reserved.

//This is the game elements file where all the base attributes of objects in the game are placed


import SpriteKit

struct CollisionBitMask {
    static let playerCategory:UInt32 = 0x1 << 0
    static let obstacleCategory:UInt32 = 0x1 << 1
    static let keyCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene {
    func createplayer() -> SKSpriteNode {
        //This is where the player size, position, and sprite are created
        player = SKSpriteNode(imageNamed: "player")
        player.size = CGSize(width: 75, height: 150)
        player.position = CGPoint(x:self.frame.midX, y:200)
        //Physics body added
        player.physicsBody = SKPhysicsBody(rectangleOf:player.size)
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.restitution = 0
        //collisions added
        player.physicsBody?.categoryBitMask = CollisionBitMask.playerCategory
        player.physicsBody?.collisionBitMask = CollisionBitMask.obstacleCategory | CollisionBitMask.groundCategory
        player.physicsBody?.contactTestBitMask = CollisionBitMask.obstacleCategory | CollisionBitMask.keyCategory | CollisionBitMask.groundCategory
        //finally gravity and returning the player func
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        
        return player
    }
    //This is the size, sprite, scale, and position of the restart button
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    //Same thing here for the pause button
    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }
    //The score label here not to be confused with the high score label
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.3)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        return scoreLbl
    }
    //here is where the high score label is created
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        
        highscoreLbl.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 22)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "Highest Score: \(highestScore)"
        } else {
            highscoreLbl.text = "Highest Score: 0"
        }
        highscoreLbl.zPosition = 5
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "Helvetica-Bold"
        return highscoreLbl
    }
    //This is the creation of the logo which appears only on the start screen
    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "logo")
        logoImg.size = CGSize(width: 272, height: 65)
        logoImg.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    //The tap to play label which tells the players how to start the game
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 50)
        taptoplayLbl.text = "Tap anywhere to play"
        taptoplayLbl.fontColor = UIColor(red: 79/255, green: 71/255, blue: 69/255, alpha: 1.0)
        taptoplayLbl.zPosition = 5
        taptoplayLbl.fontSize = 20
        taptoplayLbl.fontName = "HelveticaNeue"
        return taptoplayLbl
    }
    func createObstacle() -> SKNode  {
        // This is the physics body, position, size and sprite for the key. Keys always spawn above the obstacle object
        let keyNode = SKSpriteNode(imageNamed: "key")
        keyNode.size = CGSize(width: 80, height: 40)
        keyNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        keyNode.physicsBody = SKPhysicsBody(rectangleOf: keyNode.size)
        keyNode.physicsBody?.affectedByGravity = false
        keyNode.physicsBody?.isDynamic = false
        keyNode.physicsBody?.categoryBitMask = CollisionBitMask.keyCategory
        keyNode.physicsBody?.collisionBitMask = 0
        keyNode.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory
        keyNode.color = SKColor.blue
        // This is where the obstacle is created I left space open so I can add more obstacles in at a later point
        obstacles = SKNode()
        obstacles.name = "obstacles"
        
  
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        
       
        obstacle.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 420)
        
       
        obstacle.setScale(0.5)
        
        
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = CollisionBitMask.obstacleCategory
        obstacle.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory
        obstacle.physicsBody?.contactTestBitMask = CollisionBitMask.obstacleCategory
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.affectedByGravity = false
        
        
        
        
        obstacles.addChild(obstacle)
        
        obstacles.zPosition = 1
        // This is where the height of the obstacle gets randomized
        let randomPosition = random(min: -80, max: -10)
        obstacles.position.y = randomPosition
        obstacles.addChild(keyNode)
        
        obstacles.run(moveAndRemove)
        
        return obstacles
    }
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
 }
}
