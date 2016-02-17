//
//  ASLLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 4/1/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Dispatch
import CleanroomASL

/**
The `ASLLogRecorder` is an implemention of the `LogRecorder` protocol that
records log entries to the Apple System Log (ASL) facility.

Unless a `LogLevelTranslator` is specified during construction, the
`ASLLogRecorder` will record log messages using `ASL_LEVEL_WARNING`. This
is consistent with the behavior of `NSLog()`.
*/
public struct ASLLogRecorder: LogRecorder
{
    /** Defines the interface of a function that translates `LogSeverity`
    values into `ASLPriorityLevel` values. This function is used to determine
    the `ASLPriorityLevel` used for a given `LogEntry`. */
    public typealias LogLevelTranslator = (LogSeverity) -> ASLPriorityLevel

    /** The `LogFormatter`s to be used in conjunction with the receiver. */
    public let formatters: [LogFormatter]

    /** The `ASLClient` that will be used to perform logging. */
    public let client: ASLClient

    /** The GCD queue used by the receiver to record messages. */
    public var queue: dispatch_queue_t { return client.queue }

    /** The `LogLevelTranslator` function used by the receiver to convert
    `LogSeverity` values to `ASLPriorityLevel` values. If one was not
    explicitly provided at instantiation, a default implementation will
    be used. */
    public let logLevelTranslator: LogLevelTranslator

    /**
    Initializes an `ASLLogRecorder` instance to use the `DefaultLogFormatter`
    implementation for formatting log messages.
    
    Within ASL, log messages will be recorded at the `.Warning` priority
    level, which is consistent with the behavior of `NSLog()`.

    - parameter echoToStdErr: If `true`, ASL will also echo log messages to
                the calling process's `stderr` output stream.
    */
    public init(echoToStdErr: Bool = true)
    {
        self.client = ASLClient(useRawStdErr: echoToStdErr)
        self.formatters = [XcodeLogFormatter()]
        self.logLevelTranslator = { _ in return .Warning }
    }

    /**
     Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
     for formatting log messages.

     Within ASL, log messages will be recorded at the `.Warning` priority
     level, which is consistent with the behavior of `NSLog()`.

     - parameter formatter: A `LogFormatter` to use for formatting log entries
     to be recorded by the receiver. If the formatter returns `nil` for a given
     log entry, it is silently ignored and not recorded.

     - parameter echoToStdErr: If `true`, ASL will also echo log messages to
     the calling process's `stderr` output stream.
     */
    public init(formatter: LogFormatter, echoToStdErr: Bool = true)
    {
        self.client = ASLClient(useRawStdErr: echoToStdErr)
        self.formatters = [formatter]
        self.logLevelTranslator = { _ in return .Warning }
    }

    /**
     Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
     for formatting log messages.

     Within ASL, log messages will be recorded at the `.Warning` priority
     level, which is consistent with the behavior of `NSLog()`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter echoToStdErr: If `true`, ASL will also echo log messages to
     the `stderr` output stream of the running process.
     */
    public init(formatters: [LogFormatter], echoToStdErr: Bool = true)
    {
        self.client = ASLClient(useRawStdErr: echoToStdErr)
        self.formatters = formatters
        self.logLevelTranslator = { _ in return .Warning }
    }

    /**
     Initializes a new `ASLLogRecorder` instance to use the specified
     `LogFormatter` for formatting log entries.

     - parameter translator: A `LogLevelTranslator` function that is used to
     convert `LogSeverity` values to `ASLPriorityLevel` values.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter echoToStdErr: If `true`, ASL will also echo log messages to
     the calling process's `stderr` output stream.
     */
    public init(logLevelTranslator translator: LogLevelTranslator, formatters: [LogFormatter], echoToStdErr: Bool = true)
    {
        self.client = ASLClient(useRawStdErr: echoToStdErr)
        self.formatters = formatters
        self.logLevelTranslator = translator
    }

    /**
     Called to record the specified message to the Apple System Log.

     - note: This function is only called if one of the `formatters` associated
     with the receiver returned a non-`nil` string for the given `LogEntry`.

     - parameter message: The message to record.

     - parameter entry: The `LogEntry` for which `message` was created.

     - parameter currentQueue: The GCD queue on which the function is being
     executed.

     - parameter synchronousMode: If `true`, the receiver should record the log
     entry synchronously and flush any buffers before returning.
    */
    public func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
    {
        let msgObj = ASLMessageObject(priorityLevel: logLevelTranslator(entry.severity), message: message)
        client.log(msgObj, logSynchronously: synchronousMode, currentQueue: currentQueue)
    }
}

