/*:
 # Space Nomad - An Exploration Game

 This is a simple experience where you control your character around the galaxy and fly through planets.
 
 There is no objective, so enjoy your time!
 
 ---
 
 ## HOW TO PLAY
 
 You can move your astronaut in two ways:
 
 - **Drag and release**: If you drag from your astronaut and release far from him, you will make him fly through space (like a slingshot or angry birds).
 - **Tap when orbiting**: If you are orbiting a planet, tap anywhere on screen for you astronaut to fly away on the direction it is currently on.
 
 - Note: Created by *Rodrigo Longhi Guimarães*. This playground is meant to be used in XCode or in iPad Playgrounds in portrait mode.

 */

//#-hidden-code
import SpriteKit
//#-end-hidden-code
/*: 
 List of possible planet colors. You can totally **change that** if you want, I swear I don't mind. 
 */
//#-code-completion(literal, show, color)
let planetColorList = [
    /*#-editable-code*/#colorLiteral(red: 0.9921568627, green: 0.7215686275, blue: 0.1529411765, alpha: 1)/*#-end-editable-code*/,
    /*#-editable-code*/#colorLiteral(red: 0.8941176471, green: 0, blue: 0.3490196078, alpha: 1)/*#-end-editable-code*/,
    /*#-editable-code*/#colorLiteral(red: 0.4745098039, green: 0.06274509804, blue: 0.5294117647, alpha: 1)/*#-end-editable-code*/,
    /*#-editable-code*/#colorLiteral(red: 0.3490196078, green: 0.06274509804, blue: 0.3568627451, alpha: 1)/*#-end-editable-code*/,
    /*#-editable-code*/#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)/*#-end-editable-code*/,
    /*#-editable-code*/#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)/*#-end-editable-code*/,
    /*#-editable-code*/#colorLiteral(red: 0.1882352941, green: 0.09803921569, blue: 0.9176470588, alpha: 1)/*#-end-editable-code*/
]

/*: 
 This is how you start the game:
 */
let gameLauncher = Launcher.sharedInstance
gameLauncher.titleScreen(pColorList: planetColorList)


