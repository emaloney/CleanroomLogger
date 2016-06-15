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
    /** Specifies a timestamp style that uses the date format string
     "yyyy-MM-dd HH:mm:ss.SSS zzz". */
    case `default`

    /** Specifies a UNIX timestamp indicating the number of seconds elapsed
    since January 1, 1970. */
    case unix

    /** Specifies a custom date format. */
    case custom(String)
}

extension TimestampStyle
{
    private var dateFormat: String? {
        switch self {
        case .`default`:        return "yyyy-MM-dd HH:mm:ss.SSS zzz"
        case .unix:             return nil
        case .custom(let fmt):  return fmt
        }
    }

    private var formatter: DateFormatter? {
        guard let format = dateFormat else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }

    private func stringFromDate(_ date: Date, usingFormatter formatter: DateFormatter?)
        -> String
    {
        switch self {
        case .unix:     return "\(date.timeIntervalSince1970)"
        default:        return formatter!.string(from: date)
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

    private let formatter: DateFormatter?

    /**
     Initializes a new `TimestampLogFormatter` that will use the specified
     `TimestampStyle`.

     - parameter style: A `TimestampStyle` value that will govern the output
     of the `formatLogEntry()` function.
     */
    public init(style: TimestampStyle = .`default`)
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
    public func formatLogEntry(_ entry: LogEntry)
        -> String?
    {
        return style.stringFromDate(entry.timestamp as Date, usingFormatter: formatter)
    }
}
