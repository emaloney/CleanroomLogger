//
//  ASLLogRecorder.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 4/1/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation
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

    /** The default value used when a `name` is not specified during
    instantiation of `ASLLogRecorder`s. */
    public static let DefaultName = "CleanroomLogger.ASLLogRecorder"

    /** The name of the `ASLLogRecorder`. */
    public let name: String

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

    :param:     name The name of the log recorder, which must be unique.
                Defaults to `ASLLogRecorder.DefaultName` if the parameter
                is not specified.
    */
    public init(name: String = ASLLogRecorder.DefaultName)
    {
        self.client = ASLClient()
        self.name = name
        self.formatters = [DefaultLogFormatter()]
        self.logLevelTranslator = { _ in return .Warning }
    }

    /**
    Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
    for formatting log messages.

    Within ASL, log messages will be recorded at the `.Warning` priority
    level, which is consistent with the behavior of `NSLog()`.

    :param:     formatter The `LogFormatter` to use for formatting log messages
                recorded by the receiver.

    :param:     name The name of the log recorder, which must be unique. 
                Defaults to `ASLLogRecorder.DefaultName` if the parameter
                is not specified.
    */
    public init(formatter: LogFormatter, name: String = ASLLogRecorder.DefaultName)
    {
        self.client = ASLClient()
        self.name = name
        self.formatters = [formatter]
        self.logLevelTranslator = { _ in return .Warning }
    }

    /**
    Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
    for formatting log messages.
    
    Within ASL, log messages will be recorded at the `.Warning` priority
    level, which is consistent with the behavior of `NSLog()`.

    :param:     formatters An array of `LogFormatter`s to use for formatting log
                messages recorded by the receiver. Each formatter will be
                consulted in sequence, and the formatted string returned by the
                first formatter to yield a non-`nil` value will be recorded.

    :param:     name The name of the log recorder, which must be unique. 
                Defaults to `ASLLogRecorder.DefaultName` if the parameter 
                is not specified.
    */
    public init(formatters: [LogFormatter], name: String = ASLLogRecorder.DefaultName)
    {
        self.client = ASLClient()
        self.name = name
        self.formatters = formatters
        self.logLevelTranslator = { _ in return .Warning }
    }

    /**
    Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
    for formatting log messages.

    :param:     translator A `LogLevelTranslator` function that is used to
                convert `LogSeverity` values to `ASLPriorityLevel` values.

    :param:     formatters An array of `LogFormatter`s to use for formatting log
                messages recorded by the receiver. Each formatter will be
                consulted in sequence, and the formatted string returned by the
                first formatter to yield a non-`nil` value will be recorded.

    :param:     name The name of the log recorder, which must be unique. 
                Defaults to `ASLLogRecorder.DefaultName` if the parameter 
                is not specified.
    */
    public init(logLevelTranslator translator: LogLevelTranslator, formatters: [LogFormatter], name: String = ASLLogRecorder.DefaultName)
    {
        self.client = ASLClient()
        self.name = name
        self.formatters = formatters
        self.logLevelTranslator = translator
    }

    /**
    Called to record the specified message to the Apple System Log.

    **Note:** This function is only called if one of the `formatters` 
    associated with the receiver returned a non-`nil` string.
    
    :param:     message The message to record.

    :param:     entry The `LogEntry` for which `message` was created.

    :param:     currentQueue The GCD queue on which the function is being 
                executed.

    :param:     synchronousMode If `true`, the receiver should record the
                log entry synchronously. Synchronous mode is used during
                debugging to help ensure that logs reflect the latest state
                when debug breakpoints are hit. It is not recommended for
                production code.
    */
    public func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
    {
        let msgObj = ASLMessageObject(priorityLevel: logLevelTranslator(entry.severity), message: message)
        client.log(msgObj, logSynchronously: synchronousMode, currentQueue: currentQueue)
    }
}

