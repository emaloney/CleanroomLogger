//
//  PayloadMessageLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/6/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns the message content of a `LogEntry` whose
 `payload` is a `.message` value.
 */
public struct PayloadMessageLogFormatter: LogFormatter
{
    /**
     The initializer.
     */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `payload` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The message content, or `nil` if `entry` doesn't have a
     `payload` with a `.message` value.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        guard case .message(let content) = entry.payload else { return nil }

        return content
    }
}
