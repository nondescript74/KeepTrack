//
//  AddIntakeType.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/29/25.
//

import SwiftUI
import OSLog

struct Ingredient: Codable, Hashable {
    let name: String
}

struct AddIntakeType: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AddIntakeType")
    @EnvironmentObject private var intakeTypes: CurrentIntakeTypes
    @State private var iTypeName: String = ""
    @State private var iTypeUnit: String = ""
    @State private var iTypeAmount: Double = 0.0
    @State private var iTypeDescrip: String = "Enter A Description"
    @State private var iTypeFrequency: String = ""
    @State private var iTypeUUID: UUID = UUID()
    @State private var ingredientNames: [String] = []
    @State private var searchText: String = ""
    @State private var hasEditedAmountField = false
    @State private var selectedUnit: units = .none
    @State private var selectedFrequency: frequency = .none
    @FocusState private var descFieldIsFocused: Bool
    
    // Confirmation message and color for feedback to user
    @State private var confirmationMessage: String = ""
    @State private var confirmationColor: Color = .green
    
    var filteredIngredientNames: [String] {
        searchText.isEmpty ? ingredientNames : ingredientNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            Text("Add A New Intake Type")
                .font(.title).bold()
                .foregroundStyle(Color.blue)
                .shadow(color: .blue.opacity(0.18), radius: 4, x: 0, y: 2)
            
            TextField("Name", text: $iTypeName)
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(Color.blue)
            
            Picker("Select Ingredient", selection: $iTypeName) {
                ForEach(filteredIngredientNames, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            .pickerStyle(.automatic)
            
            HStack {
                LabeledContent("Amount") {
                    Spacer()
                    TextField("Enter amount", value: $iTypeAmount, format: .number)
                        .onTapGesture {
                            if !hasEditedAmountField {
                                iTypeAmount = Double.nan
                                hasEditedAmountField = true
                            }
                        }
                        .keyboardType(.decimalPad)
                        .foregroundStyle(Color.blue)
                }
                Text("Unit of Measure")
                Spacer()
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(units.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            }
            
            TextField("Description", text: $iTypeDescrip)
                .focused($descFieldIsFocused)
                .onChange(of: descFieldIsFocused) { oldValue, newValue in
                    if newValue && iTypeDescrip == "Enter A Description" {
                        iTypeDescrip = ""
                    }
                }
                .onChange(of: iTypeDescrip) { oldValue, newValue in
                    if newValue == "Enter A Description" {
                        iTypeDescrip = ""
                    }
                }
            
            HStack {
                Text("Frequency")
                Spacer()
                Picker("Frequency", selection: $selectedFrequency) {
                    ForEach(frequency.allCases, id: \.self) { freq in
                        Text(freq.displayName).tag(freq)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Add button to add a new intake type
            Button(action: ({
                if self.iTypeName.isEmpty || self.selectedUnit == .none || self.iTypeAmount.isZero || self.iTypeDescrip.isEmpty {
                    // Failure: required fields missing
                    logger.info("Empty fields")
                    self.confirmationMessage = "Please fill all required fields before adding."
                    self.confirmationColor = .red
                    return
                } else {
                    let myIntakeType: IntakeType = IntakeType(id: self.iTypeUUID, name: self.iTypeName, unit: self.selectedUnit.rawValue, amount: self.iTypeAmount, descrip: self.iTypeDescrip, frequency: self.selectedFrequency.rawValue)
                    intakeTypes.saveNewIntakeType(intakeType: myIntakeType)
                    
                    // Clear fields after successful addition
                    self.iTypeName = ""
                    self.iTypeUnit = ""
                    self.selectedUnit = .none
                    self.iTypeAmount = 0
                    self.hasEditedAmountField = false
                    self.iTypeDescrip = ""
                    self.iTypeFrequency = ""
                    self.selectedFrequency = .none
                    
                    // Success confirmation message
                    self.confirmationMessage = "Successfully added intake type \(myIntakeType.name)."
                    self.confirmationColor = .green
                }
                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .foregroundStyle(.blue)
            
            // MARK: - Button to remove an intake type by name
            Button(action: {
                // Attempt to find intake type by case-insensitive name
                if let idx = intakeTypes.intakeTypeArray.firstIndex(where: { $0.name.caseInsensitiveCompare(iTypeName) == .orderedSame }) {
                    let removedType = intakeTypes.intakeTypeArray[idx]
                    intakeTypes.intakeTypeArray.remove(at: idx)
                    Task { await intakeTypes.saveIntakeTypes() }
                    logger.info("Removed intake type: \(removedType.name)")
                    
                    // Clear input fields after removal
                    self.iTypeName = ""
                    self.iTypeUnit = ""
                    self.selectedUnit = .none
                    self.iTypeAmount = 0
                    self.hasEditedAmountField = false
                    self.iTypeDescrip = ""
                    self.iTypeFrequency = ""
                    self.selectedFrequency = .none
                    
                    // Success confirmation message
                    self.confirmationMessage = "Successfully removed intake type \(removedType.name)."
                    self.confirmationColor = .green
                } else {
                    // Failure confirmation message
                    logger.warning("Could not find intake type to remove: \(iTypeName)")
                    self.confirmationMessage = "Could not find intake type named \(iTypeName) to remove."
                    self.confirmationColor = .red
                }
            }, label: {
                Label("Remove This Intake Type", systemImage: "trash")
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2))
                            .foregroundColor(.red)
                    )
            })
            .foregroundStyle(.red)
            
            // Confirmation message display below buttons
            if !confirmationMessage.isEmpty {
                Text(confirmationMessage)
                    .foregroundStyle(confirmationColor)
                    .font(.callout.bold())
                    .padding(.top, 6)
            }
            
        }
        .task {
            if let url = Bundle.main.url(forResource: "ingredients_list", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    if let decoded = try? JSONDecoder().decode([Ingredient].self, from: data) {
                        self.ingredientNames = decoded.map { $0.name }
                    } else if let decodedStrings = try? JSONDecoder().decode([String].self, from: data) {
                        self.ingredientNames = decodedStrings
                    }
                    if self.iTypeName.isEmpty || !filteredIngredientNames.contains(self.iTypeName) {
                        if let firstFiltered = filteredIngredientNames.first {
                            self.iTypeName = firstFiltered
                        }
                    }
                } catch {
                    logger.error("Failed to load ingredient names: \(error.localizedDescription)")
                }
            } else {
                logger.error("ingredients_list.json not found in bundle")
            }
        }
    }
}

#Preview {
    AddIntakeType()
        .environmentObject(CurrentIntakeTypes())
}
