//
//  MedicationGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/29/25.
//

import Foundation

struct MedicationGoal: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var dosage: Int = 1
    var frequency: String
    var time: Date = Date()
    var goalMet: Bool = true
}
