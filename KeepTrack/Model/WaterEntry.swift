//
//  WaterEntry.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation

struct WaterEntry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var units: Int
    var goalMet: Bool?
}
