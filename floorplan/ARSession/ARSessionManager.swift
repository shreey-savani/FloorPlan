//
//  ARSession.swift
//  floorplan
//
//  Created by teqnodux on 29/01/25.
//

import Foundation
import ARKit

class ARSessionManager: NSObject {
    
    static let shared = ARSessionManager()
    
    private let arSession = ARSession()
    
    var currentFrame: ARFrame? {
        return arSession.currentFrame
    }
    
    private override init() {
        super.init()
        // You can set up additional configuration here if needed.
    }
    
    func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        arSession.run(configuration)
        print("AR session started.")
    }
    
    func stopSession() {
        arSession.pause()
        print("AR session stopped.")
    }
    
    // You can add more functions to interact with the AR session
}
