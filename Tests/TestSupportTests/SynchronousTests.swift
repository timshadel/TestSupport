import XCTest
@testable import TestSupport

final class TestSupportTests: XCTestCase {
    func testNil() throws {
        expect(nil: nil)
        expect(notNil: 1)
    }

    func testBool() throws {
        expect(true: true)
        expect(false: false)
    }

    func testUnwrap() throws {
        let i: Int? = 1
        let j = try expect(toUnwrap: i)
        expect(i, equals: j)
    }

    func testThrows() throws {
        shouldNotThrow {
            _ = 1 + 2
        }
        shouldThrow {
            throw TestSupportError.whatever
        }
    }

    func testDoubles() throws {
        expect(3.1415926, approximatelyEquals: .pi)
        expect(3.1415926, doesNotApproximatelyEqual: .pi, within: 0.000_000_001)
    }

    func testComparisons() throws {
        expect("aab", lessThan: "bba")
        expect(0, lessThan: 12.35)
        expect(0, lessThanOrEqualTo: 0)
        expect("bba", greaterThan: "aab")
        expect(12.35, greaterThan: 0)
        expect(0, greaterThanOrEqualTo: 0)
    }

    func testString() throws {
        expect("testing", has: .prefix("test"))
        expect("testing", has: .suffix("ing"))
        expect("testing", contains: "est")
        expect("testing", doesNotContain: "best")
    }

    func testEquals() throws {
        expect(5, equals: 5)
        expect(subject: "messages", 5, equals: 5)
        expect(5, doesNotEqual: 4)
        expect(5, doesNotEqual: nil)
    }

    func testDates() throws {
        let now = Date()
        let later = Date(timeIntervalSinceNow: 45)
        expect(date: now, equals: now)
        // now and later may occur in different minutes, even though they are < 60 seconds apart
        expect(date: now, equals: later, downToThe: .hour)
        // expect(date: now, toBeWithin: DateComponents(minute: 1), of: later)
    }
}

enum TestSupportError: Error {
    case whatever
}
