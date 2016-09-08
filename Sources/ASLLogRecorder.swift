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
    public var queue: DispatchQueue { return client.queue }

    /** The `LogLevelTranslator` function used by the receiver to convert
     `LogSeverity` values to `ASLPriorityLevel` values. If one was not
     explicitly provided at instantiation, a default implementation will
     be used. */
    public let logLevelTranslator: LogLevelTranslator

    private let addTraceAttributes: Bool

    /**
     Initializes an `ASLLogRecorder` instance to use the `DefaultLogFormatter`
     implementation for formatting log messages.

     Within ASL, log messages will be recorded at the `.warning` priority
     level, which is consistent with the behavior of `NSLog()`.

     - parameter echoToStdErr: If `true`, ASL will also echo log messages to
     the calling process's `stderr` output stream.

     - parameter addTraceAttributes: If `true`, additional program trace
     attributes will be included in each message logged to ASL. This will
     include the filesystem path of the source code file, the source code
     line of the call site, and the stack frame representing the caller.
     You probably don't want this included in production code.
     */
    public init(echoToStdErr: Bool = true, addTraceAttributes: Bool = false)
    {
        self.client = ASLClient(facility: "com.gilt.CleanroomLogger", useRawStdErr: echoToStdErr)
        self.formatters = [XcodeLogFormatter()]
        self.logLevelTranslator = { _ in return .warning }
        self.addTraceAttributes = addTraceAttributes
    }

    /**
     Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
     for formatting log messages.

     Within ASL, log messages will be recorded at the `.warning` priority
     level, which is consistent with the behavior of `NSLog()`.

     - parameter formatter: A `LogFormatter` to use for formatting log entries
     to be recorded by the receiver. If the formatter returns `nil` for a given
     log entry, it is silently ignored and not recorded.

     - parameter echoToStdErr: If `true`, ASL will also echo log messages to
     the calling process's `stderr` output stream.

     - parameter addTraceAttributes: If `true`, additional program trace
     attributes will be included in each message logged to ASL. This will
     include the filesystem path of the source code file, the source code
     line of the call site, and the stack frame representing the caller.
     You probably don't want this included in production code.
     */
    public init(formatter: LogFormatter, echoToStdErr: Bool = true, addTraceAttributes: Bool = false)
    {
        self.client = ASLClient(facility: "com.gilt.CleanroomLogger", useRawStdErr: echoToStdErr)
        self.formatters = [formatter]
        self.logLevelTranslator = { _ in return .warning }
        self.addTraceAttributes = addTraceAttributes
    }

    /**
     Initializes an `ASLLogRecorder` instance to use the specified `LogFormatter`
     for formatting log messages.

     Within ASL, log messages will be recorded at the `.warning` priority
     level, which is consistent with the behavior of `NSLog()`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter echoToStdErr: If `true`, ASL will also echo log messages to
     the `stderr` output stream of the running process.

     - parameter addTraceAttributes: If `true`, additional program trace
     attributes will be included in each message logged to ASL. This will
     include the filesystem path of the source code file, the source code
     line of the call site, and the stack frame representing the caller.
     You probably don't want this included in production code.
     */
    public init(formatters: [LogFormatter], echoToStdErr: Bool = true, addTraceAttributes: Bool = false)
    {
        self.client = ASLClient(facility: "com.gilt.CleanroomLogger", useRawStdErr: echoToStdErr)
        self.formatters = formatters
        self.logLevelTranslator = { _ in return .warning }
        self.addTraceAttributes = addTraceAttributes
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
     
     - parameter addTraceAttributes: If `true`, additional program trace
     attributes will be included in each message logged to ASL. This will
     include the filesystem path of the source code file, the source code
     line of the call site, and the stack frame representing the caller.
     You probably don't want this included in production code.
     */
    public init(logLevelTranslator translator: @escaping LogLevelTranslator, formatters: [LogFormatter], echoToStdErr: Bool = true, addTraceAttributes: Bool = false)
    {
        self.client = ASLClient(facility: "com.gilt.CleanroomLogger", useRawStdErr: echoToStdErr)
        self.formatters = formatters
        self.logLevelTranslator = translator
        self.addTraceAttributes = addTraceAttributes
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
    public func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        autoreleasepool {

            let msgObj = ASLMessageObject(priorityLevel: logLevelTranslator(entry.severity), message: message)

            msgObj["CleanroomLogger.severity"] = String(entry.severity.rawValue)
            msgObj["CleanroomLogger.threadID"] = String(entry.callingThreadID)

            if addTraceAttributes {
                msgObj["CleanroomLogger.sourceFilePath"] = entry.callingFilePath
                msgObj["CleanroomLogger.sourceFileLine"] = String(entry.callingFileLine)
                msgObj["CleanroomLogger.callingStackFrame"] = entry.callingStackFrame
            }

            client.log(msgObj, logSynchronously: synchronousMode, currentQueue: currentQueue)
        }
    }
}
