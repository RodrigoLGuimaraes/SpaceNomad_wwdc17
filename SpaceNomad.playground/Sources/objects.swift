import SpriteKit

/**
 Protocol to apply polimorfism on multiple objects of the type Entity.
 Ended up being pretty much unused
 */
protocol Entity
{
    func move(velocity : CGVector)
}

/**
 Hook to tie the player and a planet together when in Orbit.
 */
public class Hook
{
    var shape : SKShapeNode
    var fixedPoint : CGPoint
    var movingPoint : CGPoint
    var angle : Double
    var distance : Double
    var currentSpeed : Double
    let acceleration = 0 as Double
    
    /**
     Initiates a Hook
     @param fixedPoint The CGPoint that will stay in place when the hook is rotated
     @param movingPoint The CGPoint that will move when the hook is rotated
     @param parent The SKNode that will be the parent of the newly created hook in the SKScene hierarchy
    */
    public init (fixedPoint: CGPoint, movingPoint: CGPoint, parent: SKNode)
    {
        self.fixedPoint = fixedPoint
        self.movingPoint = movingPoint
        let path = CGMutablePath()
        path.move(to: fixedPoint)
        path.addLine(to: movingPoint)
        let line = SKShapeNode(path: path)
        line.zPosition = -10
        line.strokeColor = SKColor.init(red: 66, green: 134, blue: 244, alpha: 1)
        line.lineWidth = 2
        self.shape = line
        
        parent.addChild(self.shape)
        
        self.angle = 0
        self.distance = 0
        self.currentSpeed = 90
        calculateAngle()
        updateDistance()
    }
    
    /**
        Calculates the current angle of the hook (i.e. angle of the movingPoint - fixedPoint vector) and updates
        the angle instance variable.
    */
    public func calculateAngle()
    {
        let distanceVector = CGVector(dx: movingPoint.x - fixedPoint.x, dy: movingPoint.y - fixedPoint.y)
        
        angle = vectorAngle(vector: distanceVector)
    }
    
    /**
        Updates the distance instance variable by calculating the module of the CGVector movingPoint - fixedPoint
    */
    public func updateDistance()
    {
        distance = distanceModule(fixedPoint, movingPoint)
    }
    
    /**
        Updates the hook.
     
        @param newMovingPoint the new location of the movingPoint
        @param updateDistance whether the code should update the distance instance variable or not. This should be true if the moving point is farther or closer to the fixedPoint in relation to the previous movingPoint. NOTE: If you are not sure, pass true, you will only lose performance.
    */
    public func update(newMovingPoint: CGPoint, updateDistance : Bool)
    {
        self.movingPoint = newMovingPoint
        
        let path = CGMutablePath()
        path.move(to: fixedPoint)
        path.addLine(to: movingPoint)
        shape.path = path
        calculateAngle()
        if(updateDistance)
        {
            self.updateDistance()
        }
    }
    
    /**
        Rotates the hook by giving a new angle to the angle instance variable, updating the distance and redrawing the hook.
     
        @param isClockwise whether the movement is clockwise rotation or not
        @param time the current time is used to calculate the time since the last rotation and guarantee the speed no matter the FPS
    */
    public func rotate(isClockwise: Bool, time: TimeInterval) -> CGPoint
    {
        let direction = (isClockwise ? -1 : 1) as Double
        angle += degreeToRadian(currentSpeed * time) * direction
        currentSpeed += acceleration * time
        movingPoint = rotatePoint(pointToRotate: movingPoint, pivot: fixedPoint, angle: angle)
        update(newMovingPoint: movingPoint, updateDistance: false)
        return movingPoint
    }
    
    /**
        Removes the hook from the SKScene
    */
    public func destroy()
    {
        shape.removeFromParent()
    }

    
}

/**
    Player class.
 */
public class Player : Entity
{
    var shape : SKSpriteNode
    var grabbed : Bool
    var hook : Hook?
    
