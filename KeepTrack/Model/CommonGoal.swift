//
//  CommonGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonGoal: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var dates: [Date]
    var isActive: Bool
    var isCompleted: Bool
    var dosage: Double
    var units: String
    var frequency: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isActive)
        hasher.combine(id)
    }
}

