//
//  CallingThreadLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns a hexadecimal string representation of a
 `LogEntry`'s `callingThreadID`.
 
 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct CallingThreadLogFormatter: LogFormatter
{
    /** Class initializer. */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning a hexadecimal string
     representation of its `callingThreadID`.
     
     - returns: The formatted result; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        return String(format: "%08X", entry.callingThreadID)
    }
}
