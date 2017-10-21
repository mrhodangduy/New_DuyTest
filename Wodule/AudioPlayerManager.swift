//
//  AudioPlayerManager.swift
//  Wodule
//
//  Created by QTS Coder on 10/16/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import AVFoundation


class AudioPlayerManager: NSObject {
    
    static let shared = AudioPlayerManager()
    
    
    override init() {
        super.init()
    }
    
    var currentPlayer: AVAudioPlayer?
    var isPlaying = false
    
    func play(path: String)
    {
        let url = URL(string: path)
        
        DispatchQueue.global(qos: .background).async { 
            do
            {
                let data = try Data(contentsOf: url!)
                do {
                    self.currentPlayer = try AVAudioPlayer(data: data)
                    DispatchQueue.main.async(execute: { 
                        self.currentPlayer?.play()
                        self.currentPlayer?.delegate = self
                        self.isPlaying = true
                        print("TOTAL TIME:",self.currentPlayer?.duration)
                        print("Playing")
                    })
                }
                catch
                {
                    print("cannot play")
                }
            }
            catch
            {
                print("Cannot get data")
            }
        }
        
        
    }
    
    func pause()
    {
        isPlaying = false
        self.currentPlayer?.pause()
        print("Pause")
    }
    func resume()
    {
        isPlaying = true
        self.currentPlayer?.play()
        print("Resume")
        print(self.currentPlayer?.currentTime)

    }
    
    func stop()
    {
        self.currentPlayer?.stop()
        print("Stop")

    }
    
}

extension AudioPlayerManager: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("FINISH PLAY")
        self.stop()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
}











