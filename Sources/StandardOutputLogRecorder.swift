//
//  StandardOutputLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/30/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Dispatch

/**
The `StandardOutputLogRecorder` logs messages by writing to the standard output
stream of the running process.
*/
public class StandardOutputLogRecorder: LogRecorderBase
{
    /**
    Initializes a `StandardOutputLogRecorder` instance to use the
    `XcodeLogFormatter` implementation for formatting log messages.
    */
    public init()
    {
        super.init(formatters: [XcodeLogFormatter()])
    }

    /**
     Initializes a `StandardOutputLogRecorder` instance to use the specified
     `LogFormatter` implementation for formatting log messages.

    - parameter formatter: The `LogFormatter` to use for formatting log messages
                recorded by the receiver.
    */
    public init(formatter: LogFormatter)
    {
        super.init(formatters: [formatter])
    }

    /**
     Initializes a `StandardOutputLogRecorder` instance to use the specified
     `LogFormatter` implementation for formatting log messages.

    - parameter formatters: The `LogFormatter`s to use for formatting log
                messages recorded by the receiver.
    */
    public override init(formatters: [LogFormatter])
    {
        super.init(formatters: formatters)
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
        print(message)
    }
}

