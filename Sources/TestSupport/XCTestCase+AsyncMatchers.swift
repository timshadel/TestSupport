// Copyright © 2024 Tim Shadel. All rights reserved.

import Foundation
import XCTest

// MARK: - Async

public extension XCTestCase {
    typealias AsyncExecution = () -> Void
    static var defaultTimeout: TimeInterval { return 5.0 }

    /// Use this when you want to
    func runAndWaitForChecks(
        description: String = "Waiting",
        _ block: (AsyncExecution) -> Void
    ) {
        let waiter = expectation(description: description)
        block {
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 5)
    }

    func expectEventually(
        subject: String = "this",
        nil expression: @autoclosure @escaping () -> Any?,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return expression() == nil
        }

        wait(
            for: subject,
            toEventually: "be nil",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually(
        subject: String = "this",
        notNil expression: @autoclosure @escaping () -> Any?,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return expression() != nil
        }

        wait(
            for: subject,
            toEventually: "not be nil",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually(
        subject: String = "element",
        exists element: XCUIElement,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return element.exists
        }

        wait(
            for: "\(subject) \(element.description)",
            toEventually: "exist",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually(
        subject: String = "",
        doesNotExist element: XCUIElement,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return !element.exists
        }

        wait(
            for: "\(subject) \(element.description)",
            toEventually: "not exist",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually(
        subject: String = "",
        hasContent element: XCUIElement,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return !element.label.isEmpty
        }

        wait(
            for: "\(subject) \(element.description)",
            toEventually: "have content",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually(
        subject: String = "this",
        false expression: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return expression() == false
        }

        wait(
            for: subject,
            toEventually: "be false",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually(
        subject: String = "this",
        true expression: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        let expected = expectation { () -> Bool in
            return expression() == true
        }

        wait(
            for: subject,
            toEventually: "be true",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually<T: Equatable>(
        _ this: @autoclosure @escaping () -> T,
        equals expression: @autoclosure @escaping () -> T,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        var lastActual = this()
        var lastExpected = expression()
        guard lastActual != lastExpected else { return }

        let expected = expectation { () -> Bool in
            lastActual = this()
            lastExpected = expression()
            return lastActual == lastExpected
        }

        wait(
            for: "'\(lastActual)'",
            toEventually: "equal '\(lastExpected)'",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    func expectEventually<T: Equatable>(
        subject: String = "value",
        _ this: @autoclosure @escaping () -> T?,
        equals expression: @autoclosure @escaping () -> T,
        timeout: TimeInterval = XCTestCase.defaultTimeout,
        file: String = #file,
        line: Int = #line
    ) {
        var lastActual = this()
        var lastExpected = expression()
        guard let actual = lastActual, actual == lastExpected else { return }

        let expected = expectation { () -> Bool in
            lastActual = this()
            lastExpected = expression()
            guard let actual = lastActual else { return false }
            return actual == lastExpected
        }

        wait(
            for: "\(subject) '\(lastActual.plainDescription)'",
            toEventually: "equal '\(lastExpected)'",
            timeout: timeout,
            with: [expected],
            file: file,
            line: line
        )
    }

    private func expectation(from block: @escaping () -> Bool) -> XCTestExpectation {
        let predicate = NSPredicate { _, _ -> Bool in
            return block()
        }
        let expected = expectation(for: predicate, evaluatedWith: NSObject())
        return expected
    }

    // swiftlint:disable function_parameter_count
    private func wait(
        for subject: String,
        toEventually outcome: String,
        timeout: TimeInterval,
        with expectations: [XCTestExpectation],
        file: String,
        line: Int
    ) {
        let result = XCTWaiter().wait(for: expectations, timeout: timeout)

        switch result {
        case .completed:
            return
        case .timedOut:
            self.recordFailure(
                description: "Expected \(subject) to eventually \(outcome). Timed out after \(timeout)s.",
                inFile: file,
                atLine: Int(line),
                type: .assertionFailure
            )
        default:
            self.recordFailure(
                description: "Unexpected result while waiting for \(subject) to eventually \(outcome): \(result)",
                inFile: file,
                atLine: Int(line),
                type: .unmatchedExpectedFailure
            )
        }
    }
}