    var lastTime : TimeInterval
    var movementDirection : CGVector
    var angleTurnDirection : Int
    var velocityGrabbed : CGVector
    var justGrabbed : Bool
    var isClockwise : Bool
    
    
    /**
     Inits the player class.
     
     @param position initial position of the player
     @param size initial size of the player
     @param mass physics body mass
     @param parent parent of the player in the SKScene
    */
    public init(position : CGPoint, size : CGSize, mass : CGFloat, parent : SKNode?){
        self.grabbed = false
        self.shape = SKSpriteNode(imageNamed: "astronaut")
        shape.position = position
        shape.scale(to: size)
        shape.zPosition = 100
        
        shape.physicsBody = SKPhysicsBody(rectangleOf: size)
        shape.physicsBody!.mass = mass
        shape.physicsBody!.affectedByGravity = false
        
        if(parent != nil)
        {
            parent?.addChild(self.shape)
        }
        
        self.movementDirection = CGVector.zero
        self.velocityGrabbed = CGVector.zero
        self.lastTime = -1
        self.angleTurnDirection = 0
        self.justGrabbed = false
        self.isClockwise = false
    }
    
    /**
     Sets the new zrotation of the player to the same angle of the vector(+offset) IF this angle is not too far given the maxSpeed.
     If the angle is too far, moves at the maximumSpeed towards the angle.
     
     @param vector used to calculate the new angle
     @param offsetRadians difference between the vector angle and the new player angle
     @param maxSpeed max speed to move towards the angle
     @param time the current time is used to calculate the time since the last update and guarantee the speed no matter the FPS
    */
    func setZRotationFromVector(vector : CGVector, offsetRadians : CGFloat, maxSpeed: Double, time: TimeInterval)
    {
        let newAngle = CGFloat(vectorAngle(vector: vector)) - offsetRadians
        if(maxSpeed <= 0)
        {
            shape.zRotation = newAngle
        }
        else
        {
            var angleDiff = newAngle - shape.zRotation
            
            angleDiff = CGFloat(smallerDegreeDistance(angle: Double(angleDiff)))
            
            let maxChange = maxSpeed * time
            
            if(abs(Double(angleDiff)) < maxChange)
            {
                angleTurnDirection = 0
                shape.zRotation = newAngle
            }
            else
            {
                if angleTurnDirection != 0 && Double(angleDiff) < 1.5 * maxChange
                {
                    shape.zRotation += CGFloat(maxChange) * CGFloat(angleTurnDirection) * (isClockwise ? -1.0 : 1.0)
                }
                else
                {
                    if(angleDiff > 0)
                    {
                        angleTurnDirection = 1
                        shape.zRotation += CGFloat(maxChange) * (isClockwise ? -1.0 : 1.0)
                    }
                    else
                    {
                        angleTurnDirection = -1
                        shape.zRotation -= CGFloat(maxChange) * (isClockwise ? -1.0 : 1.0)
                    }
                }
            }
        }
    }
    
    /**
     @param time the current time is used to calculate the time since the last update and guarantee the good working of the player no matter the FPS
    */
    func updateTime(_ time: TimeInterval)
    {
        lastTime = time
    }
    
    /**
     Rotates the player having its hook fixedPoint as the pivot.
     @param time the current time is used to calculate the time since the last update and guarantee the speed no matter the FPS
    */
    func rotate(_ time: TimeInterval)
    {
        if(lastTime < 0)
        {
            lastTime = time
            return
        }
        
        if(justGrabbed)
        {
            justGrabbed = false
            let movementDirection = orthogonal(vector: distanceVector(startPoint: hook!.fixedPoint, endPoint: hook!.movingPoint), invert: true)
            let newAngle = CGFloat(vectorAngle(vector: movementDirection)) - CGFloat(-M_PI/2)
            let angleDiff = newAngle - shape.zRotation
            
            isClockwise = false
            if(abs(angleDiff) > CGFloat(M_PI))
            {
                isClockwise = true
            }
        }
        
        let newPos = hook!.rotate(isClockwise: isClockwise, time: time - lastTime)
        
        movementDirection = orthogonal(vector: distanceVector(startPoint: hook!.fixedPoint, endPoint: hook!.movingPoint), invert: true)
        
        let offsetRadians = isClockwise ? CGFloat(-M_PI/2) : CGFloat(M_PI/2)
        setZRotationFromVector(vector: movementDirection, offsetRadians: offsetRadians, maxSpeed: degreeToRadian(120), time: time - lastTime)
        
        shape.position = newPos
        
        lastTime = time
    }
    
