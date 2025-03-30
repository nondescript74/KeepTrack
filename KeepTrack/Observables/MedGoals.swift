//
//  MedGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/29/25.
//

import Foundation
import OSLog

@Observable final class MedGoals {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Goals")
    var medGoals: [MedicationGoal] = []
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if UserDefaults.standard.string(forKey: "med_goals_set_before") == nil {
            if let docDirUrl = urls.first {
                logger.info( "docDirUrl \(docDirUrl)")
                fileMgr.createFile(atPath: docDirUrl.path().appending("medgoals.json"), contents: nil)
                logger.info( "Created file medgoals.json")
                UserDefaults.standard.set("true", forKey: "med_goals_set_before")
                logger.info("set med_goals_set_before to true")
                medGoals = []
            } else {
                fatalError( "Couldn't find document directory or encode data")
            }
        } else {
            // launched before
            let docDirUrl = urls.first!
                // no older versions
                let fileURL = docDirUrl.appendingPathComponent("medgoals.json")
                logger.info( "fileURL for existing history \(fileURL)")
                do {
                    if fileMgr.fileExists(atPath: fileURL.path) {
                        let temp = fileMgr.contents(atPath: fileURL.path)!
                        if temp.count == 0 {
                            medGoals = []
                            logger.info("medgoals file is empty")
                        } else {
                            let tempContents: [MedicationGoal] = try JSONDecoder().decode([MedicationGoal].self, from: try Data(contentsOf: fileURL))
                            medGoals = tempContents
                            logger.info(" decoded medGoals: \(tempContents)")
                        }
                    } else {
                        logger.error( "Couldn't find medgoals file")
                        medGoals = []
                    }
                } catch {
                    logger.error( "Error reading directory \(error)")
                    fatalError( "Couldn't read history")
                }
        }
    }
    
    func addMedGoal(id: UUID, name: String, dosage: Int, frequency: String, time: Date, goalmet: Bool) {
        medGoals.append(MedicationGoal(id: id, name: name, dosage: dosage, frequency: frequency, time: time, goalMet: goalmet))
        logger.info ("Added new medGoal: \(self.medGoals)")
        save()
    }
    
    func removeMedGoalAtId(uuid: UUID) {
        medGoals.removeAll { $0.id == uuid }
        logger.info("Removed medGoal with id \(uuid)")
        save()
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("medgoals.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        
        do {
            let data = try JSONEncoder().encode(medGoals)
            try data.write(to: fileURL)
            logger.info( "Saved medgoals json data to file")
            self.medGoals = try JSONDecoder().decode([MedicationGoal].self, from: data)
            logger.info("reloaded medGoals from data")
        } catch {
            logger.error( "Error saving medgoals file \(error)")
            fatalError( "Couldn't save medgoals file")
        }
    }
    
}
