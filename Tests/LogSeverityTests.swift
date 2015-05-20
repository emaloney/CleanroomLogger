//
//  LogSeverityTests.swift
//  Cleanroom Project
//
//  Created by Claudio Romandini on 5/19/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import XCTest
import CleanroomLogger

class LogSeverityTests: XCTestCase {

    func testLogSeverityEquality() {
        XCTAssertTrue(LogSeverity.Debug == LogSeverity.Debug, "Debug should be equal to itself.")
        XCTAssertTrue(LogSeverity.Info != LogSeverity.Warning, "Info should be not equal to Warning.")
    }
    
    func testLogSeverityComparableImplementation() {
        XCTAssertTrue(LogSeverity.Verbose < LogSeverity.Debug, "Verbose should be less than Debug.")
        XCTAssertTrue(LogSeverity.Info >= LogSeverity.Debug, "Info should be greater than or equal to Debug.")
        XCTAssertTrue(LogSeverity.Warning > LogSeverity.Info, "Warning should be greater than Info.")
        XCTAssertTrue(LogSeverity.Warning <= LogSeverity.Error, "Warning should be less than or equal to Error.")
    }
}
