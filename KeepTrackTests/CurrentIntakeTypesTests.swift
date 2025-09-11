import Foundation
import Testing
@testable import KeepTrack

@Suite("CurrentIntakeTypes")
struct CurrentIntakeTypesTests {
    @Test("Add new intake type")
    func testAddNewIntakeType() async throws {
        // Arrange: create a test instance
        let cIntake = await CurrentIntakeTypes()
        // Wait for initial types to load
        try await Task.sleep(nanoseconds: 200_000_000)
//        _ = await MainActor.run { cIntake.intakeTypeArray.count }
        let newType = IntakeType(
            id: UUID(),
            name: "Test Juice",
            unit: "oz",
            amount: 8,
            descrip: "Test description",
            frequency: frequency.none.rawValue
        )

        // Act: Add the new intake type
        await cIntake.saveNewIntakeType(intakeType: newType)
        // Wait up to 2 seconds for the new type to appear
        let start = Date()
        while true {
            let names = await MainActor.run { cIntake.intakeTypeNameArray }
            if names.contains("Test Juice") {
                break
            }
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            if Date().timeIntervalSince(start) > 2.0 {
                break // timeout after 2 seconds
            }
        }

        // Assert: Check that the new intake type is present
        let names = await MainActor.run { cIntake.intakeTypeNameArray }
        #expect(names.contains("Test Juice"), "New intake type should be in the names array")
        let found = try #require(await MainActor.run { cIntake.intakeTypeArray.first { $0.name == "Test Juice" } }, "New intake type should be present in intakeTypeArray")
        #expect(found.unit == "oz", "Unit should be correct")
        #expect(found.amount == 8, "Amount should be correct")
    }
}
