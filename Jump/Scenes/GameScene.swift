//
//  GameScene.swift
//  Jump
//
//  Created by Marcus Mletzko on 26.02.21.
//

import SpriteKit

class GameScene: SKScene {
    
    var square: SKSpriteNode!
    var scoreLabel = SKLabelNode(text: "Score: 0")
    var score = 0
    var currentJumps = 0
    var difficulty = 100.0
    var jumpForce: CGFloat!
    var diveForce: CGFloat!
    var diveTimer = Timer()
    var spawnTimer = Timer()
    var difficultyTimer = Timer()
    var powerUpTimer = Timer()
    var powerUpSpawnTimer = Timer()
    var isGameOver = false
    var isPowerUp = false
    var obsticles = Set<SKSpriteNode>()
    var powerUps = Set<SKSpriteNode>()
    
    let maxJumps = 3
    
    override func didMove(to view: SKView) {
        setupPhysics()
        layoutScene()
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        jumpForce = frame.size.height / 10
        diveForce = -frame.size.height / 8
        createSquare()
        createFloor()
        createCeiling()
        createScoreLabel()
        createBackWall()
        increaseDifficulty()
        difficultyTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(increaseDifficulty), userInfo: nil, repeats: true)
        powerUpSpawnTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int.random(in: 7 ..< 11)), target: self, selector: #selector(spawnPowerUps), userInfo: nil, repeats: true)
    }
    
    @objc func increaseDifficulty() {
        difficulty *= 0.9
        spawnTimer.invalidate()
        spawnTimer = Timer.scheduledTimer(timeInterval: difficulty / 100, target: self, selector: #selector(spawnObastcles), userInfo: nil, repeats: true)
    }
    
    func createSquare() {
        square = SKSpriteNode(texture: SKTexture(imageNamed: "square"), color: UIColor.white, size: CGSize(width: frame.size.width / 16, height: frame.size.width / 16))
        square.position = CGPoint(x: frame.minX + 200, y: frame.minY + square.size.height * 3)
        square.zPosition = ZPositions.square
        square.name = "square"
        square.physicsBody = SKPhysicsBody(rectangleOf: square.size)
        square.physicsBody?.categoryBitMask = PhysicsCategories.squareCategory
        square.physicsBody?.contactTestBitMask = PhysicsCategories.obstacleCategory | PhysicsCategories.floorCategory | PhysicsCategories.backWallCategory | PhysicsCategories.powerUpCategory
        square.physicsBody?.collisionBitMask = PhysicsCategories.floorCategory | PhysicsCategories.obstacleCategory
        square.physicsBody?.allowsRotation = false
        addChild(square)
    }
    
    func createFloor() {
        let floor = SKSpriteNode(texture: SKTexture(imageNamed: "square"), color: UIColor.white, size: CGSize(width: self.size.width, height: frame.size.width / 16))
        floor.position = CGPoint(x: frame.midX, y: frame.minY + frame.size.height / 16)
        floor.zPosition = ZPositions.floor
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = PhysicsCategories.floorCategory
        floor.physicsBody?.isDynamic = false
        addChild(floor)
    }
    
    func createCeiling() {
        let ceiling = SKSpriteNode(texture: SKTexture(imageNamed: "square"), color: UIColor.white, size: CGSize(width: self.size.width, height: 1.0))
        ceiling.position = CGPoint(x: frame.midX, y: frame.maxY + 1)
        ceiling.zPosition = ZPositions.floor
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.isDynamic = false
        addChild(ceiling)
    }
    
    func createBackWall() {
        let backWall = SKSpriteNode(texture: SKTexture(imageNamed: "square"), color: UIColor.white, size: CGSize(width: 1.0, height: self.size.height))
        backWall.position = CGPoint(x: frame.minX - 1, y: frame.midY)
        backWall.zPosition = ZPositions.floor
        backWall.physicsBody = SKPhysicsBody(rectangleOf: backWall.size)
        backWall.physicsBody?.categoryBitMask = PhysicsCategories.backWallCategory
        backWall.physicsBody?.isDynamic = false
        addChild(backWall)
    }
    
    func createScoreLabel() {
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - frame.size.height / 6)
        scoreLabel.zPosition = ZPositions.label
        addChild(scoreLabel)
    }
    
    @objc func spawnObastcles() {
        let obstacleLow = Int.random(in: 0 ..< 2)
        let randomUp = Int.random(in: Int(frame.size.width / 8)..<Int(frame.maxY - frame.size.height / 6))
        let randomWidth = CGFloat(Int.random(in: Int(frame.size.width / 25)..<Int(frame.size.width / 6)))
        let randomHeight = CGFloat(Int.random(in: Int(frame.size.width / 25)..<Int(frame.size.width / 12)))
        let randomSize = CGSize(width: randomWidth, height: randomHeight)
        
        let obstacle = SKSpriteNode(texture: SKTexture(imageNamed: "square"), color: UIColor.white, size: randomSize)
        if obstacleLow == 0 {
            obstacle.position = CGPoint(x: frame.maxX + frame.size.width / 16, y: CGFloat(frame.size.width / 10))
        } else {
            obstacle.position = CGPoint(x: frame.maxX + frame.size.width / 16, y: CGFloat(randomUp))
        }
        obstacle.name = "obstacle"
        obstacle.zPosition = ZPositions.obstacles
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = PhysicsCategories.obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategories.backWallCategory
        obstacle.physicsBody?.collisionBitMask = PhysicsCategories.powerUpCategory
        obstacle.physicsBody?.allowsRotation = false
        addChild(obstacle)
        obsticles.insert(obstacle)
    }
    
    @objc func spawnPowerUps() {
        let randomY = Int.random(in: Int(frame.size.width / 10)..<Int(frame.maxY - frame.size.height / 6))
        
        let powerUp = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: UIColor.white, size: CGSize(width: 30.0, height: 30.0))
        powerUp.position = CGPoint(x: frame.maxX + frame.size.width / 16, y: CGFloat(randomY))
        powerUp.zPosition = ZPositions.obstacles
        powerUp.name = "powerUp"
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.height / 2)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategories.powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategories.backWallCategory
        addChild(powerUp)
        powerUps.insert(powerUp)
    }
    
    func jump() {
        if currentJumps < maxJumps {
            let color: [CGFloat] = randomColor()
            square.color = UIColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
            square.colorBlendFactor = 1.0
            currentJumps += 1
            square.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpForce))
        }
    }
    
    func dive() {
        if square.position.y > frame.minY + frame.size.height / 4.85 {
            diveVector()
            diveTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(diveVector), userInfo: nil, repeats: true)
        }
    }
    
    @objc func diveVector() {
        if square.position.y > frame.minY + frame.size.height / 4.85 {
            square.physicsBody?.applyImpulse(CGVector(dx: 0, dy: diveForce))
        }
    }
    
    func
    beginPowerUp() {
        powerUpTimer.invalidate()
        square.physicsBody?.collisionBitMask = PhysicsCategories.floorCategory
        powerUpTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(endPowerUp), userInfo: nil, repeats: false)
    }
    
    @objc func endPowerUp() {
        square.physicsBody?.collisionBitMask = PhysicsCategories.floorCategory | PhysicsCategories.obstacleCategory
        isPowerUp = false
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: " + "\(score)"
    }
    
    func randomColor() -> [CGFloat] {
        let red = CGFloat(Int.random(in: 100..<255))
        let green = CGFloat(Int.random(in: 100..<255))
        let blue = CGFloat(Int.random(in: 100..<255))
        let color: [CGFloat] = [red, green, blue]
        return color
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "HighScore") {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        spawnTimer.invalidate()
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if t.location(in: self).x >= frame.size.width / 2 {
                jump()
            } else {
                dive()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            diveTimer.invalidate()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for o in obsticles {
            o.physicsBody!.velocity = CGVector(dx: -500.0, dy: 8.0)
        }
        
        for p in powerUps {
            p.physicsBody!.velocity = CGVector(dx: -500.0, dy: 7.5)
            let color: [CGFloat] = randomColor()
            p.color = UIColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
            p.colorBlendFactor = 1.0
        }
        
        if isPowerUp {
            let color: [CGFloat] = randomColor()
            square.color = UIColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
            square.colorBlendFactor = 1.0
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        
        // square collision
        
        if contactMask == PhysicsCategories.squareCategory | PhysicsCategories.floorCategory {
            currentJumps = 0
        }
        
        if contactMask == PhysicsCategories.squareCategory | PhysicsCategories.powerUpCategory {
            if let powerUp = contact.bodyA.node?.name == "powerUp" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                powerUp.removeFromParent()
                self.powerUps.remove(powerUp)
            }
            
            if isPowerUp {
                self.beginPowerUp()
            } else {
                isPowerUp = true
                self.beginPowerUp()
            }
        }
        
        if contactMask == PhysicsCategories.squareCategory | PhysicsCategories.obstacleCategory {
            if isPowerUp {
                if let obstacle = contact.bodyA.node?.name == "obstacle" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                    obstacle.removeFromParent()
                    self.obsticles.remove(obstacle)
                    score += 5
                    updateScoreLabel()
                }
            } else {
                isGameOver = true
                self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
                    self.gameOver()
                })
            }
        }
        
        
        
        // backwall collision
        
        if contactMask == PhysicsCategories.backWallCategory | PhysicsCategories.obstacleCategory {
            if !isGameOver {
                score += 1
                updateScoreLabel()
            }
            if let obstacle = contact.bodyA.node?.name == "obstacle" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                obstacle.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                    obstacle.removeFromParent()
                    self.obsticles.remove(obstacle)
                })
            }
        }
        
        if contactMask == PhysicsCategories.backWallCategory | PhysicsCategories.powerUpCategory {
            if let powerUp = contact.bodyA.node?.name == "powerUp" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                powerUp.removeFromParent()
                self.powerUps.remove(powerUp)
            }
        }
        
        if contactMask == PhysicsCategories.backWallCategory | PhysicsCategories.squareCategory {
            if let square = contact.bodyA.node?.name == "square" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                square.removeFromParent()
            }
        }
    }
}
