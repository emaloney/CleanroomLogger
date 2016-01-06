//
//  StackFrameLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `LogFormatter` that returns the `callingStackFrame` property of a `LogEntry`.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct StackFrameLogFormatter: LogFormatter
{
    /** Class initializer. */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning the value of its 
     `callingStackFrame` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result; never `nil`.
     */
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return entry.callingStackFrame
    }
}
