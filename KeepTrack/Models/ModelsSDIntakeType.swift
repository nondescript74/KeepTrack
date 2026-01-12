//
//  SDIntakeType.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData

/// SwiftData model for intake types (medications, supplements, etc.)
/// Syncs via CloudKit when configured
@Model
final class SDIntakeType {
    // CloudKit doesn't support unique constraints, so we remove @Attribute(.unique)
    var id: UUID = UUID()
    var name: String = ""
    var unit: String = ""
    var amount: Double = 0.0
    var descrip: String = ""
    var frequency: String = ""
    
    // Relationship to entries
    @Relationship(deleteRule: .nullify, inverse: \SDEntry.intakeType)
    var entries: [SDEntry]?
    
    init(id: UUID = UUID(), name: String, unit: String, amount: Double, descrip: String, frequency: String) {
        self.id = id
        self.name = name
        self.unit = unit
        self.amount = amount
        self.descrip = descrip
        self.frequency = frequency
    }
    
    /// Convert from IntakeType to SDIntakeType
    convenience init(from intakeType: IntakeType) {
        self.init(
            id: intakeType.id,
            name: intakeType.name,
            unit: intakeType.unit,
            amount: intakeType.amount,
            descrip: intakeType.descrip,
            frequency: intakeType.frequency
        )
    }
    
    /// Convert to IntakeType for backward compatibility
    func toIntakeType() -> IntakeType {
        IntakeType(
            id: id,
            name: name,
            unit: unit,
            amount: amount,
            descrip: descrip,
            frequency: frequency
        )
    }
}
