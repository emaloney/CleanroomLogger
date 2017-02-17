//
//  LogSeverityComparisonTests.swift
//  Cleanroom Project
//
//  Created by Claudio Romandini on 5/19/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import XCTest
import CleanroomLogger

class LogSeverityTests: XCTestCase
{
    func testLogSeverityEquality()
    {
        XCTAssertTrue(LogSeverity.debug == LogSeverity.debug, "Debug should be equal to itself.")
        XCTAssertTrue(LogSeverity.info != LogSeverity.warning, "Info should be not equal to Warning.")
    }
    
    func testLogSeverityComparableImplementation()
    {
        XCTAssertTrue(LogSeverity.verbose < LogSeverity.debug, "Verbose should be less than Debug.")
        XCTAssertTrue(LogSeverity.info >= LogSeverity.debug, "Info should be greater than or equal to Debug.")
        XCTAssertTrue(LogSeverity.warning > LogSeverity.info, "Warning should be greater than Info.")
        XCTAssertTrue(LogSeverity.warning <= LogSeverity.error, "Warning should be less than or equal to Error.")
    }
}
