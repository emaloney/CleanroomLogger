//
//  ConcatenatingLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 The `ConcatenatingLogFormatter` lets you combine the output of multiple
 `LogFormatter`s by contatenating their output and returning the result.
 */
open class ConcatenatingLogFormatter: LogFormatter
{
    /** The `LogFormatter`s whose output will be concatenated. */
    open let formatters: [LogFormatter]

    /**
     Initializes a new `ConcatenatingLogFormatter` instance.
     
     - parameter formatters: The `LogFormatter`s whose output will be
     concatenated.
     */
    public init(formatters: [LogFormatter])
    {
        self.formatters = formatters
    }

    /**
     Formats the `LogEntry` by passing it to each of the receiver's
     `LogFormatter`s and concatenating the output.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result, or `nil` if none of the receiver's
     `formatters` returned a non-`nil` value when formatting `entry`.
     */
    open func format(_ entry: LogEntry)
        -> String?
    {
        let formatted = formatters.flatMap{ $0.format(entry) }

        guard formatted.count > 0 else {
            return nil
        }

        return formatted.joined(separator: "")
    }
}

