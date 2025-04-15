//
//  CommonStore.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation
import OSLog

@MainActor
@Observable final class CommonStore {
    
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonStore")
    var history: [CommonEntry]
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    init() {
        let fileMgr = FileManager.default
        let urls = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        if let docDirUrl = urls.first {
            let fileURL = docDirUrl.appendingPathComponent("entrystore.json")
            if fileMgr.fileExists(atPath: fileURL.path) {
                logger.info( "fileURL for existing history \(fileURL)")
                
                do {
                    let temp = fileMgr.contents(atPath: fileURL.path)!
                    if temp.count == 0 {
                        history = []
                        logger.info("history is empty")
                    } else {
                        let tempContents: [CommonEntry] = try JSONDecoder().decode([CommonEntry].self, from: try Data(contentsOf: fileURL))
                        history = tempContents
                        logger.info(" decoded history: \(tempContents)")
                    }
                } catch {
                    fatalError( "Couldn't read history")
                }
                    
                
            } else {
                fileMgr.createFile(atPath: docDirUrl.path().appending("entrystore.json"), contents: nil)
                logger.info( "Created file entrystore.json")
                history = []
            }
        } else {
            fatalError( "Failed to resolve document directory")
        }
    }
    
    fileprivate func save() {
        
        let fileURL = URL(fileURLWithPath: urls[0].appendingPathComponent("entrystore.json").path)
        logger.info( "fileURL for existing history \(fileURL.lastPathComponent)")
        
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL)
            logger.info( "Saved history to file")
            self.history = try JSONDecoder().decode([CommonEntry].self, from: data)
            logger.info("reloaded history from data")
        } catch {
            fatalError( "Couldn't save history file")
        }
    }
    
    func addEntry(entry: CommonEntry) {
        history.append(entry)
        logger.info("Added entry \(entry.name)")
        save()
    }
    
    func removeEntryAtId(uuid: UUID) {
        history.removeAll { $0.id == uuid }
        logger.info("Removed entry with id \(uuid)")
        save()
        
    }
    
}
