//
//  BSAudioStream.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation

class BSAudioStream {
    var outputStream: OutputStream
    
    init(with outputStream: OutputStream) {
        self.outputStream = outputStream
    }
}
