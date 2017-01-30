//
//  LoggingTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 8/24/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import XCTest
import Foundation
import CleanroomLogger

class LoggingTests: XCTestCase
{
    func testLogging()
    {
        Log.enable(debugMode: true, verboseDebugMode: true)

        Log.error?.trace()
        Log.error?.message("Logging an error message")
        Log.warning?.trace()
        Log.warning?.message("Logging a warning message")
        Log.info?.trace()
        Log.info?.message("Logging an info message")
        Log.debug?.trace()
        Log.debug?.message("Logging a debug message")
        Log.verbose?.trace()
        Log.verbose?.message("Logging a verbose message")
    }
}
