//
//  CommonGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonGoal: Codable, Identifiable {
    var id: UUID 
    var name: String
    var description: String
    var dates: [Date] = [Date()]
    var isActive: Bool = true
    var isCompleted: Bool = false
    var dosage: Double = 14
    var units: String? = "pills"
    var frequency: String = "daily"
}
