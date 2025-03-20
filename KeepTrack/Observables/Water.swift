//
//  Water.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation
import OSLog


@Observable final class Water {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Water")
    var waterHistory: [WaterEntry] = []
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if UserDefaults.standard.string(forKey: "launchedBefore") == nil {
            if let docDirUrl = urls.first {
                logger.info( "docDirUrl \(docDirUrl)")
                let data = try! JSONEncoder().encode(WaterEntry(date: Date(), units: 0))
                logger.info( "Data \(data)")
                fileMgr.createFile(atPath: docDirUrl.path().appending("waterhistory.json"), contents: data)
                logger.info( "Created file with initial data")
            } else {
                fatalError( "Couldn't find document directory or encode data")
            }
            UserDefaults.standard.set("true", forKey: "launchedBefore")
            logger.info("set launchedBefore to true")
        }
    }
    
    private func getWaterHistoryFromFile() -> [WaterEntry] {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("waterhistory.json").path)
        logger.info( "fileURL for existing history \(fileURL)")
        
        do {
            let data = try fileMgr.contentsOfDirectory(atPath: urls[0].appendingPathComponent("waterhistory.json").path)
            logger.info( "Data \(data)")
            let temp: [WaterEntry] = try JSONDecoder().decode([WaterEntry].self, from: try Data(contentsOf: fileURL))
            return temp
        } catch {
            logger.info( "Error reading directory \(error)")
            fatalError( "Couldn't read history file or decode history")
        }
    }
    
    
    fileprivate func save() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("waterhistory.json").path)
        logger.info( "fileURL for existing history \(fileURL)")
        do {
            let data = try JSONEncoder().encode(waterHistory)
            try data.write(to: fileURL)
            logger.info( "Saved history to file")
        } catch {
            logger.info( "Error saving history \(error)")
            fatalError( "Couldn't save history file")
        }
    }
    
    
    func addWater(_ amount: Int) {
        waterHistory.append(WaterEntry(date: Date(), units: amount))
        save()
        logger.info("Added \(amount) units of water")
    }
    
}
