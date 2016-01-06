//
//  TimestampLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Encapsulates the various formatting styles that can be used by the
 `TimestampLogFormatter`.
 */
public enum TimestampStyle
{
    case Default
    case UNIX
    case Custom(String)
}

extension TimestampStyle
{
    private var dateFormat: String? {
        switch self {
        case .Default:          return "yyyy-MM-dd HH:mm:ss.SSS zzz"
        case .UNIX:             return nil
        case .Custom(let fmt):  return fmt
        }
    }

    private var formatter: NSDateFormatter? {
        guard let format = dateFormat else {
            return nil
        }

        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter
    }

    private func stringFromDate(date: NSDate, usingFormatter formatter: NSDateFormatter?)
        -> String
    {
        switch self {
        case .UNIX:     return "\(date.timeIntervalSince1970)"
        default:        return formatter!.stringFromDate(date)
        }
    }
}

/**
 A `LogFormatter` that returns a string representation of a `LogEntry`'s
 `timestamp` property.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct TimestampLogFormatter: LogFormatter
{
    /** The `TimestampStyle` that determines how the receiver will format
     its output. */
    public let style: TimestampStyle

    private let formatter: NSDateFormatter?

    /**
     Initializes a new `TimestampLogFormatter` that will use the specified
     `TimestampStyle`.

     - parameter style: A `TimestampStyle` value that will govern the output
     of the `formatLogEntry()` function.
     */
    public init(style: TimestampStyle = .Default)
    {
        self.style = style
        self.formatter = style.formatter
    }

    /**
     Formats the passed-in `LogEntry` by converting its `timestamp` property
     into a string.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result; never `nil`.
     */
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return style.stringFromDate(entry.timestamp, usingFormatter: formatter)
    }
}
