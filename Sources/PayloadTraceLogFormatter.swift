//
//  PayloadTraceLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/6/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns the `callingStackFrame` of a `LogEntry` whose
 `payload` is `.trace`.
 */
public struct PayloadTraceLogFormatter: LogFormatter
{
    /**
     The initializer.
     */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `payload` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: `entry.callingStackFrame`, or `nil` if `entry` doesn't have a 
     `payload` with a `.trace` value.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        guard case .trace = entry.payload else { return nil }

        return entry.callingStackFrame
    }
}
