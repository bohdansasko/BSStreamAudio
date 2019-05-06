//
//  BSAudioStream.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation

protocol BSAudioStreamDelegate: class {
    func audioStream(audioStream: BSAudioStream, didRaiseEvent eventCode: Stream.Event)
}

class BSAudioStream: NSObject {
    weak var delegate: BSAudioStreamDelegate?
    
    private var stream: Stream?
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    init(with inputStream: InputStream) {
        self.stream = inputStream
        super.init()
    }
    
    init(with outputStream: OutputStream) {
        self.stream = outputStream
        super.init()
    }
    
    deinit {
        close()
    }
    
    func open() {
        stream?.delegate = self
        stream?.schedule(in: .current, forMode: .default)
        stream?.open()
    }
    
    func close() {
        stream?.close()
        stream?.delegate = nil
        stream?.remove(from: .current, forMode: .default)
    }
    
    func read(data: UnsafeMutablePointer<UInt8>, maxLength: Int) -> UInt32 {
        guard let inStream = stream as? InputStream else { return 0 }
        return UInt32(inStream.read(data, maxLength: maxLength))
    }
    
    func writeData(data: UnsafePointer<UInt8>, maxLength: Int) -> UInt32 {
        guard let outStream = stream as? OutputStream else { return 0 }
        return UInt32(outStream.write(data, maxLength: maxLength))
    }
}

extension BSAudioStream: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        delegate?.audioStream(audioStream: self, didRaiseEvent: eventCode)
    }
}
