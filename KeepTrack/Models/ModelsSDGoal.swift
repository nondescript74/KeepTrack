//
//  SDGoal.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData

/// SwiftData model for goals
/// Syncs via CloudKit when configured
@Model
final class SDGoal {
    // CloudKit doesn't support unique constraints, so we remove @Attribute(.unique)
    var id: UUID = UUID()
    var name: String = ""
    var goalDescription: String = ""
    var dates: [Date] = []
    var isActive: Bool = true
    var isCompleted: Bool = false
    var dosage: Double = 0.0
    var units: String = ""
    var frequency: String = ""
    
    init(id: UUID = UUID(), name: String, goalDescription: String, dates: [Date], 
         isActive: Bool, isCompleted: Bool, dosage: Double, units: String, frequency: String) {
        self.id = id
        self.name = name
        self.goalDescription = goalDescription
        self.dates = dates
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.dosage = dosage
        self.units = units
        self.frequency = frequency
    }
    
    /// Convert from CommonGoal to SDGoal
    convenience init(from commonGoal: CommonGoal) {
        self.init(
            id: commonGoal.id,
            name: commonGoal.name,
            goalDescription: commonGoal.description,
            dates: commonGoal.dates,
            isActive: commonGoal.isActive,
            isCompleted: commonGoal.isCompleted,
            dosage: commonGoal.dosage,
            units: commonGoal.units,
            frequency: commonGoal.frequency
        )
    }
    
    /// Convert to CommonGoal for backward compatibility
    func toCommonGoal() -> CommonGoal {
        CommonGoal(
            id: id,
            name: name,
            description: goalDescription,
            dates: dates,
            isActive: isActive,
            isCompleted: isCompleted,
            dosage: dosage,
            units: units,
            frequency: frequency
        )
    }
}
