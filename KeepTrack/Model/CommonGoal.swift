//
//  CommonGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation

struct CommonGoal: Codable, Identifiable {
    var id: UUID //
    var name: String  //
    var description: String
    var dates: [Date]
    var isActive: Bool  //
    var isCompleted: Bool  //
    var dosage: Double  //
    var units: String  //
    var frequency: String  //
}


/*
 struct WelcomeElement: Codable {
     let units: String
     let isCompleted, isActive: Bool
     let frequency, id, name: String
     let dates: [Double]
     let description: String
     let dosage: Int
 }
 */
