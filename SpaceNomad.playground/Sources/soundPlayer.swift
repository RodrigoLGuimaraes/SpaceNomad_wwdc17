import Foundation
import AVFoundation

/**
 SOUND PLAYER CLASS
 */
public class SoundPlayer
{
    var audioPlayer = AVAudioPlayer()
    var isFirst : Bool
    
    /**
     Initializes the sound Player
    */
    public init() {
        isFirst = true
    }
    
    /**
     Really plays the sound. Only done after some checks.
     
     @param index index of the sound to be played
    */
    private func reallyPlay(_ index : Int)
    {
        let alertSound = URL(fileReferenceLiteralResourceName: "pitch\(index % 12).m4a")
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        audioPlayer = try! AVAudioPlayer(contentsOf: alertSound)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    /**
     Play a new sound with pitch varying according to the index (0 - 11)
     
     @param index 0 - 11 index to represent the pitch
    */
    public func play(index : Int)
    {
        if(isFirst)
        {
            reallyPlay(index)
        }
        else
        {
            if(!audioPlayer.isPlaying)
            {
                reallyPlay(index)
            }
        }
    }
}
