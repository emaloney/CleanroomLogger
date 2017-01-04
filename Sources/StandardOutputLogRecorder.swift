//
//  StandardOutputLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/30/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Darwin.C.stdio
import Dispatch

/**
 The `StandardOutputLogRecorder` is an `OutputStreamLogRecorder` that writes 
 log messages to the standard output stream ("`stdout`") of the running
 process.
*/
open class StandardOutputLogRecorder: OutputStreamLogRecorder
{
    /**
     Initializes a `StandardOutputLogRecorder` instance to use the specified
     `LogFormatter`s for formatting log messages.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries that will be recorded by the receiver.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
    */
    public init(formatters: [LogFormatter], queue: DispatchQueue? = nil)
    {
        super.init(stream: stdout, formatters: formatters, queue: queue)
    }
}

