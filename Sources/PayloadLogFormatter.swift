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
 */
public struct PayloadLogFormatter: LogFormatter
{
    /** The `LogFormatter` used by the receiver when encountering a `LogEntry`
     whose `payload` property contains a `.trace` value. */
    public let traceFormatter: LogFormatter

    /** The `LogFormatter` used by the receiver when encountering a `LogEntry`
     whose `payload` property contains a `.message` value. */
    public let messageFormatter: LogFormatter

    /** The `LogFormatter` used by the receiver when encountering a `LogEntry`
     whose `payload` property contains a `.value` value. */
    public let valueFormatter: LogFormatter

    /** 
     The initializer.
     */
    public init(traceFormatter: LogFormatter = PayloadTraceLogFormatter(),
                messageFormatter: LogFormatter = PayloadMessageLogFormatter(),
                valueFormatter: LogFormatter = PayloadValueLogFormatter())
    {
        self.traceFormatter = traceFormatter
        self.messageFormatter = messageFormatter
        self.valueFormatter = valueFormatter
    }

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `payload` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result, or `nil` if formatting was not possible
     for the given message.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        switch entry.payload {
        case .trace:    return traceFormatter.format(entry)
        case .message:  return messageFormatter.format(entry)
        case .value:    return valueFormatter.format(entry)
        }
    }
}
