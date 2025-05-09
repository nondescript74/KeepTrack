//
//  HealthDataTypeValue.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 5/1/25.
//

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A data model used to describe a health data value.
*/

import Foundation

/// A representation of health data to use for `HealthDataTypeTableViewController`.
struct HealthDataTypeValue: Hashable {
    let startDate: Date
    let endDate: Date
    var value: Double
}

