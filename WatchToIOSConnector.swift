//
//  WatchToIOSConnector.swift
//  RhythmicsWatch Watch App
//
//  Created by Sam Goldberg on 4/14/24.
//

import Foundation
import WatchConnectivity

class WatchToIOSConnector: NSObject, WCSessionDelegate {
    
    var session: WCSession
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    func sendMacroToiOS() {
        
    }
}
