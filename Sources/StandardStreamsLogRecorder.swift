//
//  StandardStreamsLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Darwin.C.stdio
import Dispatch

/**
 The `StandardStreamsLogRecorder` is a `LogRecorder` that writes log messages
 to either the standard output stream ("`stdout`") or the standard error stream
 ("`stderr`") of the running process.
 
 Messages are directed to the appropriate stream depending on the `severity`
 property of the `LogEntry` being recorded.
 
 Messages having a severity of `.verbose`, `.debug` and `.info` will be
 directed to `stdout`, while those with a severity of `.warning` and `.error`
 are directed to `stderr`.
 */
open class StandardStreamsLogRecorder: LogRecorderBase
{
    private let stdout: StandardOutputLogRecorder
    private let stderr: StandardErrorLogRecorder

    /**
     Initializes a `StandardStreamsLogRecorder` instance to use the specified
     `LogFormatter`s for formatting log messages.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries that will be recorded by the receiver.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public override init(formatters: [LogFormatter], queue: DispatchQueue? = nil)
    {
        let q = queue != nil ? queue! : DispatchQueue(label: String(describing: type(of: self)), attributes: [])

        stdout = StandardOutputLogRecorder(formatters: formatters, queue: q)
        stderr = StandardErrorLogRecorder(formatters: formatters, queue: q)

        super.init(formatters: formatters, queue: q)
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

     - parameter synchronousMode: If `true`, the recording is being done in
     synchronous mode, and the recorder should act accordingly.
     */
    open override func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        if entry.severity <= .info {
            stdout.record(message: message, for: entry, currentQueue: currentQueue, synchronousMode: synchronousMode)
        } else {
            stderr.record(message: message, for: entry, currentQueue: currentQueue, synchronousMode: synchronousMode)
        }
    }
}
