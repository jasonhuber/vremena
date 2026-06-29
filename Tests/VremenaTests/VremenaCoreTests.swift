import XCTest
@testable import VremenaCore

final class CityCatalogTests: XCTestCase {
    func testAllTimeZonesAreValidOnThisSystem() {
        for city in CityCatalog.all {
            XCTAssertTrue(city.isValidTimeZone, "Invalid time zone: \(city.timeZoneID)")
        }
    }

    func testNoDuplicateTimeZones() {
        let ids = CityCatalog.all.map(\.timeZoneID)
        XCTAssertEqual(ids.count, Set(ids).count, "Catalog has duplicate time zones")
    }

    func testEveryCityHasAFlag() {
        for city in CityCatalog.all {
            XCTAssertFalse(city.flag.isEmpty, "\(city.name) has no flag")
        }
    }

    func testSearchByCity() {
        let results = CityCatalog.search("zagreb")
        XCTAssertEqual(results.first?.timeZoneID, "Europe/Zagreb")
    }

    func testSearchByCountry() {
        let results = CityCatalog.search("japan")
        XCTAssertTrue(results.contains { $0.timeZoneID == "Asia/Tokyo" })
    }

    func testEmptySearchReturnsAll() {
        XCTAssertEqual(CityCatalog.search("   ").count, CityCatalog.all.count)
    }

    func testLookupByID() {
        XCTAssertEqual(CityCatalog.city(withID: "Europe/London")?.name, "London")
        XCTAssertNil(CityCatalog.city(withID: "Nowhere/Nope"))
    }

    func testDefaultsExistInCatalog() {
        for id in CityCatalog.defaultSelectionIDs {
            XCTAssertNotNil(CityCatalog.city(withID: id))
        }
    }
}

final class ClockSettingsTests: XCTestCase {
    func testDefaults() {
        let s = ClockSettings()
        XCTAssertEqual(s.menuBarCount, 2)
        XCTAssertFalse(s.use24Hour)
        XCTAssertEqual(s.selectedIDs, CityCatalog.defaultSelectionIDs)
    }

    func testAddIgnoresUnknownAndDuplicates() {
        var s = ClockSettings(selectedIDs: [])
        s.add("Asia/Tokyo")
        s.add("Asia/Tokyo")        // duplicate
        s.add("Nowhere/Nope")      // unknown
        XCTAssertEqual(s.selectedIDs, ["Asia/Tokyo"])
    }

    func testToggle() {
        var s = ClockSettings(selectedIDs: [])
        s.toggle("Europe/Paris")
        XCTAssertTrue(s.contains("Europe/Paris"))
        s.toggle("Europe/Paris")
        XCTAssertFalse(s.contains("Europe/Paris"))
    }

    func testRemoveClampsMenuBarCount() {
        var s = ClockSettings(selectedIDs: ["Asia/Tokyo", "Europe/Paris"], menuBarCount: 2)
        s.remove("Europe/Paris")
        XCTAssertEqual(s.effectiveMenuBarCount, 1)
    }

    func testEffectiveMenuBarCountClampsToSelection() {
        let s = ClockSettings(selectedIDs: ["Asia/Tokyo"], menuBarCount: 5)
        XCTAssertEqual(s.effectiveMenuBarCount, 1)
    }

    func testEffectiveMenuBarCountFloorsAtOne() {
        let s = ClockSettings(selectedIDs: ["Asia/Tokyo", "Europe/Paris"], menuBarCount: 0)
        XCTAssertEqual(s.effectiveMenuBarCount, 1)
    }

    func testMove() {
        var s = ClockSettings(selectedIDs: ["A", "B", "C"])
        s.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)
        XCTAssertEqual(s.selectedIDs, ["B", "C", "A"])
    }

    func testJSONRoundTrip() {
        let original = ClockSettings(
            selectedIDs: ["Asia/Tokyo", "America/New_York"],
            menuBarCount: 2,
            use24Hour: true,
            showSeconds: true,
            launchAtLogin: true
        )
        let data = try! XCTUnwrap(original.encoded())
        let restored = try! XCTUnwrap(ClockSettings.decoded(from: data))
        XCTAssertEqual(original, restored)
    }

    func testSelectedCitiesSkipsInvalid() {
        let s = ClockSettings(selectedIDs: ["Asia/Tokyo", "Bogus/Zone"])
        XCTAssertEqual(s.selectedCities.map(\.timeZoneID), ["Asia/Tokyo"])
    }
}

final class ClockFormatterTests: XCTestCase {
    // A fixed instant: 2026-06-29 12:00:00 UTC.
    private let instant: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 6; c.day = 29
        c.hour = 12; c.minute = 0; c.second = 0
        c.timeZone = TimeZone(identifier: "UTC")
        return Calendar(identifier: .gregorian).date(from: c)!
    }()

    private let utc = City(name: "UTC", country: "C", flag: "🌐", timeZoneID: "UTC")
    private let tokyo = CityCatalog.city(withID: "Asia/Tokyo")!  // UTC+9

    func test12HourTime() {
        let f = ClockFormatter(use24Hour: false)
        XCTAssertEqual(f.time(for: utc, at: instant), "12:00")
        XCTAssertEqual(f.time(for: tokyo, at: instant), "9:00")  // 21:00 -> 9
    }

    func test24HourTime() {
        let f = ClockFormatter(use24Hour: true)
        XCTAssertEqual(f.time(for: utc, at: instant), "12:00")
        XCTAssertEqual(f.time(for: tokyo, at: instant), "21:00")
    }

    func testSeconds() {
        let f = ClockFormatter(use24Hour: true, showSeconds: true)
        XCTAssertEqual(f.time(for: utc, at: instant), "12:00:00")
    }

    func testMeridiem() {
        let f = ClockFormatter(use24Hour: false)
        XCTAssertEqual(f.timeWithMeridiem(for: tokyo, at: instant), "9:00 PM")
    }

    func testMenuBarToken() {
        let f = ClockFormatter(use24Hour: true)
        XCTAssertEqual(f.menuBarToken(for: tokyo, at: instant), "🇯🇵 21:00")
    }

    func testMenuBarTitleRespectsCount() {
        let f = ClockFormatter(use24Hour: true)
        let cities = [utc, tokyo]
        XCTAssertEqual(f.menuBarTitle(for: cities, count: 1, at: instant), "🌐 12:00")
        XCTAssertEqual(f.menuBarTitle(for: cities, count: 2, at: instant), "🌐 12:00  🇯🇵 21:00")
    }

    func testMenuBarTitleEmpty() {
        let f = ClockFormatter()
        XCTAssertEqual(f.menuBarTitle(for: [], count: 2, at: instant), "🕔 Vremena")
    }

    func testRelativeOffsetSameZone() {
        // Compare a city in the current zone against local — should read "same".
        let local = City(name: "Local", country: "", flag: "", timeZoneID: TimeZone.current.identifier)
        let f = ClockFormatter()
        XCTAssertEqual(f.relativeOffset(for: local, at: instant), "same")
    }
}
