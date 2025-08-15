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
@Observable final class CommonGoals {
    // MARK: - Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonGoals")
    private static let goalsFilename = "goalsstore.json"
    private let fileURL: URL

    var goals: [CommonGoal] = []

    // MARK: - Init
    init() {
        // Find the documents directory and file URL
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let docDirUrl = urls.first else {
            logger.fault("Failed to resolve document directory")
            self.fileURL = URL(fileURLWithPath: "/dev/null") // fallback to avoid crashes
            return
        }
        self.fileURL = docDirUrl.appendingPathComponent(Self.goalsFilename)
        loadGoals()
    }

    // MARK: - Goal CRUD
    func addGoal(goal: CommonGoal) {
        // If goal exists, replace it
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

    // MARK: - Persistence
    private func loadGoals() {
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                if data.isEmpty {
                    self.goals = []
                    self.logger.info("CGoals: goalsstore.json file is empty")
                } else {
                    let loadedGoals = try JSONDecoder().decode([CommonGoal].self, from: data)
                    self.goals = loadedGoals
                    self.logger.info("CGoals: loaded \(self.goals.count) goals")
                }
            } else {
                // Create the file if it doesn't exist
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
                self.logger.info("CGoals: Created file \(Self.goalsFilename)")
                self.goals = []
            }
        } catch {
            self.logger.error("CGoals: Couldn't read goals: \(error.localizedDescription)")
            self.goals = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(goals.sorted(by: { $0.name < $1.name }))
            try data.write(to: fileURL, options: [.atomic])
            logger.info("CGoals: Saved goalsstore json data to file")
        } catch {
            logger.error("CGoals: Couldn't save goals file: \(error.localizedDescription)")
        }
    }

    // MARK: - Filtering
    func getTodaysGoals() -> [CommonGoal] {
        goals.filter { $0.isActive }.sorted(by: { $0.name < $1.name })
    }

    func getTodaysGoalForName(namez: String) -> CommonGoal? {
        getTodaysGoals().first { $0.name.lowercased().contains(namez.lowercased()) }
    }
}

