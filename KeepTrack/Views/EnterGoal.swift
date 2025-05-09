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
    
    @State fileprivate var name: String = types.sorted(by: <)[0]
    @State fileprivate var startDate: Date = Date()
    #if os(iOS)
    @State fileprivate var stateFul: Bool = true
    #endif
    #if os(macOS) || os(iPadOS)
    @State fileprivate var stateFul: Bool = false
    #endif
    
    
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
                
                HStack {
                    DatePicker(
                            "Start Date",
                            selection: $startDate,
                            displayedComponents: [.hourAndMinute]
                        )
                }
                .padding(.horizontal)
                
                Button(action: ({
                    if self.name.isEmpty {
                        return
                    }
                    
                    if goals.goals.contains(where: { $0.name == self.name }) {
                        
                        let remain = goals.goals.filter( { $0.name == self.name } )
                        if remain.count > 1 {
                            fatalError( "Too many goals with same name: \(self.name)" )
                        }
                        var newDates = remain[0].dates
                        newDates.append(startDate)
                        let goal = CommonGoal(id: remain[0].id, name: name, description: getMatchingDesription(), dates: newDates, isActive: true, isCompleted: false, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency() )
                         
                        goals.addGoal(goal: goal)
                        
                    } else {
                        let dateArrayForGoal: [Date] = matchingDateArray(name: self.name, startDate: startDate)

                        let goal = CommonGoal(id: UUID(), name: self.name, description: getMatchingDesription(), dates: dateArrayForGoal, isActive: true, isCompleted: false, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency() )
                        
                        goals.addGoal(goal: goal)
                    }

                    self.name = types.sorted(by: <)[0]
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
                    .font(.headline)
                    .padding()
                ForEach(goals.goals, id: \.id) { goal in
                    Text(goal.name)
                        .foregroundStyle(stateFul ? .green : .orange)
                        .padding(.bottom, 5)
                    #if macos || ipadOS
                        .onHover(perform: { imOver in
                            stateFul = imOver
                        })
                    #endif
                }
            }
            .defaultHoverEffect(.automatic)
            Spacer()
        }
    }
}

#Preview {
    EnterGoal()
        .environment(CommonGoals())
}

