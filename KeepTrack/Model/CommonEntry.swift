//
//  CommonEntry.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var units: String = "fluid ounces"
    var amount: Double = 14.0
    var name: String = "Water"
    var goalMet: Bool = false 
}
