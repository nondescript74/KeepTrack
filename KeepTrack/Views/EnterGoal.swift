//
//  EnterGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EnterGoal: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterGoal")
    
    @Environment(CommonGoals.self) var goals
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = types.sorted(by: <)[0]
    @State private var dates: [Date] = [Date().addingTimeInterval(60 * 60 * 2), Date().addingTimeInterval(60 * 60 * 4), Date().addingTimeInterval(60 * 60 * 6), Date().addingTimeInterval(60 * 60 * 8), Date().addingTimeInterval(60 * 60 * 10), Date().addingTimeInterval(60 * 60 * 12)]

    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    fileprivate func getMatchingDesription() -> String {
         return matchingDescriptionDictionary[name] ?? "no description"
    }
    
    fileprivate func getMatchingUnits() -> String {
        return matchingUnitsDictionary[name] ?? "no units"
    }
    
    fileprivate func getMatchingAmounts() -> Double {
        return matchingAmountDictionary[name] ?? 0.0
    }
    
    fileprivate func getMatchingFrequency() -> String {
        return matchingFrequencyDictionary[name] ?? "no frequency"
    }
    
    
    var body: some View {
        
        Section{
            VStack {
                Text("Enter Goal Details").font(.headline)
                
                HStack {
                    Text("Select intake: ")
                    Spacer()
                    Picker("Select intake", selection: $name) {
                        ForEach(types, id: \.self) {
                            Text($0)
                        }
                    }
                }.padding(.horizontal)
                
                HStack {
                    Text(getMatchingDesription())
                        .foregroundStyle(.purple)
                }
                .padding([.trailing, .bottom])
                
                HStack {
                    Text("Dosage: ")
                    Text(getMatchingAmounts().description)
                    Text(getMatchingUnits())
                    Text(getMatchingFrequency())
                }
                .padding(.horizontal)
                .foregroundStyle(.blue)
                
                Button(action: ({
                    if self.name.isEmpty {
                        return
                    }
                    
                    let goal = CommonGoal(id: UUID(), name: name, description: getMatchingDesription(), dates: dates, isActive: true, isCompleted: false, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency() )
                    
                    goals.addGoal(goal: goal)
                    
                    self.name = types.sorted(by: <)[0]
                    self.dates = [Date()]
                    logger.info("added a goal")
                    
                }), label: ({
                    Image(systemName: "plus.arrow.trianglehead.clockwise")
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
                }))
                .padding(.top)
                .disabled(name.isEmpty)
            }
            .padding(.bottom)
        }
        
        Divider()
        
        Section {
            VStack {
                Text("Current goals are :")
                    .padding()
                ForEach(goals.goals, id: \.id) { goal in
                    Text(goal.name)
                        .foregroundStyle(.purple)
                        .padding(.bottom, 5)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    EnterGoal()
        .environment(CommonGoals())
}

