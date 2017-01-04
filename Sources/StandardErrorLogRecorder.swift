//
//  StandardErrorLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Darwin.C.stdio
import Dispatch

/**
 The `StandardErrorLogRecorder` is an `OutputStreamLogRecorder` that writes
 log messages to the standard error stream ("`stderr`") of the running
 process.
 */
open class StandardErrorLogRecorder: OutputStreamLogRecorder
{
    /**
     Initializes a `StandardErrorLogRecorder` instance to use the specified
     `LogFormatter`s for formatting log messages.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public init(formatters: [LogFormatter], queue: DispatchQueue? = nil)
    {
        super.init(stream: stderr, formatters: formatters, queue: queue)
    }
}