    /**
        Attributes the velocity to the player's physicsBody
        @param velocity the new velocity of the player
    */
    func move(velocity : CGVector)
    {
        shape.physicsBody!.velocity = velocity
    }
    
    /**
     Grabs the player (i.e. the player is now orbiting a planet)
     @param hook the hook that connects the player to the planet he is orbiting
    */
    func grab(hook: Hook)
    {
        self.velocityGrabbed = self.shape.physicsBody!.velocity
        self.shape.physicsBody!.velocity = CGVector.zero
        self.hook = hook
        self.grabbed = true
        self.justGrabbed = true
    }
    
    /**
     Releases the player (i.e. he is not orbiting a planet anymore)
    */
    func release()
    {
        var outVelocity = rotateVector(vector: movementDirection, angleRadians: isClockwise ? CGFloat(M_PI) : 0)
        let scalingFactor = CGFloat(self.hook!.currentSpeed / 90)
        outVelocity.dx *= scalingFactor
        outVelocity.dy *= scalingFactor
        self.shape.physicsBody!.velocity = outVelocity
        self.hook!.destroy()
        self.hook = nil
        self.grabbed = false
    }
}

let MAX_PLANET_WIDTH = 70 //Not exactly correct
let MIN_PLANET_WIDTH = 12

/**
 Class that represents a Planet.
 */
public class Planet
{
    var shape : SKShapeNode?
    var afterShapes = [SKShapeNode]()
    var gravityShape : SKShapeNode?
    var animations = [SKAction]()
    var entityList = [Entity]()
    var grabbed : Bool
    var size : CGSize
    let soundPlayer = SoundPlayer()
    
    /**
     Initializes a planet. This simplified constructor is not currently used.
     @param shape shape of the planet before it is touched
     @param afterShapes list of shapes that will represent the planet after it is touched
     @param animations list of animations (each correspoding to an aftershape) to play when the planet is touched
     @param size planetSize
    */
    public init(shape: SKShapeNode, afterShapes : [SKShapeNode], animations : [SKAction], size : CGSize) {
        self.grabbed = false
        self.shape = shape
        self.afterShapes = afterShapes
        self.animations = animations
        self.size = size
    }
    
    /**
     Destroys a planet by removing it from scene and nullifying all pointers
    */
    public func destroy()
    {
        if let s = shape
        {
            s.removeFromParent()
            shape = nil
        }
        
        if let s = gravityShape
        {
            s.removeAllActions()
            s.removeFromParent()
            gravityShape = nil
        }
        
        for s in afterShapes
        {
            s.removeFromParent()
        }
        
        afterShapes = []
        
        animations = []
    }
    
