//
//  ChangeHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/11/25.
//

import SwiftUI
import OSLog

struct ChangeHistory: View {
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ChangeHistory")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    @EnvironmentObject private var intakeTypes: CurrentIntakeTypes
    
    @State private var selectedIntakeType: IntakeType?
    @State private var selectedDate: Date = Date()
    @State private var name: String = "Water"
    @State private var showingTypePicker: Bool = false
    
    var body: some View {
        VStack {
            Text("Add History")
                .font(.title).bold()
                .foregroundStyle(Color.blue)
                .shadow(color: .blue.opacity(0.18), radius: 4, x: 0, y: 2)
                .padding(.top)
            
            VStack(spacing: 8) {
                HStack {
                    // Custom picker button that shows a sheet instead of menu
                    Button {
                        showingTypePicker = true
                    } label: {
                        HStack {
                            Text(name)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                    )
                    .sheet(isPresented: $showingTypePicker) {
                        HistoryTypePickerSheet(
                            selectedName: $name,
                            isPresented: $showingTypePicker
                        )
                        .environmentObject(intakeTypes)
                    }
                }
                
                HStack {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .font(.caption)
                    
                    Button(action: ({
                        let entry = CommonEntry(id: UUID(), date: selectedDate, units: intakeTypes.sortedIntakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: intakeTypes.sortedIntakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: false)
                        ChangeHistory.logger.info("Adding intake  \(name) with goalMet false")
                        Task {
                            await store.addEntry(entry: entry, goals: goals)
                        }
                    }), label: ({
                        Image(systemName: "plus.arrow.trianglehead.clockwise")
                            .padding(7)
                            .background(Color.blue.gradient, in: Capsule())
                            .foregroundColor(.white)
                    }))
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accentColor.opacity(0.35), lineWidth: 2)
                    )
            )
            .frame(maxWidth: .infinity, alignment: .center)
         
            
            // Show a list of history entries for this intake type (or show all, as you prefer)
            ScrollView {
                VStack {
                    ForEach(store.history.filter { $0.name == name }.sorted { $0.date > $1.date }) { entry in
                        HStack {
                            Text(entry.name)
                                .font(.headline)
                            Spacer()
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                            Text("\(entry.amount, specifier: "%.1f") \(entry.units)")
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    .animation(.default, value: store.history)
                }
//                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
    }
}

// MARK: - Type Picker Sheet for History
private struct HistoryTypePickerSheet: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "HistoryTypePickerSheet")
    @EnvironmentObject var intakeTypes: CurrentIntakeTypes
    @Binding var selectedName: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Group {
                if intakeTypes.sortedIntakeTypeNameArray.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Loading intake types...")
                            .foregroundStyle(.secondary)
                        Button("Reload") {
                            Task {
                                await intakeTypes.reloadFromBundle()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(intakeTypes.sortedIntakeTypeNameArray, id: \.self) { typeName in
                        Button {
                            logger.info("Selected type: \(typeName)")
                            selectedName = typeName
                            isPresented = false
                        } label: {
                            HStack {
                                Text(typeName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedName == typeName {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Type")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        logger.info("Reload button tapped")
                        Task {
                            await intakeTypes.reloadFromBundle()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #else
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        #endif
        .onAppear {
            logger.info("HistoryTypePickerSheet appeared with \(intakeTypes.sortedIntakeTypeNameArray.count) types")
            logger.info("Types: \(intakeTypes.sortedIntakeTypeNameArray.joined(separator: ", "))")
        }
    }
}

#Preview {
    ChangeHistory()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
