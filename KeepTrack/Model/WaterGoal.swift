//
//  Goal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/25/25.
//

import Foundation

struct Goal: Codable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var isActive: Bool?
    var isCompleted: Bool?
}
