//
//  LogReceptacle.swift
//  Cleanroom
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`LogReceptacle`s provide the low-level interface for accepting log messages.

Although you could use a `LogReceptacle` directly to perform all logging
functions, the `Log` implementation provides a higher-level interface that's
more convenient to use within your code.
*/
public final class LogReceptacle
{
    /** The `LogConfiguration` instances used to construct the receiver. */
    public let configuration: [LogConfiguration]

    /**
    Constructs a new `LogReceptacle` that will use the specified configurations.

    When a `LogEntry` is passed to the receiver's `log()` function, the
    `LogConfiguration`s passed to this initializer will be evaluated in order
    until the first one is found where the entry's `severity` property is as
    severe or more severe than the `minimumSeverity` of the `LogConfiguration`.
    
    The first `LogConfiguration` matching that criteria is then used to perform
    logging. If no matching `LogConfiguration` exists, then the log request
    is silently ignored.
    
    This mechanism can be used to allow different `LogConfiguration`s to be
    used for each individual `LogSeverity` (or for a range of contiguous
    `LogSeverity` values).

    :param:     configuration An array of `LogConfiguration` instances that 
                specify how the logging system will behave when messages
                are added.
    */
    public init(configuration: [LogConfiguration])
    {
        self.configuration = configuration
    }

    /**
    This function accepts a `LogEntry` instance and attempts to record it
    to the underlying log storage facility.
    
    :param:     entry The `LogEntry` being logged.
    */
    public func log(entry: LogEntry)
    {
        if let config = configurationForLogEntry(entry) {
            let synchronous = config.synchronousMode
            let acceptDispatcher = dispatcherForQueue(acceptQueue, synchronous: synchronous)
            acceptDispatcher {
                if self.logEntry(entry, passesFilters: config.filters) {
                    for recorder in config.recorders {
                        let recordDispatcher = self.dispatcherForQueue(recorder.queue, synchronous: synchronous)
                        recordDispatcher {
                            for formatter in recorder.formatters {
                                if let formatted = formatter.formatLogEntry(entry) {
                                    recorder.recordFormattedMessage(formatted, forLogEntry: entry, currentQueue: recorder.queue, synchronousMode: synchronous)
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private lazy var acceptQueue: dispatch_queue_t = dispatch_queue_create("LogReceptacle.acceptQueue", DISPATCH_QUEUE_SERIAL)

    private func configurationForLogEntry(entry: LogEntry)
        -> LogConfiguration?
    {
        for config in configuration {
            if entry.severity >= config.minimumSeverity {
                return config
            }
        }
        return nil
    }

    private func logEntry(entry: LogEntry, passesFilters filters: [LogFilter])
        -> Bool
    {
        for filter in filters {
            if !filter.shouldRecordLogEntry(entry) {
                return false
            }
        }
        return true
    }

    private func dispatcherForQueue(queue: dispatch_queue_t, synchronous: Bool)(block: dispatch_block_t)
    {
        if synchronous {
            return dispatch_sync(queue, block)
        } else {
            return dispatch_async(queue, block)
        }
    }
}
