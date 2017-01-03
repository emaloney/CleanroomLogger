//
//  CallSiteLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `LogFormatter` that returns a string representation of the `LogEntry`'s
 *call site*, consisting of the last path component of the `callingFilePath`
 followed by the `callingFileLine` within that file.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct CallSiteLogFormatter: LogFormatter
{
    /** The initializer. */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     the call site specified by its `callingFilePath` and `callingFileLine`
     properties.
     
     - returns: The formatted result; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        let file = (entry.callingFilePath as NSString).pathComponents.last ?? "redacted"
        return "\(file):\(entry.callingFileLine)"
    }
}
