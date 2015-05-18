//
//  Log.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Each `LogRecorder` instance is responsible recording formatted log strings
to an underlying log data store.
*/
public protocol LogRecorder
{
    /**
    The name of the `LogRecorder`, which must be unique.
    */
    var name: String { get }

    /**
    The `LogFormatter`s that should be used to create a formatted log string
    for passing to the receiver's `recordFormattedString(_: forLogEntry:)`
    function. The formatters will be called sequentially and given an
    opportunity to return a formatted string for each log entry. The first
    non-`nil` return value will be what gets recorded in the log.
    */
    var formatters: [LogFormatter] { get }

    /**
    Returns the GCD queue that will be used when executing tasks related to
    the receiver. Log formatting and recording will be performed using
    this queue. This is typically a serial queue because the underlying log
    implementation is usually single-threaded.
    */
    var queue: dispatch_queue_t { get }

    /**
    Called by the `LogReceptacle` to record the formatted log message.
    
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
    func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
}
