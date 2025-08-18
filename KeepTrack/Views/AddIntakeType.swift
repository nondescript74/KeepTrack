//
//  AddIntakeType.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/29/25.
//

import SwiftUI
import OSLog

struct AddIntakeType: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AddIntakeType")
    
    @Environment(CurrentIntakeTypes.self) private var intakeTypes
    
//    let formatter: NumberFormatter = NumberFormatter()

    @State private var iTypeName: String = ""
    @State private var iTypeUnit: String = ""
    @State private var iTypeAmount: Double = 0.0
    @State private var iTypeDescrip: String = ""
    @State private var iTypeFrequency: String = ""
    @State private var iTypeUUID: UUID = UUID()
    
    var body: some View {
        VStack {
            Text("Add a new intake type")
            TextField("Name", text: $iTypeName)
            TextField("Unit", text: $iTypeUnit)
            TextField("Amount", value: $iTypeAmount, format: .number)
            TextField("Description", text: $iTypeDescrip)
            TextField("Frequency", text: $iTypeFrequency)
            Text(iTypeUUID.uuidString)
            
            Button(action: ({
                if self.iTypeName.isEmpty  || self.iTypeUnit.isEmpty || self.iTypeAmount.isZero || self.iTypeDescrip.isEmpty || self.iTypeFrequency.isEmpty || self.iTypeDescrip.isEmpty || self.iTypeFrequency.isEmpty {
                    
                    logger.info( "Empty fields")
                    return
                } else {
                    let myIntakeType: IntakeType = IntakeType(id: self.iTypeUUID, name: self.iTypeName, unit: self.iTypeUnit, amount: self.iTypeAmount, descrip: self.iTypeDescrip, frequency: self.iTypeFrequency)
                    intakeTypes.saveNewIntakeType(intakeType: myIntakeType)
                    
                    self.iTypeName = ""
                    self.iTypeUnit = ""
                    self.iTypeAmount = 0.0
                    self.iTypeDescrip = ""
                    self.iTypeFrequency = ""
                }
                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .padding()
            .foregroundStyle(.blue)
        }
        .padding(20)
        .environment(intakeTypes)
    }
}

#Preview {
    AddIntakeType()
        .environment(CurrentIntakeTypes())
}
