//
//  CommonGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation
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
                logger.info( "fileURL for existing history \(fileURL)")
                do {
                    let temp = FileManager.default.contents(atPath: fileURL.path) ?? Data()
                    if temp.count == 0 {
                        goals = []
                        logger.info("goalsstore.json file is empty")
                    } else {
                        let tempContents: [CommonGoal] = try JSONDecoder().decode([CommonGoal].self, from: try Data(contentsOf: fileURL))
                        goals = tempContents
                        logger.info(" decoded goals: \(tempContents)")
                    }
                } catch {
                    fatalError( "Couldn't read goals")
                }
            } else {
                FileManager.default.createFile(atPath: docDirUrl.path().appending("goalsstore.json"), contents: nil)
                logger.info( "Created file goalsstore.json")
                goals = []
            }
        } else {
            fatalError( "Failed to resolve document directory")
        }
    }
    
    func addGoal(goal: CommonGoal) {
        goals.append(goal)
        logger.info("added goal: \(goal.name)")
        save()
    }
    
    func removeGoalAtId(uuid: UUID) {
        goals.removeAll { $0.id == uuid }
        logger.info("Removed goal with id \(uuid)")
        save()
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("goalsstore.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        
        do {
            let data = try JSONEncoder().encode(goals)
            try data.write(to: fileURL)
            logger.info( "Saved goalsstore json data to file")
            self.goals = try JSONDecoder().decode([CommonGoal].self, from: data)
            logger.info("reloaded goals from data")
        } catch {
            fatalError( "Couldn't save goals file")
        }
    }
    
    func getTodaysGoals() -> [CommonGoal] {
        let todays = goals.filter({$0.isActive == true }).sorted { $0.name < $1.name }
        return todays
        
        // let todays = goals.filter({$0.isActive == true && $0.dates.contains(where: { Calendar.current.isDateInToday($0) })})
     }
    
    func getTodaysGoalsForName(namez: String) -> [CommonGoal] {
        let todays = getTodaysGoals().filter({$0.dates.contains(where: { Calendar.current.isDateInToday($0) })}).filter({$0.name.lowercased().contains(namez.lowercased())})
        return todays
    }
    
    func getTodaysGoalsInTime(namex: String) -> [CommonGoal] {
        let todaysGoalsActive = getTodaysGoalsForName(namez: namex)
        var todaysGoalsActiveInTime: [CommonGoal] = []
        let currentDateTime = Date()
        let componentsNow = Calendar.current.dateComponents([.hour,.minute], from: currentDateTime)
        let hourNow = componentsNow.hour
        let minuteNow = componentsNow.minute
        
        for agoal in todaysGoalsActive {
            let componentsGoal = Calendar.current.dateComponents([.hour,.minute], from: agoal.dates.sorted(by: <)[0])  // ?? only using earliest goal
            let hourGoal = componentsGoal.hour
            let minuteGoal = componentsGoal.minute
            
            if (hourGoal ?? 0 < hourNow ?? 0) {
                todaysGoalsActiveInTime.append(agoal)
            } else if (hourGoal ?? 0 == hourNow ?? 0) && (minuteGoal ?? 0 <= minuteNow  ?? 0) {
                todaysGoalsActiveInTime.append(agoal)
            }
            // array of timegoals
            // are all of them met, if so return true
        }
        logger.info("getTodaysGoalsActiveInTime is \(todaysGoalsActiveInTime)")
        return todaysGoalsActiveInTime
    }
}
