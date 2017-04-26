import SpriteKit

/**
 The main game scene
 */
public class Core : SKScene
{
    var width = 800
    var height = 800
    let tempo = SKLabelNode()
    let circle = SKShapeNode(circleOfRadius: 10)
    var outerCircles = [SKShapeNode]()
    var planetList = [Planet]()
    var astronaut : Player?
    var initialPosition : CGPoint?
    var initialScale : CGPoint?
    var world = SKNode()
    let starEmitter = SKEmitterNode()
    
    /**
    Initializes the main game scene.
     
     @param the size of the SKScene
     */
    override public init(size: CGSize) {
        super.init(size: size)
        
        self.width = Int(size.width)
        self.height = Int(size.height)
        
        //Initializes the camera on the center of the scene.
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: width / 2,
                                      y: height / 2)
        self.addChild(cameraNode)
        self.camera = cameraNode
        self.camera!.zPosition += 20
        
        //Initializes the player
        let astronautPosition = CGPoint(x: width/2, y: height/2)
        let astronautSize = CGSize(width: CGFloat(width/10), height: CGFloat(width)/CGFloat(9.1))
        self.astronaut = Player(position: astronautPosition, size: astronautSize, mass: 10, parent: self)
        
        //The initial planets are on predetermined positions
        for i in 0..<5
        {
            let minSize = (2 + Double(arc4random_uniform(5))) as Double
            let step = (2 + Double(arc4random_uniform(4))) as Double
            let circleNumber = Int(5 + arc4random_uniform(8))
            
            let position = CGPoint(x: i%2 == 0 ? 2*width/10 : 8*width/10, y: (i+1) * height/5)
            let planet = Planet(circleNumber : circleNumber, minSize : minSize, step : step, position : position, parent: self)
            planetList.append(planet)
        }
        
        //Initialies the star emitter of the background.
        starEmitter.particleLifetime = 40
        starEmitter.particleBlendMode = SKBlendMode.alpha
        starEmitter.particleBirthRate = 10
        starEmitter.particleSize = CGSize(width: 1,height: 1)
        starEmitter.particleScaleRange = 2.0
        starEmitter.particleColor = SKColor(red: 255, green: 255, blue: 255, alpha: 1)
        starEmitter.position = CGPoint(x: 0, y: 0)
        starEmitter.particleSpeed = 1
        starEmitter.particleSpeedRange = 4
        starEmitter.particlePositionRange = CGVector(dx: width, dy: height)
        starEmitter.emissionAngle = 3.14
        starEmitter.advanceSimulationTime(40)
        starEmitter.particleAlpha = 0.5
        starEmitter.particleAlphaRange = 0.5
        starEmitter.zPosition = -999
        camera!.addChild(starEmitter)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Width of the SKScene
     @return the width of the SKScene
    */
    public func getWidth() -> Int
    {
        return width
    }
    
    /**
     Height of the SKScene
     @return the height of the SKScene
     */
    public func getHeight() -> Int
    {
        return height
    }
    
    /**
     Called when the update has finished, this function updates the camera position.
    */
    public override func didFinishUpdate() {
        //Follows the player with the camera. This has to be done here
        //because if its done on update the camera will start to flicker.
        camera?.position = astronaut!.shape.position
    }
    
    /**
     Considering you have a 3x3 grid of 9 width by height screens (picture a side of a rubik's cube), this function will return the index
     of the screen given the position. Do note that the only visible screen is the center one.
     @param position the candidate point
     @return the correct screen. If the point is outside all screens a -1 is returned.
    */
    func getAdjScreen(_ position : CGPoint) -> Int{
        
        var result = 0
        
        let playerPos = astronaut!.shape.position
        
        let roundedX = CGFloat(position.x)
        let roundedY = CGFloat(position.y)
        
        if(roundedX > playerPos.x + CGFloat(1.5*Double(width)) || roundedX < playerPos.x - CGFloat(1.5*Double(width)) || roundedY < playerPos.y - CGFloat(1.5*Double(height)) || roundedY > playerPos.y + CGFloat(1.5*Double(height)))
        {
            return -1 //Outside all screens. Destroy deadPlanet
        }
        
        let screenBottom = astronaut!.shape.position.y - CGFloat(height)/2
        let screenTop = astronaut!.shape.position.y + CGFloat(height)/2
        let screenLeft = astronaut!.shape.position.x - CGFloat(width)/2
        let screenRight = astronaut!.shape.position.x + CGFloat(width)/2
        
        if(position.x > screenLeft && position.x < screenRight)
        {
            result += 1
        }
        else if(position.x > screenRight)
        {
            result += 2
        }
        
        if(position.y > screenBottom && position.y < screenTop)
        {
            result += 3
        }
        else if(position.y > screenTop)
        {
            result += 6
        }
        
        return result
    }
    
