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
    Called by the `LogReceptacle` to record the specified log string. Note that
    this is only called if one of the `formatters` associated with the receiver
    returned a non-`nil` string.
    
    :param:     str The log string to record.
    
    :param:     entry The `LogEntry` being recorded.
    */
    func recordFormattedString(str: String, forLogEntry entry: LogEntry)
}
