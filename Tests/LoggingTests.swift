//
//  LoggingTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 8/24/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import XCTest
import Foundation
import CleanroomASL
import CleanroomLogger

class LoggingTests: XCTestCase
{
    func testLoggingToASL()
    {
        let startTime = NSDate()

        Log.enable(debugMode: true, verboseDebugMode: true)

        Log.error?.message("Logging an error message")
        Log.warning?.message("Logging a warning message")
        Log.info?.message("Logging an info message")
        Log.debug?.message("Logging a debug message")
        Log.verbose?.message("Logging a verbose message")

        let client = ASLClient()

        let query = ASLQueryObject()
        query.setQuery(key: .facility, value: "com.gilt.CleanroomLogger", operation: .equalTo, modifiers: .none)
        query.setQuery(key: .message, value: nil, operation: .keyExists, modifiers: .none)
        query.setQuery(key: .time, value: Int(startTime.timeIntervalSince1970), operation: .greaterThanOrEqualTo, modifiers: .none)

        let signal = NSCondition()

        signal.lock()
        signal.wait(until: Date(timeIntervalSinceNow: 1))
        signal.unlock()

        var gotFinalResult = false

        var remainingToFind = Set<String>([
            "|   ERROR | LoggingTests.swift:22 - Logging an error message",
            "| WARNING | LoggingTests.swift:23 - Logging a warning message",
            "|    INFO | LoggingTests.swift:24 - Logging an info message",
            "|   DEBUG | LoggingTests.swift:25 - Logging a debug message",
            "| VERBOSE | LoggingTests.swift:26 - Logging a verbose message"])

        client.search(query) { result in

            if let result = result {
                print("")
                for key in result.attributes.keys.sorted() {
                    print("\t\(key): \(result.attributes[key] ?? "(nil)")")
                }

                let find = (result.message as NSString).substring(from: 28)

                remainingToFind.remove(find)
            }

            signal.lock()
            gotFinalResult = result == nil
            if gotFinalResult {
                signal.signal()
            }
            signal.unlock()

            return true
        }

        signal.lock()
        while !gotFinalResult {
            signal.wait()
        }
        signal.unlock()
        
        XCTAssert(remainingToFind.isEmpty)
    }
}
