import Foundation
import UIKit
import SpriteKit
import PlaygroundSupport

//Variable with all the possible planet colors
public var planetColorList = [SKColor.white]

/* SINGLETON CLASS TO LAUNCH THE SCREENS AS APPROPRIATE*/
public class Launcher
{
    public static let sharedInstance = Launcher() //Static reference to the only instance of Launcher
    var width : Int
    var height : Int
    var view : SKView
    var currentScene : SKScene?

    /**
        Constructs the view with the specified parameters. Note: Did not want to give freedom to alter the width 
        and height outside launcher (always 400x600)
    */
    init() {
        width = 400
        height = 600
        
        view = SKView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        PlaygroundPage.current.liveView = view
        PlaygroundPage.current.needsIndefiniteExecution = true
        
        //Diagnostics
        //view.showsFPS = true
        //view.showsPhysics = true
        //view.showsNodeCount = true
    }
    
    /**
        Instantiate the title screen scene and makes it the presented scene
     
        @param pColorList all possible planet colors
    */
    public func titleScreen(pColorList : [SKColor])
    {
        planetColorList = pColorList
        currentScene = TitleScreen(size: CGSize(width: width, height: height))
        view.presentScene(currentScene!)
    }
    
    /**
     Instantiate the game scene and makes it the presented scene (does a transition too).
     
     @param pColorList all possible planet colors
     */
    public func startGame(pColorList : [SKColor])
    {
        planetColorList = pColorList
        currentScene = Core(size: CGSize(width: width, height: height))
        view.presentScene(currentScene!, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.5))
    }
}
