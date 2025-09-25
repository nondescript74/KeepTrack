// ConsumptionByDayAndTimeModelTests.swift
// Unit tests for ConsumptionByDayAndTimeModel

import Foundation
import Testing
@testable import KeepTrack // Adjust if your module name differs

@Suite("ConsumptionByDayAndTimeModel Tests")
struct ConsumptionByDayAndTimeModelTests {
    // Helper to create test entries
    func makeEntry(name: String, amount: Double, date: Date, units: String = "mg", goalMet: Bool = false) -> CommonEntry {
        CommonEntry(id: UUID(), date: date, units: units, amount: amount, name: name, goalMet: goalMet)
    }

    @Test("Groups entries correctly by day")
    func testGroupedEntries() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let entries = [
            makeEntry(name: "A", amount: 2, date: today),
            makeEntry(name: "B", amount: 3, date: today),
            makeEntry(name: "A", amount: 1, date: yesterday)
        ]
        let model = ConsumptionByDayAndTimeModel(entries: entries)
        let grouped = model.groupedEntries
        #expect(grouped.count == 2)
        #expect(grouped[0].date == today)
        #expect(grouped[1].date == yesterday)
        #expect(grouped[0].entries.count == 2)
        #expect(grouped[1].entries.count == 1)
    }

    @Test("Aggregates chart data by day and type")
    func testChartDataAggregation() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries = [
            makeEntry(name: "Juice", amount: 2, date: today),
            makeEntry(name: "Juice", amount: 3, date: today),
            makeEntry(name: "Water", amount: 5, date: today)
        ]
        let model = ConsumptionByDayAndTimeModel(entries: entries)
        let chartData = model.chartData
        let juice = chartData.first { $0.name == "Juice" }
        let water = chartData.first { $0.name == "Water" }
        #expect(juice?.total == 5)
        #expect(water?.total == 5)
    }

    @Test("Handles empty entries gracefully")
    func testEmptyEntries() async throws {
        let model = ConsumptionByDayAndTimeModel(entries: [])
        #expect(model.groupedEntries.isEmpty)
        #expect(model.chartData.isEmpty)
    }

    @Test("Supports all entries on the same day and type")
    func testSameDaySameType() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries = [
            makeEntry(name: "Juice", amount: 1, date: today),
            makeEntry(name: "Juice", amount: 2, date: today)
        ]
        let model = ConsumptionByDayAndTimeModel(entries: entries)
        let grouped = model.groupedEntries
        let chartData = model.chartData
        #expect(grouped.count == 1)
        #expect(grouped[0].entries.count == 2)
        #expect(chartData.count == 1)
        #expect(chartData[0].total == 3)
    }

    @Test("Handles goalMet flag diversity")
    func testGoalMetVariety() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries = [
            makeEntry(name: "Juice", amount: 2, date: today, goalMet: true),
            makeEntry(name: "Juice", amount: 3, date: today, goalMet: false)
        ]
        let model = ConsumptionByDayAndTimeModel(entries: entries)
        #expect(model.groupedEntries[0].entries.contains { $0.goalMet })
        #expect(model.groupedEntries[0].entries.contains { !$0.goalMet })
    }
}
