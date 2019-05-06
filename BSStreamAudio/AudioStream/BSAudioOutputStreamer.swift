//
//  BSAudioOutputStreamer.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation
import MediaPlayer

protocol AudioOutputStreamerProtocol {
    var audioStream: BSAudioStream { get set }
    var assetReader: AVAssetReader? { get set }
    var assetOutput: AVAssetReaderTrackOutput? { get set }
    
    var isStreaming: Bool { get set }
    
    var audioStreamReadMaxLength: UInt32 { get set }
    var audioQueueBufferSize: UInt32 { get set }
    var audioQueueBufferCount: UInt32 { get set }
    
    func start()
    func resume()
    func pause()
    func stop()
}

class BSAudioOutputStreamer: NSObject {
    var audioStream: BSAudioStream
    var assetReader: AVAssetReader?
    var assetOutput: AVAssetReaderTrackOutput?
    
    var audioStreamReadMaxLength: UInt32 = 255
    var audioQueueBufferSize: UInt32 = 512
    var audioQueueBufferCount: UInt32 = 3
    var isStreaming: Bool = false
    
    init(with outputStream: OutputStream) {
        
        audioStream = BSAudioStream(with: outputStream)
//        audioStream.delegate = self
        super.init()
    }
 
}

extension BSAudioOutputStreamer: AudioOutputStreamerProtocol {
    func start() {
        
    }
    func resume() {
        
    }
    func pause() {
        
    }
    func stop() {
        
    }
}
