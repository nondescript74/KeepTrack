//
//  HealthKit.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 5/22/25.
//

import Foundation
import UIKit
import HealthKit
import OSLog
import SwiftUI

@Observable final class HealthKitManager {
    
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "HealthKitManager")
    fileprivate let calendar = Calendar.autoupdatingCurrent
    
    let healthStore: HKHealthStore
    var descriptionLabel: String = ""
    
    var waterIntake: Double = 0
    var dailyWaterIntake: [Double] = []
    
    // MARK: - Data Types
    
    static var readDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }
    
    static var shareDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }
    
    private static var allHealthDataTypes: [HKSampleType] {
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.dietaryWater.rawValue
        ]
        
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }
    
    private func createAuthorizationStatusDescription(for types: Set<HKObjectType>) -> String {
        var dictionary = [HKAuthorizationStatus: Int]()
        
        for type in types {
            let status = healthStore.authorizationStatus(for: type)
            
            if let existingValue = dictionary[status] {
                dictionary[status] = existingValue + 1
            } else {
                dictionary[status] = 1
            }
        }
        
        var descriptionArray: [String] = []
        
        if let numberOfAuthorizedTypes = dictionary[.sharingAuthorized] {
            let format = NSLocalizedString("AUTHORIZED", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfAuthorizedTypes])
            
            descriptionArray.append(formattedString)
        }
        if let numberOfDeniedTypes = dictionary[.sharingDenied] {
            let format = NSLocalizedString("DENIED", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfDeniedTypes])
            
            descriptionArray.append(formattedString)
        }
        if let numberOfUndeterminedTypes = dictionary[.notDetermined] {
            let format = NSLocalizedString("UNDETERMINED", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfUndeterminedTypes])
            
            descriptionArray.append(formattedString)
        }
        
        // Format the sentence for grammar if there are multiple clauses.
        if let lastDescription = descriptionArray.last, descriptionArray.count > 1 {
            descriptionArray[descriptionArray.count - 1] = "and \(lastDescription)"
        }
        
        let description = "Sharing is " + descriptionArray.joined(separator: ", ") + "."
        
        return description
    }
    
    init() {
        self.healthStore = HKHealthStore()
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.getRequestStatusForAuthorization(toShare: [HKQuantityType.quantityType(forIdentifier: .dietaryWater)!], read: [HKQuantityType.quantityType(forIdentifier: .dietaryWater)!]) { (authorizationRequestStatus, error) in
                
                var status: String = ""
                
                if let error = error {
                    status = "HealthKit Authorization Error: \(error.localizedDescription)"
                } else {
                    switch authorizationRequestStatus {
                    case .shouldRequest:
                        status = "The application has not yet requested authorization."
                        self.logger.info("\(status)")
                    case .unknown:
                        status = "Authorization request undetermined, error occurred."
                        self.logger.info("\(status)")
                    case .unnecessary:
                        status = "Application has already requested authorization."
                        status += self.createAuthorizationStatusDescription(for: [HKQuantityType.quantityType(forIdentifier: .dietaryWater)!])
                        self.logger.info("\(status)")
                    default:
                        break
                    }
                }
                
                self.logger.info("\(status)")
                
                // Results come back on a background thread. Dispatch UI updates to the main thread.
                DispatchQueue.main.async {
                    self.descriptionLabel = status
                }
            }
        } else {
            fatalError( "HealthKit is not available.")
        }
    }
    
    func addWaterSample(quantity: HKQuantity) async {
        if descriptionLabel == "HealthKit authorization successful." {
            let sample = HKQuantitySample(type: HKObjectType.quantityType(forIdentifier: .dietaryWater)!, quantity: quantity, start: Date(), end: Date())
            do {
                try await healthStore.save(sample)
                self.logger.info("Water sample saved successfully.")
            } catch {
                self.logger.error("Error saving water sample: \(error)")
            }
        } else {
            // cannot save
            self.logger.info("(\(self.descriptionLabel)")
            return
        }
    }
    
    func requestWaterSamples(from startDate: Date, to endDate: Date) async  {
        
        let waterIntakeHKType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        let predicate = HKSamplePredicate.quantitySample(type: waterIntakeHKType)
        let sumOfWaterQuery = HKStatisticsQueryDescriptor(predicate: predicate, options: .cumulativeSum)

        
        do {
            let quantity = try await sumOfWaterQuery.result(for: healthStore)?
                .sumQuantity()?
                .doubleValue(for: .fluidOunceUS()) ?? 0
            let newQuantity = quantity * 0.034
            logger.info( "Water consumed: \(newQuantity)")
            self.waterIntake = newQuantity
            
        } catch {
            fatalError( "HealthKit is not available.")
        }
    }
    
    func requestDailyWaterIntake(from startDate: Date, to endDate: Date) async {
         let periodOfTime = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        
        guard periodOfTime.day != nil else {
            logger.warning("Failed to calculate the number of days between \(startDate) and \(endDate)")
            return
        }
        
        let thisPeriod = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        // query descriptor
        let waterType = HKQuantityType(.dietaryWater)
        let waterThisPeriod = HKSamplePredicate.quantitySample(type: waterType, predicate: thisPeriod)
        let everyDay = DateComponents(day: 1)
        
        let sumOfWaterQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: waterThisPeriod,
            options: [.cumulativeSum],
            anchorDate: endDate,
            intervalComponents: everyDay
        )
        
        do {
            let waterCount = try await sumOfWaterQuery.result(for: healthStore)
                .statistics()
            dailyWaterIntake = waterCount.map(\.description).compactMap(Double.init)
            logger.info("Daily water intake: \(self.dailyWaterIntake)")
             
        } catch {
            fatalError( "HealthKit is not available.")
        }
    }
}
