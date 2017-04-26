import Foundation
import SpriteKit

/**
 Title Screen Scene of the game
 */
public class TitleScreen : SKScene
{
    var width : Int?
    var height : Int?
    
    /**
     Initializes the game's title screen
     
     @param size the size of the SKScene
     */
    override public init(size: CGSize) {
        super.init(size: size)
        
        self.width = Int(size.width)
        self.height = Int(size.height)
        
        let tutorialTitle = SKLabelNode()
        tutorialTitle.text = "Space Nomad"
        tutorialTitle.fontColor = SKColor.yellow
        tutorialTitle.position = CGPoint(x: width!/2, y: 7*height!/8)
        self.addChild(tutorialTitle)
        
        let astronaut = SKSpriteNode(imageNamed: "astronaut.png")
        astronaut.size = CGSize(width: Double(width! / 4) , height: 1.1 * Double(width! / 4))
        astronaut.position = CGPoint(x: width!/2, y: 5*height!/8)
        self.addChild(astronaut)
        
        let tutorialTip1 = SKLabelNode()
        tutorialTip1.text = "*Check the how to play on the code.*"
        tutorialTip1.fontColor = SKColor.yellow
        tutorialTip1.fontSize *= CGFloat(7*width!/8) / tutorialTip1.frame.width
        tutorialTip1.position = CGPoint(x: width!/2, y: 3*height!/8)
        self.addChild(tutorialTip1)
        
        let callToAction = SKLabelNode()
        callToAction.text = "TAP TO PLAY"
        callToAction.fontColor = SKColor.yellow
        callToAction.fontSize *= CGFloat(7*width!/8) / callToAction.frame.width
        callToAction.position = CGPoint(x: width!/2, y: Int(callToAction.frame.height) / 2)
        self.addChild(callToAction)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     When the scene is tapped, the game should begin
    */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Launcher.sharedInstance.startGame(pColorList: planetColorList)
    }
}
