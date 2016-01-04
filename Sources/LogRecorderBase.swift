//
//  LogRecorderBase.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/12/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
A partial implementation of the `LogRecorder` protocol.

Note that this implementation provides no mechanism for log file rotation
or log pruning. It is the responsibility of the developer to keep the log
file at a reasonable size.
*/
public class LogRecorderBase: LogRecorder
{
    /// The `LogFormatter`s that will be used to format messages for
    /// the `LogEntry`s to be logged.
    public let formatters: [LogFormatter]

    /// The GCD queue that should be used for logging actions related to
    /// the receiver.
    public let queue: dispatch_queue_t

    /**
    Initialize a new `LogRecorderBase` instance to use the given parameters.

    - parameter formatters: The `LogFormatter`s to use for the recorder.
    */
    public init(formatters: [LogFormatter] = [XcodeLogFormatter()])
    {
        self.formatters = formatters
        self.queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    }

    /**
    This implementation does nothing. Subclasses must override this function
    to provide actual log recording functionality.

    **Note:** This function is only called if one of the `formatters` 
    associated with the receiver returned a non-`nil` string.
    
    - parameter message: The message to record.

    - parameter entry: The `LogEntry` for which `message` was created.

    - parameter currentQueue: The GCD queue on which the function is being
                executed.

    - parameter synchronousMode: If `true`, the receiver should record the
                log entry synchronously. Synchronous mode is used during
                debugging to help ensure that logs reflect the latest state
                when debug breakpoints are hit. It is not recommended for
                production code.
    */
    public func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)
    {
    }
}

