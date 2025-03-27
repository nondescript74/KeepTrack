//
//  Goals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/25/25.
//

import Foundation
import OSLog

@MainActor
@Observable final class Goals {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Goals")
    var goals: [Goal]
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if UserDefaults.standard.string(forKey: "goals_set_before") == nil {
            if let docDirUrl = urls.first {
                logger.info( "docDirUrl \(docDirUrl)")
                fileMgr.createFile(atPath: docDirUrl.path().appending("goals.json"), contents: nil)
                logger.info( "Created file goals.json")
                UserDefaults.standard.set("true", forKey: "goals_set_before")
                logger.info("set goals_set_before to true")
                goals = []
            } else {
                fatalError( "Couldn't find document directory or encode data")
            }
        } else {
            // launched before
            let docDirUrl = urls.first!
                // no older versions
                let fileURL = docDirUrl.appendingPathComponent("goals.json")
                logger.info( "fileURL for existing history \(fileURL)")
                do {
                    if fileMgr.fileExists(atPath: fileURL.path) {
                        let temp = fileMgr.contents(atPath: fileURL.path)!
                        if temp.count == 0 {
                            goals = [Goal]()
                            logger.info("goals file is empty")
                        } else {
                            let tempContents: [Goal] = try JSONDecoder().decode([Goal].self, from: try Data(contentsOf: fileURL))
                            goals = tempContents
                            logger.info(" decoded goals: \(tempContents)")
                        }
                    } else {
                        logger.error( "Couldn't find goals file")
                        fatalError( "Couldn't find goals file")
                    }
                } catch {
                    logger.error( "Error reading directory \(error)")
                    fatalError( "Couldn't read history")
                }
        }
    }
    
    func addGoal(id: UUID, name: String, description: String, startDate: Date, endDate: Date) {
        goals.append(Goal(id: id, name: name, description: description, startDate: startDate, endDate: endDate))
        logger.info ("Added new goal: \(self.goals)")
        save()
    }
    
    func removeGoalAtId(uuid: UUID) {
        goals.removeAll { $0.id == uuid }
        logger.info("Removed goal with id \(uuid)")
        save()
        
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("goals.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        do {
            try FileManager.default.removeItem(at: fileURL)
            logger.info( "Removed existing goals file")
        } catch {
            logger.error( "Error removing existing goals file \(error)")
        }
        
        do {
            let data = try JSONEncoder().encode(goals)
            try data.write(to: fileURL)
            logger.info( "Saved goals json data to file")
            self.goals = try JSONDecoder().decode([Goal].self, from: data)
            logger.info("reloaded goals from data")
        } catch {
            logger.error( "Error saving goals file \(error)")
            fatalError( "Couldn't save goals file")
        }
    }
    
}
