//
//  LogRecorderBase.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/12/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Dispatch

/**
 A partial implementation of the `LogRecorder` protocol.
 */
public class LogRecorderBase: LogRecorder
{
    /** The `LogFormatter`s that will be used to format messages for the
     `LogEntry`s to be logged. */
    public let formatters: [LogFormatter]

    /** The GCD queue that should be used for logging actions related to the
     receiver. */
    public let queue: DispatchQueue

    /**
     Initialize a new `LogRecorderBase` instance.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.
     */
    public init(formatters: [LogFormatter])
    {
        self.formatters = formatters
        self.queue = DispatchQueue(label: "\(self.dynamicType)", attributes: [])
    }

    /**
     This implementation, which does nothing, is present to satisfy the
     `LogRecorder` protocol. Subclasses must override this function to provide
     actual log recording functionality.

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
    }
}
