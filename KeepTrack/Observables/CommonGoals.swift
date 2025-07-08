//
//  CommonGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
@Observable final class CommonGoals: ObservableObject {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonGoals")
    var goals: [CommonGoal] = []
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        if let docDirUrl = urls.first {
            let fileURL = docDirUrl.appendingPathComponent("goalsstore.json")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                logger.info( "CGoals: fileURL for existing history \(fileURL)")
                do {
                    let temp = FileManager.default.contents(atPath: fileURL.path) ?? Data()
                    if temp.count == 0 {
                        goals = []
                        logger.info("CGoals: goalsstore.json file is empty")
                    } else {
                        let tempContents: [CommonGoal] = try JSONDecoder().decode([CommonGoal].self, from: try Data(contentsOf: fileURL))
                        goals = tempContents.filter { !$0.isCompleted == true }
                        logger.info("CGoals:  \(self.goals)")
                    }
                } catch {
                    fatalError( "Couldn't read goals")
                }
            } else {
                FileManager.default.createFile(atPath: docDirUrl.path().appending("goalsstore.json"), contents: nil)
                logger.info( "CGoals: Created file goalsstore.json")
                goals = []
            }
        } else {
            fatalError( "Failed to resolve document directory")
        }
    }
    
    func addGoal(goal: CommonGoal) {
        // if goal exists, replace it
        goals.removeAll { $0.id == goal.id }
        if goal.isActive {
            goals.append(goal)
            logger.info("CGoals: added or replaced goal: \(goal.name)")
        }
        save()
    }
    
    func removeGoalAtId(uuid: UUID) {
        goals.removeAll { $0.id == uuid }
        logger.info("CGoals: Removed goal with id \(uuid)")
        save()
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("goalsstore.json").path)
        logger.info( "CGoals: fileURL for existing history \(fileURL.lastPathComponent)")
        
        do {
            let data = try JSONEncoder().encode(goals.sorted(by: ({$0.name < $1.name})))
            try data.write(to: fileURL)
            logger.info( "CGoals: Saved goalsstore json data to file")
            self.goals = try JSONDecoder().decode([CommonGoal].self, from: data)
            logger.info("CGoals: reloaded goals from data")
        } catch {
            fatalError( "Couldn't save goals file")
        }
    }
    
    func getTodaysGoals() -> [CommonGoal] {
        let todays = goals.filter({$0.isActive == true }).sorted(by: ({$0.name < $1.name}))
        return todays
        
     }
    
    func getTodaysGoalForName(namez: String) -> CommonGoal? {
        let todays = getTodaysGoals().filter({$0.name.lowercased().contains(namez.lowercased())}).first
        return todays  // could be nil
    }
}
