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
    
    private var currentPlayer: AVAudioPlayer?
    var isPlaying = false
    
    func play(path: String)
    {
        let url = URL.init(string: path)
        
        do {
            self.currentPlayer =  try AVAudioPlayer(contentsOf: url!)
            self.currentPlayer?.delegate = self
            self.currentPlayer?.play()
            self.isPlaying = true
            
            print(self.currentPlayer?.currentTime)
        } catch  {
            print("Error loading file", error.localizedDescription)
        }
        
    }
    
    func pause()
    {
        isPlaying = false
        self.currentPlayer?.pause()
    }
    
    func stop()
    {
        self.currentPlayer?.stop()
    }
    
}

extension AudioPlayerManager: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("FINISH PLAY")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
}











