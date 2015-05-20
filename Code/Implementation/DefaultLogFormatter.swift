//
//  DefaultLogFormatter.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
The `DefaultLogFormatter` is a basic implementation of the `LogFormatter` 
protocol.

This implementation is used by default if no other log formatters are specified.
*/
public struct DefaultLogFormatter: LogFormatter
{
    public let includeTimestamp: Bool
    public let includeThreadID: Bool

    private static let timestampFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS zzz"
        return fmt
    }()

    /**
    Initializes the DefaultLogFormatter using the given settings.

    :param:     includeTimestamp If `true`, the log entry timestamp will be
                included in the formatted message.

    :param:     includeThreadID If `true`, an identifier for the calling thread
                will be included in the formatted message.
    */
    public init(includeTimestamp: Bool = false, includeThreadID: Bool = false)
    {
        self.includeTimestamp = includeTimestamp
        self.includeThreadID = includeThreadID
    }

    /**
    Returns a formatted representation of the given `LogEntry`.
    
    :param:         entry The `LogEntry` being formatted.

    :returns:       The formatted representation of `entry`. This particular
                    implementation will never return `nil`.
    */
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        let severity = DefaultLogFormatter.stringRepresentationOfSeverity(entry.severity)
        let caller = DefaultLogFormatter.stringRepresentationForCallingFile(entry.callingFilePath, line: entry.callingFileLine)
        let message = DefaultLogFormatter.stringRepresentationForPayload(entry)

        var timestamp: String?
        if includeTimestamp {
            timestamp = DefaultLogFormatter.stringRepresentationOfTimestamp(entry.timestamp)
        }

        var threadID: String?
        if includeThreadID {
            threadID = DefaultLogFormatter.stringRepresentationOfThreadID(entry.callingThreadID)
        }

        return DefaultLogFormatter.formatLogMessageWithSeverity(severity, caller: caller, message: message, timestamp: timestamp, threadID: threadID)
    }

    /**
    Returns the formatted log message given the string representation of the
    severity, caller and message associated with a given `LogEntry`.
    
    This implementation is used by the `DefaultLogFormatter` for creating
    the log messages that will be recorded.
    
    :param:     severity The string representation of the log entry's severity.
    
    :param:     caller The string representation of the caller's source file
                and line.
    
    :param:     message The log message.
    
    :param:     timestamp An optional timestamp string to include in the 
                message.

    :param:     threadID An optional thread ID to include in the message.

    :returns:   The formatted log message.
    */
    public static func formatLogMessageWithSeverity(severity: String, caller: String, message: String, timestamp: String?, threadID: String?)
        -> String
    {
        var fmt = ""
        if let timestamp = timestamp {
            fmt += "\(timestamp) | "
        }
        if let threadID = threadID {
            fmt += "\(threadID) | "
        }
        fmt += "\(severity) | \(caller) — \(message)"
        return fmt
    }

    /**
    Returns a string representation of a given `LogSeverity` value.
    
    This implementation is used by the `DefaultLogFormatter` for creating
    string representations for representing the `severity` value of
    `LogEntry` instances.
    
    :param:     severity The `LogSeverity` for which a string representation
                is desired.
    
    :returns:   A string representation of the `severity` value.
    */
    public static func stringRepresentationOfSeverity(severity: LogSeverity)
        -> String
    {
        var severityTag = severity.printableValueName.uppercaseString
        while count(severityTag.utf16) < 7 {
            severityTag = " " + severityTag
        }
        return severityTag
    }

    /**
    Returns a string representation for a calling file and line.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of a `LogEntry`'s `callingFilePath` and
    `callingFileLine` properties.

    :param:     filePath The full file path of the calling file.
    
    :param:     line The line number within the calling file.
    
    :returns:   The string representation of `filePath` and `line`.
    */
    public static func stringRepresentationForCallingFile(filePath: String, line: Int)
        -> String
    {
        let file = filePath.pathComponents.last ?? "(unknown)"

        return "\(file):\(line)"
    }

    /**
    Returns a string representation of an arbitrary optional value.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of `LogEntry` payloads.

    :param:     entry The `LogEntry` whose payload is desired in string form.
    
    :returns:   The string representation of `entry`'s payload.
    */
    public static func stringRepresentationForPayload(entry: LogEntry)
        -> String
    {
        switch entry.payload {
        case .Trace:                return entry.callingFunction
        case .Message(let msg):     return msg
        case .Value(let value):     return stringRepresentationForValue(value)
        }
    }

    /**
    Returns a string representation of an arbitrary optional value.

    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of `LogEntry` instances containing `.Value` payloads.

    :param:     value The value for which a string representation is desired.
    
    :returns:   If value is `nil`, the string "`(nil)`" is returned; otherwise,
                the return value of `stringRepresentationForValue(Any)` is
                returned.
    */
    public static func stringRepresentationForValue(value: Any?)
        -> String
    {
        if let value = value {
            return stringRepresentationForValue(value)
        } else {
            return "(nil)"
        }
    }

    /**
    Returns a string representation of an arbitrary value.
    
    This implementation is used by the `DefaultLogFormatter` for creating
    string representations of `LogEntry` instances containing `.Value` payloads.

    :param:     value The value for which a string representation is desired.
    
    :returns:   A string representation of `value`.
    */
    public static func stringRepresentationForValue(value: Any)
        -> String
    {
        let type = reflect(value).summary

        let desc: String
        if let debugValue = value as? DebugPrintable {
            desc = debugValue.debugDescription
        }
        else if let printValue = value as? Printable {
            desc = printValue.description
        }
        else if let objcValue = value as? NSObject {
            desc = objcValue.description
        }
        else {
            desc = "(no description)"
        }

        return "<\(type): \(desc)>"
    }

    public static func stringRepresentationOfTimestamp(timestamp: NSDate)
        -> String
    {
        return timestampFormatter.stringFromDate(timestamp)
    }

    public static func stringRepresentationOfThreadID(threadID: UInt64)
        -> String
    {
        return NSString(format: "%08X", threadID) as String
    }
}
