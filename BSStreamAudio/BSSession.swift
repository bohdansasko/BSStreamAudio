//
//  BSSession.swift
//  BSStreamAudio
//
//  Created by Bogdan Sasko on 5/6/19.
//  Copyright © 2019 Vinso. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol BSSessionDelegate: class {
    func session(session: BSSession, didReceiveAudioStream stream: InputStream)
    func session(session: BSSession, didReceiveData data: Data)
}

class BSSession: NSObject {
    private lazy var session: MCSession = {
        let session = MCSession(peer: peerID)
        session.delegate = self
        return session
    }()
    private var advertiser: MCAdvertiserAssistant!
    private var peerID: MCPeerID
    
    let kStreamName: String = "music"
    
    weak var delegate: BSSessionDelegate?
    
    init(withDisplayName displayName: String) {
        peerID = MCPeerID(displayName: displayName)
        super.init()
    }
    
    func startAdvertising(forServiceName serviceName: String, discoveryInfo: [String: String]) {
        advertiser = MCAdvertiserAssistant(serviceType: serviceName, discoveryInfo: discoveryInfo, session: self.session)
        advertiser.delegate = self
        advertiser.start()
    }
    
    func stopAdvertising() {
        advertiser.stop()
    }
    
    func browserViewController(forServiceType type: String) -> MCBrowserViewController {
        let browser = MCBrowserViewController(serviceType: type, session: session)
        browser.delegate = self
        return browser
    }
    
    func connectedPeers() -> [MCPeerID] {
        return session.connectedPeers
    }
    
    func outputStream(forPeer peer: MCPeerID) throws -> OutputStream {
        return try session.startStream(withName: kStreamName, toPeer: peer)
    }
    
    func sendData(_ data: Data) {
        do {
            try session.send(data, toPeers: connectedPeers(), with: .reliable)
        } catch {
            print(#function, "=>", error.localizedDescription)
        }
    }
}

// - MARK: MCSessionDelegate
extension BSSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting: print("Connecting to", peerID.displayName)
        case .connected: print("Connected to", peerID.displayName)
        case .notConnected: print("Disconnected from", peerID.displayName)
        @unknown default:
            fatalError("caught unhandled state")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(#function)
        delegate?.session(session: self, didReceiveData: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        if streamName == kStreamName {
            print(#function)
            delegate?.session(session: self, didReceiveAudioStream: stream)
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(#function)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(#function)
    }
}

// - MARK: MCAdvertiserAssistantDelegate
extension BSSession: MCAdvertiserAssistantDelegate {
    // do nothing
}

// - MARK: MCAdvertiserAssistantDelegate
extension BSSession: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
}
