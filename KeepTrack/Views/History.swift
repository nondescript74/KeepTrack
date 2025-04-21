//
//  History.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct History: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 10)), count: 3)
    
    private func getToday() -> [CommonEntry] {
        let todays = store.history.filter { Calendar.current.isDateInToday($0.date) }
        return  todays
    }
    
    private func getYesterday() -> [CommonEntry] {
        let yesterdays = store.history.filter { Calendar.current.isDateInYesterday($0.date) }
        return  yesterdays
    }
    var body: some View {
        VStack {
            Text("History")
                .font(.headline)

            List {
                Section(header: Text("Today")) {
                    HStack {

                        VStack(alignment: .leading) {
                            if getToday().isEmpty {
                                Text("Nothing taken today")
                                    .foregroundColor(.gray)
                            } else {
                                LazyHGrid(rows: rowLayout) {
                                    ForEach(getToday(), id: \.self.date) { entry in
                                        HStack {
                                            Text(entry.date, style: .time)
                                            Text(entry.name)
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                        CommonDisplay()

                    }
                    .background(Color.green.opacity(0.1))
                    Text("Took " + getToday().count.description)
                        .foregroundStyle(store.history.count >= goals.goals.count ? Color.green : Color.red)
                }
                
                Section(header: Text("Yesterday")) {
                    Text("Total " + getYesterday().count.description)
                }
            }
        }
        .environment(store)
        .environment(goals)
    }
}

#Preview {
    History()
        .environment(CommonStore())
        .environment(CommonGoals())
}

