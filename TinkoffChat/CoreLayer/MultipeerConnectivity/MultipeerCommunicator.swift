//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 03/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import MultipeerConnectivity

protocol ICommunicator: class {
    func sendMessage(text: String, to userId: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ()))
    var delegate: ICommunicatorDelegate? { get set }
    var online: Bool { get set }
}

class MultipeerCommunicator: NSObject, ICommunicator {
    
    private let ownPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let serviceType = "tinkoff-chat"
    
    weak var delegate: ICommunicatorDelegate?
    var online: Bool
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: ownPeerId,
                                                      discoveryInfo: ["userName": UIDevice.current.name],
                                                      serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: ownPeerId,
                                                serviceType: serviceType)
        online = true
        
        super.init()
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendMessage(text: String, to userId: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())) {
        guard let index = session.connectedPeers.index(where: {
                  (item) -> Bool in
                  item.displayName == userId }) else { return  }
        
        let message = ["eventType": "TextMessage",
                       "text": text,
                       "messageId": Message.generateMessageId()]
        
        do {
            let json = try! JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            try session.send(json, toPeers: [session.connectedPeers[index]], with: .reliable)
            
            delegate?.didSendMessage(text: text, to: userId)
            
            completionHandler(true, nil)
        }
        catch {
            completionHandler(false, error)
        }
    }
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: ownPeerId, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        return session
    }()
    
}

extension MultipeerCommunicator: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\n\(peerID.displayName) is connected!\n")
        case .connecting:
            print("\n\(peerID.displayName) is connecting...\n")
        case .notConnected:
            print("\n\(peerID.displayName) is not connected!\n")
        }
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: String]
            
            if let text = json["text"] {
                delegate?.didReceiveMessage(text: text, from: peerID.displayName)
            }
        } catch {
            print("\nResponse cannot be parsed!\n")
        }
    }
    
    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        // Not implemented yet...
    }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        // Not implemented yet...
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        // Not implemented yet...
    }
    
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        guard let userName = info?["userName"] else {
            return
        }
        
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        delegate?.didFindUser(id: peerID.displayName, name: userName)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        delegate?.didLoseUser(id: peerID.displayName)
    }
    
}
