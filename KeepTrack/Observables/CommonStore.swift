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
                if self.zBug { self.logger.info( "CStore: fileURL for existing history \(fileURL)") }
                
                do {
                    let temp = FileManager.default.contents(atPath: fileURL.path)!
                    if temp.count == 0 {
                        self.history = []
                        if self.zBug { self.logger.info("CStore: history is empty") }
                    } else {
                        let tempContents: [CommonEntry] = try JSONDecoder().decode([CommonEntry].self, from: try Data(contentsOf: fileURL))
                        self.history = tempContents.sorted { $0.date > $1.date }
                        if self.zBug { self.logger.info("CStore:  decoded history: \(tempContents)") }
                    }
                } catch {
                    fatalError( "Couldn't read history")
                    // don't fail gracefully, this should never happen
                }
                
                
            } else {
                FileManager.default.createFile(atPath: docDirUrl.path().appending("entrystore.json"), contents: nil)
                if self.zBug { self.logger.info( "CStore: Created file entrystore.json") }
                self.history = []
            }
        } else {
            fatalError( "Failed to resolve document directory")
            // don't fail gracefully, this should never happen
        }
    }
    
    fileprivate func save() {
        let fileURL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entrystore.json").path)
        if self.zBug { self.logger.info( "CStore: fileURL for existing history \(fileURL.lastPathComponent)") }
        
        do {
            let data = try JSONEncoder().encode(self.history)
            try data.write(to: fileURL)
            self.logger.info( "CStore: Saved history to file")
            self.history = try JSONDecoder().decode([CommonEntry].self, from: data).sorted(by: ({$0 .date > $1.date}))
            self.logger.info("CStore: reloaded history from data")
        } catch {
            fatalError( "Couldn't save history file")
            // don't fail gracefully, this should never happen
        }
    }
    
    func addEntry(entry: CommonEntry) {
        self.history.append(entry)
        self.logger.info("CStore: Added entry to CommonStore \(entry.name)")
        self.save()
    }
    
    func removeEntryAtId(uuid: UUID) {
        self.history.removeAll { $0.id == uuid }
        self.logger.info("CStore: Removed entry with id \(uuid)")
        self.save()
        
    }
    
    func getTodaysIntake() -> [CommonEntry] {
        let todays = self.history.filter { Calendar.autoupdatingCurrent.isDateInToday($0.date) }
        self.logger.info( "CStore: Found \(todays.count) entries for today")
        return  todays
    }
}

