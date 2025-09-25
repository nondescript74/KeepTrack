import SwiftUI
import OSLog
import Charts

struct ConsumptionByDayAndTimeModel {
    let entries: [CommonEntry]
    
    var groupedEntries: [(date: Date, entries: [CommonEntry])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        // Sort days descending (most recent first)
        return groups.sorted { $0.key > $1.key }
            .map { (date: $0.key, entries: $0.value.sorted { $0.date < $1.date }) }
    }
    
    var chartData: [ConsumptionByDayAndTimeView.ChartData] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: entries) { entry in
            ConsumptionByDayAndTimeView.DayTypeKey(date: calendar.startOfDay(for: entry.date), name: entry.name)
        }
        return groups.map { (key, entries) in
            ConsumptionByDayAndTimeView.ChartData(date: key.date, name: key.name, total: entries.reduce(0) { $0 + $1.amount }, count: entries.count)
        }
    }
}

struct ConsumptionByDayAndTimeView: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ConsumptionByDayAndTime")
    @Environment(CommonStore.self) private var store
    @EnvironmentObject private var cIntakeTypes: CurrentIntakeTypes
    
    @State private var hoveredChartData: ChartData?
    
    var model: ConsumptionByDayAndTimeModel {
        ConsumptionByDayAndTimeModel(entries: store.history)
    }
    
    // Helper: Group entries by day (using just the date, no time)
    struct DayTypeKey: Hashable {
        let date: Date
        let name: String
    }
    
    // Prepare chart data: [ChartData] with date, type, total amount for that day/type
    struct ChartData: Identifiable, Hashable {
        let id = UUID()
        let date: Date
        let name: String
        let total: Double
        let count: Int
    }
    
    // Palette for colors (assuming it exists or adding a default one)
    static let palette: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .yellow, .teal, .indigo, .brown
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        ScrollView(.horizontal, showsIndicators: true) {
                            let uniqueNames = Array(NSOrderedSet(array: model.chartData.map(\.name)).array as! [String])
//                            let colorMap: KeyValuePairs<String, Color> = KeyValuePairs(dictionaryLiteral: uniqueNames.enumerated().map { ($1, Self.palette[$0 % Self.palette.count]) })
                            
                            Chart(model.chartData, id: \.id) { data in
                                BarMark(
                                    x: .value("Amount", data.total),
                                    y: .value("Day", data.date, unit: .day)
                                )
                                .foregroundStyle(by: .value("Type", data.name))
                                .position(by: .value("Type", data.name))
                            }
//                            .chartForegroundStyleScale(colorMap)
                            .frame(width: max(CGFloat(model.groupedEntries.count) * 70, geometry.size.width), height: 420)
                            .padding(.horizontal)
                            .chartOverlay { proxy in
                                Rectangle().fill(Color.clear).contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let location = value.location
                                                if let date: Date = proxy.value(atX: location.x) {
                                                    // Find the closest ChartData with this date
                                                    if let element = model.chartData.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).first {
                                                        hoveredChartData = element
                                                    } else {
                                                        hoveredChartData = nil
                                                    }
                                                } else {
                                                    hoveredChartData = nil
                                                }
                                            }
                                            .onEnded { _ in
                                                hoveredChartData = nil
                                            }
                                    )
                            }
                        }
                        if let hovered = hoveredChartData {
                            VStack(spacing: 4) {
                                Text("\(hovered.name)")
                                Text("\(hovered.total, specifier: "%.1f")")
                                Text(hovered.date.formatted(date: .abbreviated, time: .omitted))
                            }
                            .font(.caption)
                            .padding(8)
                            .background(.thinMaterial)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 32)
                        }
                    }
                }
                .frame(height: 420)
                
                List {
                    ForEach(model.groupedEntries, id: \.date) { group in
                        Section(header: Text(group.date.formatted(date: .abbreviated, time: .omitted)).font(.headline)) {
                            ForEach(group.entries) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 0.5) {
                                        Text(entry.name)
                                            .font(.caption)
                                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(entry.amount, specifier: "%.1f") \(entry.units)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    if entry.goalMet {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                                .padding(.vertical, 0.5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("By Day & Time")
        }
    }
}

#Preview {
    ConsumptionByDayAndTimeView()
        .environment(CommonStore())
        .environmentObject(CurrentIntakeTypes())
}
