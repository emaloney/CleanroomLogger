//
//  LoggerTestCase.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/17/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import XCTest
import CleanroomLogger

fileprivate let _xcodeConfig = XcodeLogConfiguration(debugMode: true, verboseDebugMode: true, stdStreamsMode: .useExclusively)
fileprivate let _recorder = BufferedLogEntryMessageRecorder(formatters: _xcodeConfig.recorders.first!.formatters)
fileprivate let _bufferConfig = BasicLogConfiguration(minimumSeverity: .verbose, recorders: [_recorder], synchronousMode: true)

/**
 The `LoggerTestCase` should be used for any test that relies on 
 CleanroomLogger being enabled and configured properly.
 */
class LoggerTestCase: XCTestCase
{
    var recorder: BufferedLogEntryMessageRecorder {
        return _recorder
    }

    override func setUp()
    {
        Log.enable(configuration: [_xcodeConfig, _bufferConfig])

        super.setUp()
    }

    override func tearDown()
    {
        // clear out the buffer before the next test run
        recorder.clear()

        super.tearDown()
    }
}
