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
    @State private var iTypeDescrip: String = ""
    @State private var iTypeFrequency: String = ""
    @State private var iTypeUUID: UUID = UUID()
    @State private var ingredientNames: [String] = []
    @State private var searchText: String = ""
    
    @State private var selectedUnit: units = .none
    @State private var selectedFrequency: frequency = .none
    
    var filteredIngredientNames: [String] {
        searchText.isEmpty ? ingredientNames : ingredientNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            Text("Add a new intake type")
            
            TextField("Name", text: $iTypeName)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 4)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 4)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredIngredientNames, id: \.self) { name in
                        HStack {
                            Text(name)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                            Spacer()
                        }
                        .background(iTypeName == name ? Color.accentColor.opacity(0.15) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { self.iTypeName = name; self.searchText = "" }
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2))
                )
            }
            .frame(maxHeight: 200)
            
            Picker("Unit", selection: $selectedUnit) {
                ForEach(units.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.menu)
            
            TextField("Amount", value: $iTypeAmount, format: .number)
            TextField("Description", text: $iTypeDescrip)
            
            Picker("Frequency", selection: $selectedFrequency) {
                ForEach(frequency.allCases, id: \.self) { freq in
                    Text(freq.displayName).tag(freq)
                }
            }
            .pickerStyle(.menu)
            
//            Text(iTypeUUID.uuidString)
            
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
                    self.iTypeAmount = 0.0
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

