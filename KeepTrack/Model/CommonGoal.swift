//
//  CommonGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonGoal: Codable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var dates: [Date] = [Date()]
    var isActive: Bool = true
    var isCompleted: Bool = false
    var dosage: Int = 1
    var frequency: String = "daily"
}
