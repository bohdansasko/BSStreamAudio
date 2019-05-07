//
//  BSAudioOutputStreamer.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation
import MediaPlayer

class BSAudioOutputStreamer: NSObject {
    private var audioStream: BSAudioStream
    private var assetReader: AVAssetReader?
    private var assetOutput: AVAssetReaderTrackOutput?
    private var streamThread: Thread?
    
    var isStreaming: Bool = false
    
    init(withOutputStream stream: OutputStream) {
        audioStream = BSAudioStream(with: stream)
        super.init()
        
        audioStream.delegate = self
    }
 
    func sendDataChunk() {
        let sampleBuffer = assetOutput?.copyNextSampleBuffer()
        
        if sampleBuffer == nil || CMSampleBufferGetNumSamples(sampleBuffer!) == 0 {
            return
        }
        
        var blockBuffer: UnsafeMutablePointer<CMBlockBuffer?>?
        var audioBufferList = AudioBufferList()
        
        let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer!,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: blockBuffer)
        
        if status != 0 {
            blockBuffer?.deallocate()
            print("Status != 0")
            return
        }
        
        let buffers = UnsafeBufferPointer<AudioBuffer>(start: &audioBufferList.mBuffers, count: Int(audioBufferList.mNumberBuffers))
        
        for audioBuffer in buffers {
            let frame = audioBuffer.mData?.assumingMemoryBound(to: UInt8.self)
            _ = audioStream.writeData(data: frame!, maxLength: Int(audioBuffer.mDataByteSize))
        }
    }
}

extension BSAudioOutputStreamer {
    @objc func start() {
        if Thread.current != Thread.main {
            return self.performSelector(onMainThread: #selector(start), with: nil, waitUntilDone: true)
        }
        streamThread = Thread(target: self, selector: #selector(run), object: nil)
        streamThread?.start()
    }
    
    @objc func run() {
        audioStream.open()
        isStreaming = true
        print("Loop")
        
        while(isStreaming && RunLoop.current.run(mode: .default, before: Date.distantFuture)) {
            // do nothing
        }
        
        print("Done")
    }
    
    func streamAudio(fromURL url: URL) {
        let asset = AVAsset(url: url)
        assetReader = try? AVAssetReader(asset: asset)
        assetOutput = AVAssetReaderTrackOutput(track: asset.tracks[0], outputSettings: nil)
        
        guard let ao = assetOutput,
              let _ = assetReader?.canAdd(ao) else { return }
        
        assetReader?.add(ao)
        assetReader?.startReading()
        print("Reading asset")
    }
    
    func stop() {
        guard let currentThread = streamThread else { return }
        perform(#selector(stopThread), on: currentThread, with: nil, waitUntilDone: true)
    }
    
    @objc func stopThread() {
        isStreaming = false
        audioStream.close()
        print(#function)
    }
}

extension BSAudioOutputStreamer: BSAudioStreamDelegate {
    func audioStream(audioStream: BSAudioStream, didRaiseEvent eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable: sendDataChunk()
        case .endEncountered: print("endEncountered")
        case .errorOccurred: print("errorOccurred")
        default: break
        }
    }
    
    
}
