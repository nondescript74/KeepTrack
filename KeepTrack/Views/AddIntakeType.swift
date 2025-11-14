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
    @State private var showingIngredientPicker: Bool = false
    @FocusState private var descFieldIsFocused: Bool
    @FocusState private var amountFieldIsFocused: Bool
    @FocusState private var nameFieldIsFocused: Bool
    
    // Confirmation message and color for feedback to user
    @State private var confirmationMessage: String = ""
    @State private var confirmationColor: Color = .green
    
    var filteredIngredientNames: [String] {
        searchText.isEmpty ? ingredientNames : ingredientNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Add A New Intake Type")
                    .font(.title).bold()
                    .foregroundStyle(Color.blue)
                    .shadow(color: .blue.opacity(0.18), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 8)
                
                // MARK: - Name/Ingredient Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredient Name")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Name", text: $iTypeName)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(Color.blue)
                        .focused($nameFieldIsFocused)
                        .onChange(of: iTypeName) { oldValue, newValue in
                            logger.debug("Name field changed: '\(oldValue)' -> '\(newValue)'")
                        }
                        .onChange(of: nameFieldIsFocused) { oldValue, newValue in
                            logger.debug("Name field focus changed: \(oldValue) -> \(newValue)")
                        }
                    
                    // Custom ingredient picker using sheet instead of Picker
                    Button {
                        logger.debug("Ingredient picker button tapped")
                        showingIngredientPicker = true
                    } label: {
                        HStack {
                            Text(iTypeName.isEmpty ? "Select Ingredient" : iTypeName)
                                .foregroundStyle(iTypeName.isEmpty ? .secondary : .primary)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor.opacity(0.6), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                // MARK: - Amount Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Amount")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 16) {
                        TextField("Enter amount", value: $iTypeAmount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .focused($amountFieldIsFocused)
                            .onTapGesture {
                                logger.debug("Amount field tapped, hasEditedAmountField: \(hasEditedAmountField)")
                                if !hasEditedAmountField {
                                    iTypeAmount = 0
                                    hasEditedAmountField = true
                                }
                            }
                            .keyboardType(.numbersAndPunctuation)
                            .foregroundStyle(Color.blue)
                            .onChange(of: iTypeAmount) { oldValue, newValue in
                                logger.debug("Amount changed: \(oldValue) -> \(newValue)")
                            }
                            .onChange(of: amountFieldIsFocused) { oldValue, newValue in
                                logger.debug("Amount field focus changed: \(oldValue) -> \(newValue)")
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // MARK: - Unit Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Unit of Measure")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(units.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedUnit) { oldValue, newValue in
                        logger.debug("Unit changed: \(oldValue.rawValue) -> \(newValue.rawValue)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                // MARK: - Description Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description", text: $iTypeDescrip)
                        .textFieldStyle(.roundedBorder)
                        .focused($descFieldIsFocused)
                        .onChange(of: descFieldIsFocused) { oldValue, newValue in
                            logger.debug("Description field focus changed: \(oldValue) -> \(newValue)")
                            if newValue && iTypeDescrip == "Enter A Description" {
                                iTypeDescrip = ""
                            }
                        }
                        .onChange(of: iTypeDescrip) { oldValue, newValue in
                            logger.debug("Description changed: '\(oldValue)' -> '\(newValue)'")
                            if newValue == "Enter A Description" {
                                iTypeDescrip = ""
                            }
                        }
                }
                
                // MARK: - Frequency Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(frequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedFrequency) { oldValue, newValue in
                        logger.debug("Frequency changed: \(oldValue.rawValue) -> \(newValue.rawValue)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                    .padding(.top, 8)
                
                // MARK: - Action Buttons
                VStack(spacing: 16) {
                    // Add button to add a new intake type
                    Button(action: ({
                        logger.debug("Add button tapped")
                        logger.debug("Current values - Name: '\(iTypeName)', Unit: \(selectedUnit.rawValue), Amount: \(iTypeAmount), Description: '\(iTypeDescrip)', Frequency: \(selectedFrequency.rawValue)")
                        
                        if self.iTypeName.isEmpty || self.selectedUnit == .none || self.iTypeAmount.isZero || self.iTypeDescrip.isEmpty {
                            // Failure: required fields missing
                            logger.info("Validation failed - Empty fields detected")
                            logger.debug("Validation details - isEmpty: \(iTypeName.isEmpty), unit==.none: \(selectedUnit == .none), amount.isZero: \(iTypeAmount.isZero), descrip.isEmpty: \(iTypeDescrip.isEmpty)")
                            self.confirmationMessage = "Please fill all required fields before adding."
                            self.confirmationColor = .red
                            return
                        } else {
                            let myIntakeType: IntakeType = IntakeType(id: self.iTypeUUID, name: self.iTypeName, unit: self.selectedUnit.rawValue, amount: self.iTypeAmount, descrip: self.iTypeDescrip, frequency: self.selectedFrequency.rawValue)
                            logger.debug("Creating new intake type: \(myIntakeType.name, privacy: .public) with amount: \(myIntakeType.amount, privacy: .public) \(myIntakeType.unit, privacy: .public)")
                            intakeTypes.saveNewIntakeType(intakeType: myIntakeType)
                            logger.info("Successfully saved intake type: \(myIntakeType.name)")
                            
                            // Clear fields after successful addition
                            self.iTypeName = ""
                            self.iTypeUnit = ""
                            self.selectedUnit = .none
                            self.iTypeAmount = 0
                            self.hasEditedAmountField = false
                            self.iTypeDescrip = ""
                            self.iTypeFrequency = ""
                            self.selectedFrequency = .none
                            logger.debug("Cleared all fields after successful addition")
                            
                            // Success confirmation message
                            self.confirmationMessage = "Successfully added intake type \(myIntakeType.name)."
                            self.confirmationColor = .green
                        }
                        
                    }), label: ({
                        HStack {
                            Image(systemName: "plus.arrow.trianglehead.clockwise")
                            Text("Add Intake Type")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2))
                        )
                    }))
                    .foregroundStyle(.blue)
                    
                    // MARK: - Button to remove an intake type by name
                    Button(action: {
                        logger.debug("Remove button tapped for name: '\(iTypeName)'")
                        
                        // Attempt to find intake type by case-insensitive name
                        if let idx = intakeTypes.intakeTypeArray.firstIndex(where: { $0.name.caseInsensitiveCompare(iTypeName) == .orderedSame }) {
                            let removedType = intakeTypes.intakeTypeArray[idx]
                            logger.debug("Found intake type at index \(idx): \(removedType)")
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
                            logger.debug("Cleared all fields after successful removal")
                            
                            // Success confirmation message
                            self.confirmationMessage = "Successfully removed intake type \(removedType.name)."
                            self.confirmationColor = .green
                        } else {
                            // Failure confirmation message
                            logger.warning("Could not find intake type to remove: \(iTypeName)")
                            logger.debug("Available intake types: \(intakeTypes.intakeTypeArray.map { $0.name })")
                            self.confirmationMessage = "Could not find intake type named \(iTypeName) to remove."
                            self.confirmationColor = .red
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove This Intake Type")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, style: StrokeStyle(lineWidth: 2))
                        )
                    })
                    .foregroundStyle(.red)
                }
                
                // Confirmation message display below buttons
                if !confirmationMessage.isEmpty {
                    Text(confirmationMessage)
                        .foregroundStyle(confirmationColor)
                        .font(.callout.bold())
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding()
            
            // Ingredient picker sheet
            .sheet(isPresented: $showingIngredientPicker) {
                logger.debug("Ingredient picker sheet dismissed")
            } content: {
                NavigationStack {
                    List {
                        ForEach(filteredIngredientNames, id: \.self) { name in
                            Button {
                                logger.debug("Selected ingredient: '\(name)'")
                                iTypeName = name
                                showingIngredientPicker = false
                            } label: {
                                HStack {
                                    Text(name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if iTypeName == name {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search ingredients")
                    .onChange(of: searchText) { oldValue, newValue in
                        logger.debug("Search text changed: '\(oldValue)' -> '\(newValue)', filtered count: \(filteredIngredientNames.count)")
                    }
                    .navigationTitle("Select Ingredient")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                logger.debug("Ingredient picker cancelled")
                                showingIngredientPicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .task {
            logger.debug("AddIntakeType view appeared, loading ingredients")
            if let url = Bundle.main.url(forResource: "ingredients_list", withExtension: "json") {
                logger.debug("Found ingredients_list.json at: \(url.path)")
                do {
                    let data = try Data(contentsOf: url)
                    logger.debug("Loaded \(data.count) bytes from ingredients_list.json")
                    
                    if let decoded = try? JSONDecoder().decode([Ingredient].self, from: data) {
                        self.ingredientNames = decoded.map { $0.name }
                        logger.info("Loaded \(ingredientNames.count) ingredients from structured JSON")
                    } else if let decodedStrings = try? JSONDecoder().decode([String].self, from: data) {
                        self.ingredientNames = decodedStrings
                        logger.info("Loaded \(ingredientNames.count) ingredients from string array JSON")
                    } else {
                        logger.error("Failed to decode ingredients_list.json - format not recognized")
                    }
                    
                    if self.iTypeName.isEmpty || !filteredIngredientNames.contains(self.iTypeName) {
                        if let firstFiltered = filteredIngredientNames.first {
                            logger.debug("Setting default ingredient name to: '\(firstFiltered)'")
                            self.iTypeName = firstFiltered
                        } else {
                            logger.warning("No ingredients available after filtering")
                        }
                    }
                } catch {
                    logger.error("Failed to load ingredient names: \(error.localizedDescription)")
                }
            } else {
                logger.error("ingredients_list.json not found in bundle")
            }
            logger.debug("Current intake types count: \(intakeTypes.intakeTypeArray.count)")
        }
    }
}

#Preview {
    AddIntakeType()
        .environmentObject(CurrentIntakeTypes())
}
