// Copyright © 2023 Tim Shadel. All rights reserved.

import Foundation
import XCTest

public extension XCTestCase {
    func recordFailure(
        description: String,
        inFile filePath: String,
        atLine lineNumber: Int,
        type: XCTIssue.IssueType
    ) {
        let location = XCTSourceCodeLocation(filePath: filePath, lineNumber: lineNumber)
        let sourceCodeContext = XCTSourceCodeContext(location: location)
        let issue = XCTIssue(
            type: type,
            compactDescription: description,
            detailedDescription: description,
            sourceCodeContext: sourceCodeContext,
            associatedError: NSError(domain: description, code: -009)
        )
        record(issue)
    }
}

public extension Optional {
    var plainDescription: String {
        return self.map { String(describing: $0) } ?? "nil"
    }
}
