//
//  IntakeType.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import Foundation

struct IntakeType: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var unit: String
    var amount: Double
    var descrip: String
    var frequency: String

    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}
