//
//  SavedRoomMetadata.swift
//  floorplan
//
//  Created by teqnodux on 15/01/25.
//

import Foundation

struct SavedRoomMetadata: Identifiable, Codable {
    let id: String
    let name: String
    let timestamp: Date
}
