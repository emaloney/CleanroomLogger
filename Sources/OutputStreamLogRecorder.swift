//
//  OutputStreamLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Dispatch
import Darwin.C.stdio

/**
 The `OutputStreamLogRecorder` logs messages by writing to the standard
 output stream of the running process.
 */
open class OutputStreamLogRecorder: LogRecorderBase
{
    private let stream: UnsafeMutablePointer<FILE>
    private let newlines: [Character] = ["\n", "\r"]

    /**
     Initializes a `StandardOutputLogRecorder` instance to use the specified
     `LogFormatter` implementation for formatting log messages.

     - parameter stream: A standard C file handle to use as the output stream.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries that will be recorded by the receiver.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public init(stream: UnsafeMutablePointer<FILE>, formatters: [LogFormatter], queue: DispatchQueue? = nil)
    {
        self.stream = stream

        super.init(formatters: formatters, queue: queue)
    }

    /**
     Called to record the specified message to standard output.

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
        var addNewline = true
        let chars = message.characters
        if chars.count > 0 {
            let lastChar = chars[chars.index(before: chars.endIndex)]
            addNewline = !newlines.contains(lastChar)
        }

        fputs(message, stream)

        if addNewline {
            fputc(0x0A, stream)
        }

        if synchronousMode {
            fflush(stream)
        }
    }
}
