//
//  BSAudioFileStream.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/7/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation
import AudioToolbox

protocol BSAudioFileStreamDelegate: class {
    func audioFileStream(audioFileSystem: BSAudioFileStream, didReceiveError error: OSStatus)
    func audioFileStreamDidBecomeReady(audioFileStream: BSAudioFileStream)
    func audioFileStream(audioFileStream: BSAudioFileStream, didReceiveData data: Data, length: UInt32, packetDescription: AudioStreamPacketDescription)
    func audioFileStream(audioFileStream: BSAudioFileStream, didReceiveData data: Data, length: UInt32)
}

func BSAudioFileStreamPropertyListener(inClientData: UnsafeMutableRawPointer, inAudioFileStreamID: AudioFileStreamID, inProperty: AudioFileStreamPropertyID, ioFlags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
    let audioFileStream = inClientData.assumingMemoryBound(to: BSAudioFileStream.self).pointee
    audioFileStream.didChangeProperty(inProperty, ioFlags: ioFlags)
}

func BSAudioFileStreamPacketsListener(inClientData: UnsafeMutableRawPointer, inNumberBytes: UInt32, inNumberPackets: UInt32, inInputData: UnsafeRawPointer, inPacketDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>) {
    let audioFileStream = inClientData.assumingMemoryBound(to: BSAudioFileStream.self).pointee
    audioFileStream.didReceivePackets(packets: inInputData, packetDescriptions: inPacketDescriptions, numberOfPackets: inNumberPackets, numberOfBytes: inNumberBytes)
}

// MARK: BSAudioFileStream

func umpBridge<T : AnyObject>(obj : T) -> UnsafeMutablePointer<T> {
    return UnsafeMutablePointer<T>(OpaquePointer(bridge(obj: obj)))
    // return unsafeAddressOf(obj) // ***
}

func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
    // return unsafeAddressOf(obj) // ***
}

class BSAudioFileStream: NSObject {
    var basicDescription: UnsafeMutablePointer<AudioStreamBasicDescription?>?
    var totalByteCount: UInt64 = 0
    var packetBufferSize: UInt32 = 0
    var magicCookieData: UnsafeMutableRawPointer?
    var magicCookiesLength: UInt32 = 0
    var discontinious: Bool = false
    
    weak var delegate: BSAudioFileStreamDelegate?
    
    private var audioFileStreamID: AudioFileStreamID?
    
    override init() {
        super.init()
        guard let audioFileStreamID = audioFileStreamID else { return }
        
        let err = AudioFileStreamOpen(bridge(obj: self), BSAudioFileStreamPropertyListener, BSAudioFileStreamPacketsListener, 0, UnsafeMutablePointer(audioFileStreamID))
        if err != 0 { return }
        discontinious = true
    }
    
    deinit {
        magicCookieData?.deallocate()
        guard let audioFileStreamID = audioFileStreamID else { return }
        AudioFileStreamClose(audioFileStreamID)
    }
    
    
    func didChangeProperty(_ inPropertyID: AudioFileStreamPropertyID, ioFlags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
        if inPropertyID != kAudioFileStreamProperty_ReadyToProducePackets {
            return
        }
        
        guard let audioFileStreamID = audioFileStreamID else { return }
        var basicDescriptionSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        var error: OSStatus = AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataFormat, &basicDescriptionSize, &basicDescription)
        if error != 0 {
            self.delegate?.audioFileStream(audioFileSystem: self, didReceiveError: error)
            return
        }
        
        var byteCountSize: UInt32 = 0
        AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_AudioDataByteCount, &byteCountSize, &totalByteCount)
        
        var sizeOfUInt32 = UInt32(MemoryLayout<UInt32>.size)
        error = AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_PacketSizeUpperBound, &sizeOfUInt32, &packetBufferSize)
        
        if (error != 0 || packetBufferSize != 0) {
            AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_MaximumPacketSize, &sizeOfUInt32, &packetBufferSize)
        }
        
        
        var writeable: DarwinBoolean = false
        error = AudioFileStreamGetPropertyInfo(audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &magicCookiesLength, &writeable)
        
        if error != 0 {
            magicCookieData = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: Int(magicCookiesLength))
            AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_MagicCookieData, &magicCookiesLength, &magicCookieData)
        }
        
        delegate?.audioFileStreamDidBecomeReady(audioFileStream: self)
    }
    
    func didReceivePackets(packets: UnsafeRawPointer, packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>, numberOfPackets: UInt32, numberOfBytes: UInt32) {
        
    }
    
    func parseData(data: UnsafeRawPointer, length: UInt32) {
        var err: OSStatus
        guard let audioFileStreamID = audioFileStreamID else { return }
        if discontinious {
            err = AudioFileStreamParseBytes(audioFileStreamID, length, data,
                                            .discontinuity)
            discontinious = false
        } else {
            err = AudioFileStreamParseBytes(audioFileStreamID, length, data, .init(rawValue: 0))
        }
        
        if (err != 0) {
            self.delegate?.audioFileStream(audioFileSystem: self, didReceiveError: err)
        }
    }
}

