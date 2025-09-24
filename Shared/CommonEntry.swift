//
//  CommonEntry.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonEntry: Codable, Identifiable, Hashable {
    var id: UUID
    var date: Date
    var units: String
    var amount: Double
    var name: String
    var goalMet: Bool
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name) // Only names!
    }
}

struct CommonEntryTwo: Codable, Identifiable, Hashable {
    var id: UUID
    var intake: IntakeType
    var goalmet: Bool
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(intake)
        hasher.combine(id)
    }
}
