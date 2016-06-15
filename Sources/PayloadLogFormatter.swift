//
//  PayloadLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns a string representation of a `LogEntry`'s
 `payload` property.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct PayloadLogFormatter: LogFormatter
{
    /** Class initializer. */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `payload` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result; never `nil`.
     */
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        switch entry.payload {
        case .trace:                return entry.callingStackFrame
        case .message(let msg):     return msg
        case .value(let value):     return "\(value)"
        }
    }
}
