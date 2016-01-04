//
//  TimestampLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A formatting module for use with the `ModularLogFormatter` that converts
 `NSDate`-based timestamps into strings.
*/
public struct TimestampLogFormatter: LogFormatter
{
    private let formatter: NSDateFormatter

    public init(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS zzz")
    {
        formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
    }

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return formatter.stringFromDate(entry.timestamp)
    }
}
