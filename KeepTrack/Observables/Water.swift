//
//  Water.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation
import OSLog

@MainActor
@Observable final class Water {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Water")
    var waterHistory: [WaterEntry]
    
    let fileMgr = FileManager.default
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if UserDefaults.standard.string(forKey: "launchedBefore") == nil {
            if let docDirUrl = urls.first {
                logger.info( "docDirUrl \(docDirUrl)")
                let waterEntryInitial = WaterEntry(id: UUID(), date: Date(), units: 0)
                let data = try! JSONEncoder().encode(waterEntryInitial)
                logger.info( "Data \(data)")
                fileMgr.createFile(atPath: docDirUrl.path().appending("waterhistory.json"), contents: data)
                logger.info( "Created file with initial data")
                UserDefaults.standard.set("true", forKey: "launchedBefore")
                logger.info("set launchedBefore to true")
                waterHistory = [waterEntryInitial]
                
            } else {
                fatalError( "Couldn't find document directory or encode data")
            }
        } else {
            // launched before
            let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("waterhistory.json").path)
            logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
            do {
                let data = try fileMgr.contentsOfDirectory(atPath: urls[0].path())
                logger.info( "Data \(data)")
                let temp: [WaterEntry] = try JSONDecoder().decode([WaterEntry].self, from: try Data(contentsOf: fileURL))
                waterHistory = temp
                logger.info(" decoded history: \(temp)")
            } catch {
                logger.info( "Error reading directory \(error)")
                fatalError( "Couldn't read history file or decode history")
            }
        }
    }
    
    fileprivate func save() {
        
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("waterhistory.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        do {
            try fileMgr.removeItem(at: fileURL)
            logger.info( "Removed existing history file")
        } catch {
            logger.info( "Error removing existing history file \(error)")
        }
        
        do {
            let data = try JSONEncoder().encode(waterHistory)
            try data.write(to: fileURL)
            logger.info( "Saved history to file")
            self.waterHistory = try JSONDecoder().decode([WaterEntry].self, from: data)
            logger.info("reloaded water history from data")
        } catch {
            logger.info( "Error saving history \(error)")
            fatalError( "Couldn't save history file")
        }
    }
    
    func addWater(_ amount: Int) {
        waterHistory.append(WaterEntry(id: UUID(), date: Date(), units: amount))
        logger.info("Added \(amount) units of water")
        save()
    }
    
    func removeWaterAtId(uuid: UUID) {
        waterHistory.removeAll { $0.id == uuid }
        logger.info("Removed water entry with id \(uuid)")
        save()
        
    }
}
