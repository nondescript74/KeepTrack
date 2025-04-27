//
//  CommonStore.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation
import HealthKit
import OSLog
import SwiftUI

@MainActor
@Observable final class CommonStore {
    
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonStore")
    var history: [CommonEntry]
        
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var healthStore: HKHealthStore
    
    let waterType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
    
    let sampleTypes = Set([HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
                           HKSeriesType.heartbeat(),
                           HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                           HKObjectType.quantityType(forIdentifier: .heartRate)!
    ])
    
    func heartRateDetailsString(quantity: HKQuantity, dateInterval: DateInterval) -> String {
        let BPM = HKUnit(from: "count/min")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return "\(dateFormatter.string(from: dateInterval.start)) \(Int(quantity.doubleValue(for: BPM))) BPM"
    }
    
    init() {
        if let docDirUrl = urls.first {
            let fileURL = docDirUrl.appendingPathComponent("entrystore.json")
            
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                logger.info( "fileURL for existing history \(fileURL)")
                
                do {
                    let temp = FileManager.default.contents(atPath: fileURL.path)!
                    if temp.count == 0 {
                        history = []
                        logger.info("history is empty")
                    } else {
                        let tempContents: [CommonEntry] = try JSONDecoder().decode([CommonEntry].self, from: try Data(contentsOf: fileURL))
                        history = tempContents
                        logger.info(" decoded history: \(tempContents)")
                    }
                } catch {
                    fatalError( "Couldn't read history")
                }
                    
                
            } else {
                FileManager.default.createFile(atPath: docDirUrl.path().appending("entrystore.json"), contents: nil)
                logger.info( "Created file entrystore.json")
                history = []
            }
        } else {
            fatalError( "Failed to resolve document directory")
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("This app requires a device that supports HealthKit")
        }
        
        healthStore = HKHealthStore()
        logger.info( "Initialized HealthStore")
        
        healthStore.requestAuthorization(toShare: [HKObjectType.quantityType(forIdentifier: .heartRate)!], read: Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])) { (success, error) in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
            // Handle authorization errors here.
            if !success {
                self.logger.info( "Request Authorization failed")
                fatalError( "Request Authorization failed")
            }
            self.logger.info( "authorization granted: \(success)")
            
        }
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entrystore.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL)
            logger.info( "Saved history to file")
            self.history = try JSONDecoder().decode([CommonEntry].self, from: data)
            logger.info("reloaded history from data")
        } catch {
            fatalError( "Couldn't save history file")
        }
    }
    
    func addEntry(entry: CommonEntry) {
        history.append(entry)
        logger.info("Added entry \(entry.name)")
        save()
    }
    
    func removeEntryAtId(uuid: UUID) {
        history.removeAll { $0.id == uuid }
        logger.info("Removed entry with id \(uuid)")
        save()
        
    }
    
   func getTodaysIntake() -> [CommonEntry] {
        let todays = history.filter { Calendar.autoupdatingCurrent.isDateInToday($0.date) }
        return  todays
    }
}
