//
//  ProcessNameLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns a `LogEntry`'s `processName` property.
 
 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct ProcessNameLogFormatter: LogFormatter
{
    /** The initializer. */
    public init() {}
    
    /**
     Formats the passed-in `LogEntry` by returning its `processName` property.
     
     - parameter entry: The `LogEntry` to be formatted.
     
     - returns: The formatted result; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        return entry.processName
    }
}
