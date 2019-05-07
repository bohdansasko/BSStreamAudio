//
//  BSAudioInputStreamer.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/7/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation
import AudioToolbox

class BSAudioInputStreamer: NSObject {
//    private var audioStream: BSAudioStream
    private var audioFileStream: BSAudioFileStream
//    private var audioQueue: BSAudioQueue
    
    var audioStreamReadMaxLength: UInt32 = 255
    var audioQueueBufferSize: UInt32 = 512
    var audioQueueBufferCount: UInt32 = 3
    
    override init() {
        audioFileStream = BSAudioFileStream()
        
        super.init()
        
        audioFileStream.delegate = self
    }
    
    convenience init(with inputStream: InputStream) {
        self.init()
    }
    
    func start() {
        
    }
    
    func resume() {
        
    }
    
    func pause() {
        
    }
    
    func stop() {
        
    }
}

// MARK - BSAudioFileStreamDelegate

extension BSAudioInputStreamer: BSAudioFileStreamDelegate {
    func audioFileStream(audioFileSystem: BSAudioFileStream, didReceiveError error: OSStatus) {
        print(#function)
    }
    
    func audioFileStreamDidBecomeReady(audioFileStream: BSAudioFileStream) {
        print(#function)
    }
    
    func audioFileStream(audioFileStream: BSAudioFileStream, didReceiveData data: UnsafeRawPointer, length: UInt32, packetDescription: AudioStreamPacketDescription) {
        print(#function)
    }
    
    func audioFileStream(audioFileStream: BSAudioFileStream, didReceiveData data: UnsafeRawPointer, length: UInt32) {
        print(#function)
    }
    
    
}
