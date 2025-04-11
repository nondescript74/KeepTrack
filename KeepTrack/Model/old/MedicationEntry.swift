//
//  MedicationEntry.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/23/25.
//

import Foundation

struct MedicationEntry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var name: String?
    var goalMet: Bool?
}
