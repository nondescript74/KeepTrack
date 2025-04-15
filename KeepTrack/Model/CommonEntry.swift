//
//  CommonEntry.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonEntry: Codable, Identifiable {
    var id: UUID
    var date: Date
    var units: String
    var amount: Double
    var name: String
    var goalMet: Bool
}
