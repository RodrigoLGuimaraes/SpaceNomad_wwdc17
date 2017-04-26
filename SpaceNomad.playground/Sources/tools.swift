import SpriteKit
import Foundation

/* THIS FILE CONSISTS OF SOME HELPER FUNCTIONS. MOST OF THEM DEAL WITH CGVectors and Angles */

/**
 Calculates the module of the distance between two points
 @param a first point
 @param b second point
 */
public func distanceModule(_ a: CGPoint, _ b : CGPoint) -> Double
{
    let distX = Double(a.x - b.x)
    let distY = Double(a.y - b.y)
    
    return sqrt(distX * distX + distY * distY)
}

/**
 Converts degrees to radians
 @param angle angle in degrees
 @return angle in radians
 */
public func degreeToRadian(_ angle: Double) -> Double
{
    return angle * Double(M_PI) / Double(180)
}

/**
 Converts radians to degrees
 @param angle angle in radians
 @return angle in degrees
 */
public func radianToDegree(_ angle: Double) -> Double
{
    return angle * Double(180) / Double(M_PI)
}

/**
 Returns a vector orthogonal to the input vector.
 @param vector the input vector
 @param invert whether the x or the y coordinate will have its signal changed
 @return the output vector that is orthogonal to the input vector
 */
public func orthogonal (vector : CGVector, invert : Bool) -> CGVector
{
    if(invert)
    {
        return CGVector(dx: -vector.dy , dy: vector.dx)
    }
    return CGVector(dx: -vector.dx , dy: vector.dy)
}

/**
 Returns the vector between startPoint and endPoint
 @param startPoint the starting point of the vector
 @param endPoint the end point of the vector
 @return the vector between startPoint and endPoint
 */
public func distanceVector (startPoint: CGPoint, endPoint: CGPoint) -> CGVector
{
    return CGVector(dx: endPoint.x - startPoint.x, dy: endPoint.y - startPoint.y)
}

/**
 Returns the module of a vector
 @param vector the input vector
 @return the module of the input vector
 */
public func vectorModule(vector : CGVector) -> Double
{
    return sqrt(Double(vector.dx * vector.dx) + Double(vector.dy * vector.dy))
}

/**
 Returns the angle of the input vector
 @param vector the input vector
 @return the angle of the input vector
 */
public func vectorAngle(vector: CGVector) -> Double
{
    
    var angle = atan(Double(abs(vector.dy))/Double(abs(vector.dx)))
    
    if(vector.dx < 0 && vector.dy > 0)
    {
        angle = degreeToRadian(180) - angle
    }
    else if(vector.dx < 0 && vector.dy < 0)
    {
        angle += degreeToRadian(180)
    }
    else if(vector.dx > 0 && vector.dy < 0)
    {
        angle = degreeToRadian(360) - angle
    }
    
    return angle
}

/**
 Constructs a vector given its length (module) and angle
 @param length the lenght (module) of the vector
 @param angle the angle of the vector
 @return the output vector
 */
public func polarCGVector(length: Double, angle: Double) -> CGVector
{
    var positiveAngle = angle
    if(positiveAngle < 0)
    {
        positiveAngle = degreeToRadian(360) + positiveAngle
    }
    
    let X = cos(positiveAngle) * length
    let Y = sin(positiveAngle) * length
    
    return CGVector(dx: X, dy: Y)
}

/**
 Returns the input vector rotated by angleRadians
 @param vector the input vector
 @param angleRadians the angle to rotate the vector in radians
 @return the output vector
 */
public func rotateVector (vector: CGVector, angleRadians: CGFloat) -> CGVector
{
    let module = vectorModule(vector: vector)
    let angle = Double(CGFloat(vectorAngle(vector: vector)) + angleRadians)
    return polarCGVector(length: module, angle: angle)
}

/**
 Rotates a point around a pivot by and angle
 @param pointToRotate the point to be rotated
 @param pivot the point that pointToRotate is rotated around
 @param angle the angle (in radians) to rotate the point
 @return the rotated point
 */
public func rotatePoint (pointToRotate: CGPoint, pivot: CGPoint, angle : Double) -> CGPoint
{
    var positiveAngle = angle
    if(positiveAngle < 0)
    {
        positiveAngle = degreeToRadian(360) + positiveAngle
    }
    let distance = distanceModule(pivot, pointToRotate)
    let distX = cos(positiveAngle) * distance
    let distY = sin(positiveAngle) * distance
    
    return CGPoint(x: Double(pivot.x) + distX, y: Double(pivot.y) + distY)
}

/**
 Returns an angle between 0 and 180 representing the smaller distance of rotation given a -360 to 360 input angle.
 @param angle the input angle should be a -360 degrees to 360 degrees angle (in radians).
 @return an angle between 0 and 180 representing the smaller distance of rotation given a -360 to 360 input angle.
 */
public func smallerDegreeDistance(angle: Double) -> Double
{
    var adjAngle = angle
    if (adjAngle > degreeToRadian(180))
    {
        adjAngle = degreeToRadian(360) - adjAngle
    }
    else if (angle < degreeToRadian(-180))
    {
        adjAngle = degreeToRadian(360) + adjAngle
    }
    return adjAngle
}
