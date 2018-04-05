//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 03/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import MultipeerConnectivity

class MultipeerCommunicator: NSObject, Communicator {
    private let ownPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let serviceType = "tinkoff-chat"
    
    weak var delegate: CommunicatorDelegate?
    var online = false
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: ownPeerId, discoveryInfo: ["userName": "Oleg"], serviceType: serviceType)
        
        serviceBrowser = MCNearbyServiceBrowser(peer: ownPeerId, serviceType: serviceType)

        super.init()
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        online = true
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        online = false
        
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?) {
        if let index = session.connectedPeers.index(where: { (item) -> Bool in item.displayName == userID }) {
            do {
                var message = [String: String]()
                message["eventType"] = "TextMessage"
                message["text"] = string
                message["messageId"] = generateMessageId()
                
                let json = try! JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
                
                try self.session.send(json, toPeers: [session.connectedPeers[index]], with: .reliable)
                completionHandler?(true, nil)
            }
            catch let error {
                completionHandler?(false, error)
            }
        }
    }
    
    private func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)!.base64EncodedString()
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
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: String]
            
            if let text = json["text"] {
                delegate?.didReceiveMessage(text: text, fromUser: peerID.displayName, toUser: ownPeerId.displayName)
            }
        } catch {
            print("\nResponse cannot be parsed!\n")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not implemented yet...
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not implemented yet...
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not implemented yet...
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if let info = info {
            delegate?.didFoundUser(userID: peerID.displayName, userName: info["userName"])
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
    }
}
