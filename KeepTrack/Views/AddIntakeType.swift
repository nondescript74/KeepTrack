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
    
    var filteredIngredientNames: [String] {
        searchText.isEmpty ? ingredientNames : ingredientNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            Text("Add A New Intake Type")
                .font(.title).bold()
                .foregroundStyle(Color.blue)
                .shadow(color: .blue.opacity(0.18), radius: 4, x: 0, y: 2)
            
            HStack {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                TextField("Name", text: $iTypeName)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(Color.blue)
            }
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
            
            Button(action: ({
                if self.iTypeName.isEmpty || self.selectedUnit == .none || self.iTypeAmount.isZero || self.iTypeDescrip.isEmpty || self.selectedFrequency == .none {
                    
                    logger.info("Empty fields")
                    return
                } else {
                    let myIntakeType: IntakeType = IntakeType(id: self.iTypeUUID, name: self.iTypeName, unit: self.selectedUnit.rawValue, amount: self.iTypeAmount, descrip: self.iTypeDescrip, frequency: self.selectedFrequency.rawValue)
                    intakeTypes.saveNewIntakeType(intakeType: myIntakeType)
                    
                    self.iTypeName = ""
                    self.iTypeUnit = ""
                    self.selectedUnit = .none
                    self.iTypeAmount = Double.nan
                    self.hasEditedAmountField = false
                    self.iTypeDescrip = ""
                    self.iTypeFrequency = ""
                    self.selectedFrequency = .none
                }
                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .padding()
            .foregroundStyle(.blue)
            
            Text("Ingredient")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.bottom, 2)
            Picker("Select Ingredient", selection: $iTypeName) {
                ForEach(filteredIngredientNames, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            .pickerStyle(.wheel)
        }
        .padding(20)
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
