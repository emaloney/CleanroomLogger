//
//  LogEntryTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 8/24/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import XCTest
import Foundation
import CleanroomLogger

class LogEntryTests: LoggerTestCase
{
    func testCallerInfo()
    {
        //
        // record the calling thread ID for future testing
        //
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        //
        // log something, which we'll use for testing below
        //
        Log.error?.trace()

        //
        // make sure the calling file, line & stack frame look OK
        //
        let logEntry = recorder.buffer.first!.0

        // the test below will break if the Log.error?.trace() call above
        // is moved to a different line...
        XCTAssertEqual(logEntry.callingFileLine, 26)

        // the test below will break if the file containing this code is renamed
        XCTAssertEqual((logEntry.callingFilePath as NSString).lastPathComponent, "LogEntryTests.swift")

        // the test below will break if the containing function is renamed
        XCTAssertEqual(logEntry.callingStackFrame, "testCallerInfo()")

        // verify the calling thread ID
        XCTAssertEqual(logEntry.callingThreadID, threadID)
    }

    func testProcessInfo()
    {
        Log.info?.value("Process info test")

        let logEntry = recorder.buffer.first!.0

        // this test will break if XCTest changes so that it runs under 
        // a different process name
        XCTAssertEqual(logEntry.processName, "xctest")

        // verify ProcessID is what OS thinks it is
        XCTAssertEqual(logEntry.processID, ProcessInfo.processInfo.processIdentifier)
    }

    func testLogSeverity()
    {
        Log.error?.message("Logging an error message")
        Log.warning?.message("Logging a warning message")
        Log.info?.message("Logging an info message")
        Log.debug?.message("Logging a debug message")
        Log.verbose?.message("Logging a verbose message")

        //
        // make sure messages are logged at the level specified
        //
        let results = recorder.keyedMessageBuffer()
        XCTAssertEqual(results["Logging an error message"]?.severity, .error)
        XCTAssertEqual(results["Logging a warning message"]?.severity, .warning)
        XCTAssertEqual(results["Logging an info message"]?.severity, .info)
        XCTAssertEqual(results["Logging a debug message"]?.severity, .debug)
        XCTAssertEqual(results["Logging a verbose message"]?.severity, .verbose)
    }
}
