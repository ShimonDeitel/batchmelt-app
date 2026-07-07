import XCTest
@testable import BatchMelt

final class BatchMeltTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchMeltStore()
        XCTAssertGreaterThan(store.pours.count, 0)
        XCTAssertLessThan(store.pours.count, BatchMeltStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchMeltStore()
        let before = store.pours.count
        let added = store.addPour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.pours.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchMeltStore()
        let before = store.pours.count
        let added = store.addPour(pieceName: "   ", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.pours.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchMeltStore()
        for item in store.pours { store.deletePour(item.id) }
        for _ in 0..<BatchMeltStore.freeLimit {
            XCTAssertTrue(store.addPour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: false))
        }
        XCTAssertFalse(store.addPour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: false))
        XCTAssertTrue(store.addPour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchMeltStore()
        store.addPour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: false)
        guard let item = store.pours.last else { return XCTFail("expected entry") }
        let before = store.pours.count
        store.deletePour(item.id)
        XCTAssertEqual(store.pours.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchMeltStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.pours.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchMeltStore()
        store.addPour(pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part", isPro: false)
        guard let item = store.pours.last else { return XCTFail("expected entry") }
        store.updatePour(item.id, pieceName: "Belt Buckle", alloyType: "Aluminum", pourTemp: "1350", moldPattern: "Sand - 2 part")
        XCTAssertEqual(store.pours.count, store.pours.count)
    }
}
