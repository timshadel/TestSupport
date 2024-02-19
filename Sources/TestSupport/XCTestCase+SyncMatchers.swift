// Copyright © 2023 Tim Shadel. All rights reserved.

import Foundation
import XCTest

public extension XCTestCase {
    // MARK: - Throws
    func shouldNotThrow(
        file: String = #file,
        line: Int = #line,
        _ block: () throws -> Void
    ) {
        do {
            _ = try block()
        } catch {
            recordFailure(
                description: "Boo! \(error)",
                inFile: file,
                atLine: Int(line),
                type: .thrownError
            )
        }
    }

    func shouldThrow(
        file: String = #file,
        line: Int = #line,
        _ block: () throws -> Void
    ) {
        do {
            _ = try block()
            recordFailure(
                description: "Should have thrown!",
                inFile: file,
                atLine: Int(line),
                type: .unmatchedExpectedFailure
            )
        } catch {
        }
    }

    // MARK: - Fail
    func fail(
        _ message: String,
        file: String = #file,
        line: Int = #line
    ) {
        recordFailure(description: "Failure: \(message)", inFile: file, atLine: Int(line), type: .system)
    }

    // MARK: - Equals
    func expect(
        nil expression: @autoclosure () -> Any?,
        file: String = #file,
        line: Int = #line
    ) {
        if let this = expression() {
            recordFailure(
                description: "Expected '\(this)' to be nil.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect(
        notNil expression: @autoclosure () -> Any?,
        file: String = #file,
        line: Int = #line
    ) {
        if expression() == nil {
            recordFailure(
                description: "Expected this not to be nil.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T>(
        toUnwrap expression: @autoclosure () throws -> T?,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        let e = try expression()
        return try XCTUnwrap(e, file: file, line: line)
    }

    func expect(
        exists element: XCUIElement,
        file: String = #file,
        line: Int = #line
    ) {
        if !element.exists {
            print(XCUIApplication().debugDescription)
            recordFailure(
                description: "Expected \(element) to exist.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect(
        doesNotExist element: XCUIElement,
        file: String = #file,
        line: Int = #line
    ) {
        if element.exists {
            recordFailure(
                description: "Expected \(element) to not exist.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect(
        oneExists elements: [XCUIElement],
        file: String = #file,
        line: Int = #line
    ) /* -> XCUIElement? */ {
        for element in elements where element.exists {
            // return element
            return
        }
        print(XCUIApplication().debugDescription)
        recordFailure(
            description: "Expected one of \(elements) to exist.",
            inFile: file,
            atLine: Int(line),
            type: .assertionFailure
        )
    }

    func expect(
        false expression: @autoclosure () -> Bool?,
        file: String = #file,
        line: Int = #line
    ) {
        guard let actual = expression() else {
            recordFailure(
                description: "Expected 'nil' to be false.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
            return
        }
        if actual != false {
            recordFailure(
                description: "Expected this to be false.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect(
        true expression: @autoclosure () -> Bool?,
        file: String = #file,
        line: Int = #line
    ) {
        guard let actual = expression() else {
            recordFailure(
                description: "Expected 'nil' to be true.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
            return
        }
        if actual != true {
            recordFailure(
                description: "Expected this to be true.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: BinaryFloatingPoint>(
        _ this: @autoclosure () -> T?,
        approximatelyEquals expression: @autoclosure () -> T?,
        within delta: T = 0.000_1,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()

        if !approximatelyEquals(actual, expected, within: delta) {
            let desc = "Expected '\(String(describing: actual))' to equal '\(String(describing: expected)) within \(delta)"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: BinaryFloatingPoint>(
        _ this: @autoclosure () -> T?,
        doesNotApproximatelyEqual expression: @autoclosure () -> T?,
        within delta: T = 0.000_1,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if approximatelyEquals(actual, expected, within: delta) {
            let desc = "Expected '\(String(describing: actual))' not to equal '\(String(describing: expected)) within \(delta)"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    enum StringHas: CustomStringConvertible {
        case prefix(String)
        case suffix(String)

        public var description: String {
            switch self {
            case .prefix:
                return "prefix"
            case .suffix:
                return "suffix"
            }
        }
    }

    func expect(
        _ this: @autoclosure () -> String,
        has expression: @autoclosure () -> StringHas,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let part = expression()
        var success = false
        var value: String
        let expressionValue = expression()
        switch expressionValue {
        case .prefix(let prefix):
            value = prefix
            success = actual.hasPrefix(value)
        case .suffix(let suffix):
            value = suffix
            success = actual.hasSuffix(value)
        }
        if !success {
            recordFailure(
                description: "Expected '\(actual)' to have \(part) '\(value)'",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: Equatable>(
        noun: String = "",
        _ this: @autoclosure () -> T?,
        equals expression: @autoclosure () -> T?,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if !equals(actual, expected) {
            let desc = "Expected \(noun) '\(actual.plainDescription)' to equal '\(expected.plainDescription)'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: Equatable>(
        _ this: @autoclosure () -> T?,
        doesNotEqual expression: @autoclosure () -> T?,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if equals(actual, expected) {
            let desc = "Expected '\(actual.plainDescription)' to not equal '\(expected.plainDescription)'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: Comparable>(
        noun: String = "",
        _ this: @autoclosure () -> T?,
        lessThan expression: @autoclosure () -> T?,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if !lessThan(actual, expected) {
            let desc = "Expected \(noun) '\(actual.plainDescription)' to be less than '\(expected.plainDescription)'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: Comparable>(
        noun: String = "",
        _ this: @autoclosure () -> T?,
        lessThanOrEqualTo expression: @autoclosure () -> T?,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if !equals(actual, expected) && !lessThan(actual, expected) {
            let desc = "Expected \(noun) '\(actual.plainDescription)' to be less than or equal to '\(expected.plainDescription)'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: Comparable>(
        noun: String = "",
        _ this: @autoclosure () -> T?,
        greaterThan expression: @autoclosure () -> T?,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if !greaterThan(actual, expected) {
            let desc = "Expected \(noun) '\(actual.plainDescription)' to be greater than '\(expected.plainDescription)'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect<T: Comparable>(
        noun: String = "",
        _ this: @autoclosure () -> T?,
        greaterThanOrEqualTo expression: @autoclosure () -> T?,
        file: String = #file,
        line: Int = #line
    ) {
        let actual = this()
        let expected = expression()
        if !equals(actual, expected) && !greaterThan(actual, expected) {
            let desc = "Expected \(noun) '\(actual.plainDescription)' to be greater than or equal to '\(expected.plainDescription)'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }
    
    func expect(
        date thisDate: Date?,
        equals thatDate: Date?,
        downToThe component: Calendar.Component = .second,
        file: String = #file,
        line: Int = #line
    ) {
        guard let thisDate = thisDate, let thatDate = thatDate else {
            recordFailure(
                description: "Expected dates not to be nil",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
            return
        }
        if !Calendar.current.isDate(thisDate, equalTo: thatDate, toGranularity: component) {
            recordFailure(
                description: "Expected \(thisDate) to equal: \(thatDate)",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect(
        date thisDate: Date?,
        toBeWithin timeSpan: DateComponents,
        of thatDate: Date?,
        component: Calendar.Component,
        file: String = #file,
        line: Int = #line
    ) {
        guard let thisDate = thisDate, let thatDate = thatDate else {
            recordFailure(
                description: "Expected dates to not be nil",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
            return
        }
        if !Calendar.current.isDate(thisDate, equalTo: thatDate, toGranularity: component) {
            recordFailure(
                description: "Expected \(thisDate) to equal: \(thatDate)",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    // MARK: - Contains
    func expect(
        _ actual: String,
        contains expected: String...,
        file: String = #file,
        line: Int = #line
    ) {
        let result = expected.map { actual.contains($0) }
        if let index = result.firstIndex(of: false) {
            recordFailure(
                description: "Expected '\(actual)' to contain '\(expected[index])'",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    func expect(
        _ actual: String,
        doesNotContain expected: String...,
        file: String = #file,
        line: Int = #line
    ) {
        let result = expected.map { actual.contains($0) }
        if let index = result.firstIndex(of: true) {
            let desc = "Expected '\(actual)' to not contain '\(expected[index])'"
            recordFailure(
                description: desc,
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        }
    }

    private func equals<T: Equatable>(_ lhs: T?, _ rhs: T?) -> Bool {
        if lhs == nil && rhs == nil {
            return true
        }
        guard let actual = lhs, let expected = rhs else {
            return false
        }
        return actual == expected
    }

    private func lessThan<T: Comparable>(_ lhs: T?, _ rhs: T?) -> Bool {
        guard let actual = lhs, let expected = rhs else {
            return false
        }
        return actual < expected
    }

    private func greaterThan<T: Comparable>(_ lhs: T?, _ rhs: T?) -> Bool {
        guard let actual = lhs, let expected = rhs else {
            return false
        }
        return actual > expected
    }

    private func approximatelyEquals<T: BinaryFloatingPoint>(_ lhs: T?, _ rhs: T?, within delta: T = 0.000_1) -> Bool {
        if lhs == nil && rhs == nil {
            return true
        }
        guard let actual = lhs, let expected = rhs else {
            return false
        }
        let diff = abs(actual - expected)
        return diff <= delta
    }
}
