//
//  BSAudioStreamConstants.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation

enum Constants {
    enum AudioStream: UInt32 {
        case readMaxLength = 512
        case queueBufferSize = 2048
        case queueBufferCount = 16
        case queueStartMinimumBuffers = 8
    }
}
