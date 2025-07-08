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
    
    fileprivate let zBug: Bool = false
    
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonStore")
    var history: [CommonEntry]
        
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        if let docDirUrl = urls.first {
            let fileURL = docDirUrl.appendingPathComponent("entrystore.json")
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if zBug { logger.info( "CStore: fileURL for existing history \(fileURL)") }
                
                do {
                    let temp = FileManager.default.contents(atPath: fileURL.path)!
                    if temp.count == 0 {
                        history = []
                        if zBug { logger.info("CStore: history is empty") }
                    } else {
                        let tempContents: [CommonEntry] = try JSONDecoder().decode([CommonEntry].self, from: try Data(contentsOf: fileURL))
                        history = tempContents.sorted { $0.date > $1.date }
                        if zBug { logger.info("CStore:  decoded history: \(tempContents)") }
                    }
                } catch {
                    fatalError( "Couldn't read history")
                }
                    
                
            } else {
                FileManager.default.createFile(atPath: docDirUrl.path().appending("entrystore.json"), contents: nil)
                if zBug { logger.info( "CStore: Created file entrystore.json") }
                history = []
            }
        } else {
            fatalError( "Failed to resolve document directory")
        }
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entrystore.json").path)
        if zBug { logger.info( "CStore: fileURL for existing history \(fileURL.lastPathComponent)") }
        
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL)
            logger.info( "CStore: Saved history to file")
            self.history = try JSONDecoder().decode([CommonEntry].self, from: data).sorted(by: ({$0 .date > $1.date}))
            logger.info("CStore: reloaded history from data")
        } catch {
            fatalError( "Couldn't save history file")
        }
    }
    
    func addEntry(entry: CommonEntry) {
        history.append(entry)
        logger.info("CStore: Added entry to CommonStore \(entry.name)")
        save()
    }
    
    func removeEntryAtId(uuid: UUID) {
        history.removeAll { $0.id == uuid }
        logger.info("CStore: Removed entry with id \(uuid)")
        save()
        
    }
    
   func getTodaysIntake() -> [CommonEntry] {
        let todays = history.filter { Calendar.autoupdatingCurrent.isDateInToday($0.date) }
        return  todays
    }
}
