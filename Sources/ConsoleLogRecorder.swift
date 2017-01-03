//
//  ConsoleLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Dispatch

/**
 The `ConsoleLogRecorder` logs messages by writing to the standard output
 stream of the running process.
 */
public final class ConsoleLogRecorder: LogRecorderBase
{
    /** `true` if the receiver is logging to `stdout` instead of using the
     `os_log()` function. */
    public let isUsingStdout: Bool

    private let recorder: LogRecorder
    
    /**
     Initializes a `StandardOutputLogRecorder` instance to use the specified
     `LogFormatter` implementation for formatting log messages.
     
     - parameter formatters: The `LogFormatter`s to use for formatting log
     messages recorded by the receiver.
     
     - parameter useStdoutOnly: If `true`, the `os_log()` function is not used
     even if available; instead, all log messages are sent to `stdout` using
     the `StandardOutputLogRecorder`.
     */
    public init(formatters: [LogFormatter], useStdoutOnly: Bool = false)
    {
        recorder = (useStdoutOnly ? nil : OSLogRecorder(formatters: formatters)) ?? StandardOutputLogRecorder(formatters: formatters)
        isUsingStdout = recorder is StandardOutputLogRecorder
        
        super.init(formatters: formatters, queue: recorder.queue)
    }
    
    /**
     Called to record the specified message to standard output.
     
     - note: This function is only called if one of the `formatters` associated
     with the receiver returned a non-`nil` string for the given `LogEntry`.
     
     - parameter message: The message to record.
     
     - parameter entry: The `LogEntry` for which `message` was created.
     
     - parameter currentQueue: The GCD queue on which the function is being
     executed.
     
     - parameter synchronousMode: If `true`, the receiver should record the log
     entry synchronously and flush any buffers before returning.
     */
    public override func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        recorder.record(message: message, for: entry, currentQueue: currentQueue, synchronousMode: synchronousMode)
    }
}

extension ConsoleLogRecorder
{
    /**
     Determines whether the `os_log()` function will be used given the runtime
     environment and the value of `useStdoutOnly`.
     
     - parameter useStdoutOnly: If `true`, the return value will always be
     `false`, indicating that `stdout` will be used instead of `os_log()`, 
     even if `os_log()` is available at runtime.
     
     - returns: `true` if and only if `os_log()` is available at runtime
     and `useStdoutOnly` is `false`.
     */
    public static func willUseOSLog(useStdoutOnly: Bool)
        -> Bool
    {
        return OSLogRecorder.isOSLogAvailable && !useStdoutOnly
    }
}
