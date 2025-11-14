//
//  IntakeType.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import Foundation

struct IntakeType: Codable, Identifiable, Hashable, CustomStringConvertible {
    var id: UUID
    var name: String
    var unit: String
    var amount: Double
    var descrip: String
    var frequency: frequency.RawValue
    
    var description: String {
        "IntakeType(id: \(id), name: \"\(name)\", unit: \"\(unit)\", amount: \(amount), descrip: \"\(descrip)\", frequency: \(frequency))"
    }
}

