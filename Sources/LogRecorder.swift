//
//  LogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Dispatch

/**
 Each `LogRecorder` instance is responsible recording formatted log messages
 (along with their accompanying `LogEntry` instances) to an underlying log
 facility or data store.
 */
public protocol LogRecorder
{
    /**
     The `LogFormatter`s that should be used to create a formatted log string
     for passing to the receiver's `recordFormattedString()` function. 
     Formatters are consulted sequentially and given an opportunity to return 
     a formatted string for each `LogEntry`. The first non-`nil` return value
     is sent to the log for recording. Typically, an implementation of this
     protocol would not hard-code the `LogFormatter`s it uses, but would instead
     provide a constructor that accepts an array of `LogFormatter`s, which it
     will subsequently return from this property.
     */
    var formatters: [LogFormatter] { get }

    /**
     Returns the GCD queue that will be used when executing tasks related to
     the receiver. Log formatting and recording will be performed using
     this queue. A serial queue is typically used, such as when the underlying
     log facility is inherently single-threaded and/or proper message ordering
     wouldn't be ensured otherwise. However, a concurrent queue may also be
     used, and might be appropriate when logging to databases or network
     endpoints.
     */
    var queue: DispatchQueue { get }

    /**
     Called by the `LogReceptacle` to record the formatted log message.

     - note: This function is only called if one of the `formatters` associated
     with the receiver returned a non-`nil` string for the given `LogEntry`.

     - parameter message: The message to record.

     - parameter entry: The `LogEntry` for which `message` was created.

     - parameter currentQueue: The GCD queue on which the function is being
     executed.

     - parameter synchronousMode: If `true`, the recording is being done in
     synchronous mode, and the recorder should act accordingly.
    */
    func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
}
