//
//  Detailable.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/26/25.
//

import HealthKit

protocol Detailable {
    // The summary string--used as a cell title in the history view controller.
    var summaryString: String { get }
    
    // The overview strings--used as overview section cell titles in the detail view controller.
    var overviewStrings: [String] { get }
    
    // The detail strings--used as detail section cell titles in in the detail view controller.
    func getDetailStrings(_ healthStore: HKHealthStore, with completion: @escaping ([String]) -> Void)
}