    /**
     Generates new planets in not enough populated screens and destroys planets outside all adjacent screens
    */
    func generateNewPlanets()
    {
        //This part will check how many planets there are in all eight directions (as in a grid)
        var countOfPlanetsOnEachAdjScreen = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        var indexesToRemove = [Int]()
        var index = 0
        
        for planet in planetList
        {
            if let shape = planet.shape
            {
                let visibleRect = CGRect(x: astronaut!.shape.position.x - CGFloat(width) / 2, y: astronaut!.shape.position.y - CGFloat(height) / 2, width: CGFloat(width), height: CGFloat(height))
                
                
                if(!visibleRect.contains(shape.position))
                {
                    let screen = getAdjScreen(shape.position)
                    if(screen < 0)
                    {
                        //If the return is negative, the planet is outside all adjacent screens. Destroy it to free some memory.
                        planet.destroy()
                        indexesToRemove.append(index)
                    }
                    else
                    {
                        countOfPlanetsOnEachAdjScreen[screen] += 1
                    }
                }
            }
            index += 1
        }
        
        //All destroyed planets should be removed
        var indexModifier = 0
        for curIndex in indexesToRemove
        {
            planetList.remove(at: curIndex - indexModifier)
            indexModifier += 1 //Each time a planet is removed from the list, this has to be taken into account when removing the following planets
        }
        
        //Check all adjacent screens to see if there are enough planets already.
        for i in 0...8
        {
            //If the current number of planets in a given screen is less than 3, make new planets for that screen
            if(countOfPlanetsOnEachAdjScreen[i] < 3)
            {
                if(i == 4)
                {
                    continue //Visible screen. No planets should pop in the players sight.
                }
                var widthLesserLimit = -1.5*Double(width)
                if(i % 3 == 1)
                {
                    widthLesserLimit = -0.5*Double(width)
                }
                else if(i % 3 == 2)
                {
                    widthLesserLimit = 0.5*Double(width)
                }
                
                var heightLesserLimit = -1.5*Double(height)
                if i >= 3
                {
                    heightLesserLimit = -0.5*Double(height)
                }
                if(i >= 6)
                {
                    heightLesserLimit = 0.5*Double(height)
                }
                
                widthLesserLimit += Double(astronaut!.shape.position.x)
                heightLesserLimit += Double(astronaut!.shape.position.y)
                
                
                let xRange = Double(arc4random_uniform(50)) / 50
                let yRange = Double(arc4random_uniform(50)) / 50
                
                let planetPosition = CGPoint(x: widthLesserLimit + xRange * Double(width), y: heightLesserLimit + yRange * Double(height))
                
                let minSize = (2 + Double(arc4random_uniform(5))) as Double
                let step = (2 + Double(arc4random_uniform(4))) as Double
                let circleNumber = Int(5 + arc4random_uniform(8))
                
                let position = planetPosition
                let planet = Planet(circleNumber : circleNumber, minSize : minSize, step : step, position : position, parent: self)
                
                planetList.append(planet)
            }
        }
        
    }
    
    /**
     Updates the game for the new frame. Most of the game's logic takes place here.
     @param currentTime current clock time
    */
    public override func update(_ currentTime: TimeInterval)
    {
        if(astronaut!.grabbed)
        {
            //Rotate the astronaut around the planet it is currently attached to
            astronaut!.rotate(currentTime)
        }
        else
        {
            //Updates the player current time for it to work properly
            astronaut!.updateTime(currentTime)
        }
        
        //Checks if the astronaut is near enough of a planet to be grabbed or to touch it
        for planet in planetList
        {
            if(!planet.grabbed)
            {
                if let shape = planet.shape
                {
                    if (distanceModule(shape.position, astronaut!.shape.position) < Double(astronaut!.shape.size.height + planet.size.width))
                    {
                        //It is close enough, grab the planet
                        planet.grab()
                        if(astronaut!.grabbed)
                        {
                            //Oh, the astronaut is already grabbed by another planet, so touch this new planet.
                            planet.touchedPlanet()
                        }
                        else
                        {
                            //The astronaut has a hook attaching him to the planet he just grabbed.
                            astronaut!.grab(hook: Hook(fixedPoint: shape.position, movingPoint: astronaut!.shape.position, parent: self))
                            break
                        }
                    }
                }
            }
        }
        
        //Create new planets if no planets are around
        generateNewPlanets()
    }
    
    
    /**
     Touches have just began. Different checks are done depending on the state of the game, but it basically sees if it as tap
     to release the planet from an orbit or a drag to launch the player far away.
    */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(!astronaut!.grabbed)
        {
            //Check to see if the astronaut is being dragged.
            if (astronaut!.shape.contains(touches.first!.location(in: self)))
            {
                astronaut!.shape.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                initialPosition = touches.first!.location(in: self)
                
                initialScale = CGPoint(x: astronaut!.shape.xScale, y:astronaut!.shape.yScale)
            }
        }
        else
        {
            //Check to see if the astronaut should be released from orbit
            for planet in planetList
            {
                if planet.shape != nil
                {
                    if(planet.grabbed)
                    {
                        if(astronaut!.grabbed)
                        {
                            if(planet.shape?.position == astronaut!.hook?.fixedPoint)
                            {
                                astronaut!.release()
                                planet.touchedPlanet()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     Check to see if the touches have moved. If the player is being dragged, adjust its size and the calculations
     for the speed it will gain when the touch end.
    */
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let initPos = initialPosition {
            let curPos = touches.first!.location(in: self)
            let distance = CGVector(dx: initPos.x - curPos.x, dy:  initPos.y - curPos.y)
            
            astronaut!.shape.xScale = initialScale!.x / CGFloat(max(min((100 + vectorModule(vector: distance)) / 100, 3.0), 1.0))
            astronaut!.shape.yScale = initialScale!.y / CGFloat(max(min((100 + vectorModule(vector: distance)) / 100, 3.0), 1.0))
            
            astronaut!.setZRotationFromVector(vector: distance, offsetRadians: CGFloat(M_PI/2), maxSpeed: -1, time: 0)
        }
    }
    
    
    /**
     When the touches have ended, if the astronaut was being dragged, throw him in the opposite direction of the drag.
     Also, adjust its scale to give a squash and strech cartoon-like feeling.
    */
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let initPos = initialPosition {
            initialPosition = nil
            let curPos = touches.first!.location(in: self)
            let distance = CGVector(dx: initPos.x - curPos.x, dy:  initPos.y - curPos.y)
            
            let backToNormalScale = SKAction.scale(to: initialScale!.x, duration: 0.15)
            
            astronaut!.shape.run(backToNormalScale)
            
            astronaut!.shape.physicsBody?.velocity = distance
        }
    }
}
