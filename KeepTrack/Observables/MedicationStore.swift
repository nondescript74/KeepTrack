//
//  MedicationStore.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/23/25.
//

import Foundation
import OSLog

@MainActor
@Observable final class MedicationStore {
    
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MedicationStore")
    var medicationHistory: [MedicationEntry]
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if UserDefaults.standard.string(forKey: "medicationsLaunchedBefore") == nil {
            if let docDirUrl = urls.first {
                logger.info( "docDirUrl \(docDirUrl)")
                fileMgr.createFile(atPath: docDirUrl.path().appending("medicationhistory.json"), contents: nil)
                logger.info( "Created file medicationhistory.json")
                UserDefaults.standard.set("true", forKey: "medicationsLaunchedBefore")
                logger.info("set medicationsLaunchedBefore to true")
                medicationHistory = []
                
            } else {
                fatalError( "Couldn't find document directory")
            }
        } else {
            // launched before
            let docDirUrl = urls.first!
                // no older versions
                let fileURL = docDirUrl.appendingPathComponent("medicationhistory.json")
                logger.info( "fileURL for existing history \(fileURL)")
                do {
                    if fileMgr.fileExists(atPath: fileURL.path) {
                        let temp = fileMgr.contents(atPath: fileURL.path)!
                        if temp.count == 0 {
                            medicationHistory = []
                            logger.info("medication history is empty")
                        } else {
                            let tempContents: [MedicationEntry] = try JSONDecoder().decode([MedicationEntry].self, from: try Data(contentsOf: fileURL))
                            medicationHistory = tempContents
                            logger.info(" decoded medication history: \(tempContents)")
                        }
                    } else {
                        logger.error( "Couldn't find medication history file")
                        fatalError( "Couldn't find medication history file")
                    }
                } catch {
                    logger.error( "Error reading directory \(error)")
                    fatalError( "Couldn't read history")
                }
        }
    }
    
    fileprivate func save() {
        
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("medicationhistory.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        do {
            try FileManager.default.removeItem(at: fileURL)
            logger.info( "Removed existing history file")
        } catch {
            logger.info( "Error removing existing history file \(error)")
        }
        
        do {
            let data = try JSONEncoder().encode(medicationHistory)
            try data.write(to: fileURL)
            logger.info( "Saved history to file")
            self.medicationHistory = try JSONDecoder().decode([MedicationEntry].self, from: data)
            logger.info("reloaded medication history from data")
        } catch {
            logger.info( "Error saving history \(error)")
            fatalError( "Couldn't save history file")
        }
    }
    
    func addMedication() {
        medicationHistory.append(MedicationEntry(id: UUID(), date: Date()))
        logger.info("Added medication")
        save()
    }
    
    func removeMedicationAtId(uuid: UUID) {
        medicationHistory.removeAll { $0.id == uuid }
        logger.info("Removed medication entry with id \(uuid)")
        save()
        
    }
    
}


