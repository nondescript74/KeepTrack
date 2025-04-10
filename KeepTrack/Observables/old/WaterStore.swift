//
//  Water.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation
import OSLog
import HealthKit

@MainActor
@Observable final class Water {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Water")
    var waterHistory: [WaterEntry]
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if UserDefaults.standard.string(forKey: "launchedBefore") == nil {
            if let docDirUrl = urls.first {
                logger.info( "docDirUrl \(docDirUrl)")
                fileMgr.createFile(atPath: docDirUrl.path().appending("waterhistory.json"), contents: nil)
                logger.info( "Created file waterhistory.json")
                UserDefaults.standard.set("true", forKey: "launchedBefore")
                logger.info("set launchedBefore to true")
                waterHistory = []
                
            } else {
                fatalError( "Couldn't find document directory or encode data")
            }
        } else {
            // launched before
            let fileMgr = FileManager.default
            let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
                // no older versions
            if let docDirUrl = urls.first {
                let fileURL = docDirUrl.appendingPathComponent("waterhistory.json")
                    logger.info( "fileURL for existing water history \(fileURL)")
                    do {
                        if fileMgr.fileExists(atPath: fileURL.path) {
                            let temp = fileMgr.contents(atPath: fileURL.path)!
                            if temp.count == 0 {
                                waterHistory = []
                                logger.info("water history is empty")
                            } else {
                                let tempContents: [WaterEntry] = try JSONDecoder().decode([WaterEntry].self, from: try Data(contentsOf: fileURL))
                                waterHistory = tempContents
                                logger.info(" decoded water history: \(tempContents)")
                            }
                        } else {
                            logger.error( "No water history file found")
                            waterHistory = []
                        }
                    } catch {
                        logger.info( "Error reading directory \(error)")
                        fatalError( "Couldn't read history")
                    }
            } else {
                logger.error( "Couldn't find document directory")
                fatalError("Couldn't find document directory")
            }

        }
    }
    
//    fileprivate func createHKEntry(date: Date, amount: Double) -> HKQuantitySample {
//        let quantityType = HKQuantityType(.dietaryWater)
//        let quantity = HKQuantity(unit: .ounce(), doubleValue: amount * 14)
//        let startDate = Calendar.current.startOfDay(for: date)
//        return HKQuantitySample(type: quantityType, quantity: quantity, start: startDate, end: startDate.addingTimeInterval(10))
//    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("waterhistory.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        do {
            try FileManager.default.removeItem(at: fileURL)
            logger.info( "Removed existing history file")
        } catch {
            logger.info( "Error removing existing history file \(error)")
        }
        
        do {
            let data = try JSONEncoder().encode(waterHistory)
            try data.write(to: fileURL)
            logger.info( "Saved water history to file")
            self.waterHistory = try JSONDecoder().decode([WaterEntry].self, from: data)
            logger.info("reloaded water history from data")
        } catch {
            logger.info( "Error saving water history \(error)")
            fatalError( "Couldn't save water history file")
        }
        
//        do {
//            if HKHealthStore.isHealthDataAvailable() {
//                try healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
//                logger.info("Authorized health data")
//            }
//        } catch {
//            logger.error( "Error requesting health data authorization \(error)")
//            fatalError( "Couldn't request health data authorization")
//        }
    }
    
    func addLiquid(_ amount: Double, goalmet: Bool, name: String) {
        waterHistory.append(WaterEntry(id: UUID(), date: Date(), units: Int(amount), goalMet: goalmet, amount: amount, name: name))
        logger.info("Added \(amount) of liquid, goalmet is \(goalmet), name is \(name)")
        save()
    }
    
    func addWater(_ amount: Int, goalmet: Bool) {
        addLiquid(Double(amount), goalmet: goalmet, name: "Water")
    }
    
    func addWater(_ amount: Int) {
        addLiquid(Double(amount), goalmet: false, name: "Water")
    }
    
    func removeWaterAtId(uuid: UUID) {
        waterHistory.removeAll { $0.id == uuid }
        logger.info("Removed water entry with id \(uuid)")
        save()
        
    }
    
    func showTodaysWater() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todaysEntries = waterHistory.filter { calendar.startOfDay(for: $0.date) == today }
        return todaysEntries.reduce(0) { $0 + $1.units }
    }
}
