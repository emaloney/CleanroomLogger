//
//  LogFilter.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/20/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Before a `LogEntry` is recorded, any `LogFilter`s specified in the active
`LogConfiguration` are given a chance to prevent the entry from being recorded
by returning `false` from the `shouldRecordLogEntry()` function.
*/
public protocol LogFilter
{
    /**
    Called to determine whether the given `LogEntry` should be recorded.

    :param:     entry The `LogEntry` to be evaluated by the filter.
    
    :returns:   `true` if `entry` should be recorded, `false` if not.
    */
    func shouldRecordLogEntry(entry: LogEntry)
        -> Bool
}

/**
A `LogFilter` implementation that filters out any `LogEntry` with a 
`LogSeverity` less than a specified value.
*/
public struct LogSeverityFilter: LogFilter
{
    /** Returns the `LogSeverity` associated with the receiver. */
    public let severity: LogSeverity

    /**
    Initializes a new `LogSeverityFilter` instance.
    
    :param:     severity Specifies the `LogSeverity` that the filter will
                use to determine whether a given `LogEntry` should be
                recorded. Only those log entries with a severity equal to
                or more severe than this value will pass through the filter.
    */
    public init(severity: LogSeverity)
    {
        self.severity = severity
    }

    /**
    Called to determine whether the given `LogEntry` should be recorded.

    :param:     entry The `LogEntry` to be evaluated by the filter.

    :returns:   `true` if `entry.severity` is as or more severe than the
                receiver's `severity` property; `false` otherwise.
    */
    public func shouldRecordLogEntry(entry: LogEntry)
        -> Bool
    {
        return entry.severity >= severity
    }
}