    /**
     Initializes a planet. If in doubt in some parameters, see the other constructor for more details.
     @param circleNumber number of circles that will be used to create the aftershapes
     @param minSize minimumSize of an afterShape
     @param step minimum distance between two consecutive afterShapes
     @param position center position of all the shapes
     @param parent parent of the planet in the SKScene
    */
    public init(circleNumber : Int, minSize : Double, step : Double, position : CGPoint, parent: SKNode)
    {
        let planetSize = CGFloat(minSize) + CGFloat(circleNumber) * CGFloat(step)
        self.size = CGSize(width: planetSize, height: planetSize)
        let planetShape = SKShapeNode(circleOfRadius: planetSize)
        planetShape.position = position
        planetShape.fillColor = planetColorList[Int(arc4random_uniform(UInt32(planetColorList.count)))]
        planetShape.strokeColor = SKColor.gray.withAlphaComponent(0)
        parent.addChild(planetShape)
        
        let gravityShape = SKShapeNode(circleOfRadius: planetSize)
        gravityShape.position = position
        gravityShape.fillColor = SKColor.white.withAlphaComponent(0)
        gravityShape.strokeColor = planetShape.fillColor
        let timeBetweenRings = (1000 + Double(arc4random_uniform(1500))) / 1000
        let fadingEffect = SKAction.sequence([
            SKAction.wait(forDuration: timeBetweenRings),
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.fadeAlpha(to: 1, duration: 0.01)
            ])
        let scalingEffect = SKAction.sequence([
            SKAction.wait(forDuration: timeBetweenRings),
            SKAction.scale(by: 2, duration: 0.5),
            SKAction.scale(by: 0.5, duration: 0.01)
            ])
        gravityShape.run(SKAction.repeatForever(fadingEffect))
        gravityShape.run(SKAction.repeatForever(scalingEffect))
        parent.addChild(gravityShape)
        
        var circleList = [SKShapeNode]()
        var animationList = [SKAction]()
        for i in 0 ..< circleNumber
        {
            let circleRadius = Double(minSize) + Double(step)*Double(i)
            let outerCircle = SKShapeNode(circleOfRadius: CGFloat(circleRadius))
            outerCircle.lineWidth = max(CGFloat((CGFloat(minSize) - 10.0) / 2.0), 1)
            outerCircle.fillColor = SKColor.white.withAlphaComponent(0)
            outerCircle.position = planetShape.position
            
            circleList.append(outerCircle)
            outerCircle.isHidden = true
            parent.addChild(outerCircle)
            
            let xRandom = Double(arc4random_uniform(UInt32(minSize)))
            let yRandom = Double(arc4random_uniform(UInt32(minSize)))
            let timeRandom = Double(arc4random_uniform(500)) / 1000.0
            let scaleRandom = CGFloat(Double(arc4random_uniform(10))/5.0)
            outerCircle.strokeColor = SKColor.init(red: CGFloat(xRandom / Double(minSize)), green: CGFloat(yRandom / Double(minSize)), blue: CGFloat((xRandom + yRandom) / Double(minSize)) / 2, alpha: 1)
            let upAndDown = SKAction.sequence([
                SKAction.moveBy(x: CGFloat(xRandom), y: CGFloat(yRandom), duration: timeRandom),
                SKAction.moveBy(x: CGFloat(-xRandom), y: CGFloat(-yRandom), duration: timeRandom)
                ])
            let scalingAnim = SKAction.sequence([
                SKAction.scale(by: scaleRandom, duration: timeRandom),
                SKAction.scale(to: 1, duration: timeRandom)
                ])
            
            animationList.append(SKAction.sequence([scalingAnim, upAndDown]))
        }
        
        self.grabbed = false
        self.shape = planetShape
        self.afterShapes = circleList
        self.animations = animationList
    }
    
    /**
     When the planet is touched (by the player, not by your finger. But you can modify this if you want) some animation plays, the main shape
     is destroyed and the afterShapes take place. This transition is animated.
    */
    public func touchedPlanet()
    {
        if let curShape = shape {
            shape = nil
            
            curShape.isHidden = true
            
            for i in 0..<afterShapes.count
            {
                afterShapes[i].isHidden = false
                afterShapes[i].run(animations[i])
            }
            
            //Calculates the index according to the planet size
            let soundIndex = Int(11 - Double((self.size.width - CGFloat(MIN_PLANET_WIDTH)) / CGFloat(MAX_PLANET_WIDTH)) * 11)
            soundPlayer.play(index: soundIndex)
            
        }
        
    }
    
    /**
     Sets the grabbed instance variable. Good to know if this planet should be taken into consideration when the player is near to a planet.
    */
    public func grab()
    {
        self.grabbed = true
    }
}
