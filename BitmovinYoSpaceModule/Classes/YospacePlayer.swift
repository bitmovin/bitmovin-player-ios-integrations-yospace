//
//  YospacePlayer.swift
//  BitmovinYoSpaceModule
//
//  Created by Cory Zachman on 11/6/18.
//

import UIKit
import Yospace

class YoSpacePlayer: NSObject, YSVideoPlayer  {
    public required init(streamSource source: URL) {
        super.init();
    }
    
    public var currentTime: TimeInterval {
        get {
            return (player?.currentTime ?? 0) * 1000
        }
        set (currentTime){
            
        }
    }
    
    public var duration: TimeInterval {
        get {
            return (player?.duration ?? 0) * 1000
        }
        set (duration){
            
        }
    }
    
    public var rate: Float {
        get {
            return player?.playbackSpeed ?? 0
        }
        set (duration){
            
        }
    }
    
    public weak var player:BitmovinYoSpacePlayer?
    
}
