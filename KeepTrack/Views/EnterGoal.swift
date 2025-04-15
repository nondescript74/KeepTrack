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
    
    @State private var name: String = ""
    @State private var selectedFrequency: String = "Once daily"
    @State private var description: String = "Enter description"
    @State private var dates: [Date] = [Date().addingTimeInterval(60 * 60 * 2), Date().addingTimeInterval(60 * 60 * 4), Date().addingTimeInterval(60 * 60 * 6), Date().addingTimeInterval(60 * 60 * 8), Date().addingTimeInterval(60 * 60 * 10), Date().addingTimeInterval(60 * 60 * 12)]
    @State private var dosage: Int = 14
    @State private var unit: String = "fluid ounces"
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    
    var body: some View {
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
                Text("Description: ")
                Spacer()
                TextField("Description", text: $description)
                    .disabled(name.isEmpty)
            }
            .padding(.horizontal)
            
            HStack {
                Text("Dosage: ")
                TextField("Dosage", value: $dosage, formatter: NumberFormatter())
                Picker(units.description, selection: $unit) {
                    ForEach(units, id: \.self) {
                        Text($0)
                    }
                }
            }
            .padding(.horizontal)
            
            if selectedFrequency.lowercased().contains("once daily") {
                VStack(alignment: .leading) {
                    DatePicker("Start Time", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                }
                .padding(.horizontal)
            } else if selectedFrequency.lowercased().contains("twice") {
                VStack(alignment: .leading) {
                    DatePicker("Start Time 1", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 2", selection: $dates[1].animation(.default), displayedComponents: .hourAndMinute)
                }
                .padding(.horizontal)
            } else if selectedFrequency.lowercased().contains("three") {
                VStack(alignment: .leading) {
                    DatePicker("Start Time 1", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 2", selection: $dates[1].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 3", selection: $dates[2].animation(.default), displayedComponents: .hourAndMinute)
                }
                .padding(.horizontal)
            } else if selectedFrequency.lowercased().contains("six") {
                VStack(alignment: .leading) {
                    DatePicker("Start Time 1", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 2", selection: $dates[1].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 3", selection: $dates[2].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 4", selection: $dates[3].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 5", selection: $dates[4].animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 6", selection: $dates[5].animation(.default), displayedComponents: .hourAndMinute)
                    
                }
                .padding(.horizontal)
            }
            
            Picker("Select Frequency", selection: $selectedFrequency) {
                ForEach(frequencies, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            Button(action: ({
                if self.name.isEmpty {
                    return
                }
                logger.info("adding a goal")
                logger.info("second start time: \(dates[1])")
                logger.info("third start time: \(dates[2])")
                
                goals.addGoal(goal: CommonGoal(id: UUID(), name: self.name, description: self.description, dates: dates, isActive: true, isCompleted: true, dosage: self.dosage, frequency: self.selectedFrequency))
                
                self.name = ""
                self.description = ""
                self.dates = Array(repeating: Date(), count: 3)
                self.dosage = 0
                self.selectedFrequency = "Once Daily"

                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .disabled(name.isEmpty)
        }
        Spacer()
    }
}

#Preview {
    EnterGoal()
        .environment(CommonGoals())
}

