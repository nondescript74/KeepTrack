//
//  SDEntry.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData

/// SwiftData model for tracking intake entries
/// Syncs via CloudKit when configured
@Model
final class SDEntry {
    // CloudKit doesn't support unique constraints, so we remove @Attribute(.unique)
    var id: UUID = UUID()
    var date: Date = Date()
    var units: String = ""
    var amount: Double = 0.0
    var name: String = ""
    var goalMet: Bool = false
    
    // Relationship to intake type (optional, for linking)
    var intakeType: SDIntakeType?
    
    init(id: UUID = UUID(), date: Date, units: String, amount: Double, name: String, goalMet: Bool) {
        self.id = id
        self.date = date
        self.units = units
        self.amount = amount
        self.name = name
        self.goalMet = goalMet
    }
    
    /// Convert from CommonEntry to SDEntry
    convenience init(from commonEntry: CommonEntry) {
        self.init(
            id: commonEntry.id,
            date: commonEntry.date,
            units: commonEntry.units,
            amount: commonEntry.amount,
            name: commonEntry.name,
            goalMet: commonEntry.goalMet
        )
    }
    
    /// Convert to CommonEntry for backward compatibility
    func toCommonEntry() -> CommonEntry {
        CommonEntry(
            id: id,
            date: date,
            units: units,
            amount: amount,
            name: name,
            goalMet: goalMet
        )
    }
}
