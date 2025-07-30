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
    @Environment(CurrentIntakeTypes.self) var cIntakeTypes
    @Environment(\.dismiss) var dismiss
    
    @State fileprivate var name: String = "Water"
    @State fileprivate var startDate: Date = Date()
#if os(iOS)
    @State fileprivate var stateFul: Bool = true
#endif
#if os(macOS) || os(iPadOS)
    @State fileprivate var stateFul: Bool = false
#endif
#if os(visionOS)
    @State fileprivate var stateFul: Bool = false
#endif
    
    
    fileprivate func getMatchingDesription() -> String {
        let myReturn = cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.descrip ?? "no description"
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func getMatchingUnits() -> String {
        let myReturn = cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.unit ?? units.none.rawValue
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func getMatchingAmounts() -> Double {
        return cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.amount ?? 0
    }
    
    fileprivate func getMatchingFrequency() -> frequency.RawValue {
        let myReturn = cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.frequency ?? frequency.none.rawValue
        logger.info("\(myReturn)")
        return myReturn
    }
    
    
    var body: some View {
        ScrollView {
            Text("Enter goal details")
                .font(.headline)
                .fontWeight(.bold)
            
            
            HStack {
                Text("Select intake: ")
                Spacer()
                
                Picker("Select Type", selection: $name) {
                    ForEach(cIntakeTypes.intakeTypeNameArray.sorted(by: {$0 < $1}), id: \.self) {
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
                    displayedComponents: [.date, .hourAndMinute]
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
                    
                    logger.info( "name: \(self.name)" )
                    logger.info( "dateArrayForGoal: \(dateArrayForGoal)" )
                    
                    let goal = CommonGoal(id: UUID(), name: self.name, description: getMatchingDesription(), dates: dateArrayForGoal, isActive: true, isCompleted: false, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency() )
                    
                    goals.addGoal(goal: goal)
                    logger.info("added a new goal")
                }
                
                self.name = cIntakeTypes.intakeTypeArray.sorted(by: {$0.name < $1.name})[0].name
                
                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .padding()
            .foregroundStyle(.blue)
            
            Text("Current goals are :")
                .font(.subheadline)
            
            ForEach(goals.goals, id: \.id) { goal in
                Text(goal.name)
                    .font(.caption)
                    .foregroundStyle(stateFul ? .green : .orange)
            }
        }
        Spacer()
            .navigationTitle(Text("Enter Goal"))
            .environment(goals)
            .environment(cIntakeTypes)
    }
}

#Preview {
    EnterGoal()
        .environment(CommonGoals())
        .environment(CurrentIntakeTypes())
}

