// Copyright © 2024 Tim Shadel. All rights reserved.

import Foundation
import XCTest

public protocol TestPage {
    var testCase: XCTestCase { get }
    var app: XCUIApplication { get }
}


public extension TestPage {
    var app: XCUIApplication { XCUIApplication() }
}
