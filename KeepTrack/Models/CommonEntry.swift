//
//  CommonEntry.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

public struct CommonEntry: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var date: Date
    public var units: String
    public var amount: Double
    public var name: String
    public var goalMet: Bool
    
    public init(id: UUID, date: Date, units: String, amount: Double, name: String, goalMet: Bool) {
        self.id = id
        self.date = date
        self.units = units
        self.amount = amount
        self.name = name
        self.goalMet = goalMet
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name) // Only names!
    }
}

//struct CommonEntryTwo: Codable, Identifiable, Hashable {
//    var id: UUID
//    var intake: IntakeType
//    var goalmet: Bool
//    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(intake)
//        hasher.combine(id)
//    }
//}
