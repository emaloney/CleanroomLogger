//
//  LogReceptacle.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
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

    public let minimumSeverity: LogSeverity

    /**
    Constructs a new `LogReceptacle` that will use the specified configurations.

    When a `LogEntry` is passed to the receiver's `log()` function, logging
    will proceed using **all** `LogConfiguration`s having a `minimumSeverity`
    that's less or as severe as the passed-in `LogEntry`'s `severity` property.

    If no matching `LogConfiguration`s are found, then the log request is
    silently ignored.

    - parameter configuration: An array of `LogConfiguration` instances that 
                specify how the logging system will behave when messages
                are logged.
    */
    public init(configuration: [LogConfiguration])
    {
        let configs = configuration.flatMap{ $0.flatten() }

        self.minimumSeverity = configs.map{ $0.minimumSeverity }.reduce(.Error, combine: { $0 < $1 ? $0 : $1 })

        self.configuration = configs
    }

    /**
    This function accepts a `LogEntry` instance and attempts to record it
    to the underlying log storage facility.
    
    - parameter entry: The `LogEntry` being logged.
    */
    public func log(entry: LogEntry)
    {
        let matchingConfigs = configuration.filter{ entry.severity >= $0.minimumSeverity }

        // pass off to the asynchronous configurations first...
        let asyncConfigs = matchingConfigs.filter{ !$0.synchronousMode }
        asyncConfigs.forEach{ logEntry(entry, usingConfiguration: $0) }

        // ...then log using the synchronous configurations
        let syncConfigs = matchingConfigs.filter{ $0.synchronousMode }
        syncConfigs.forEach{ logEntry(entry, usingConfiguration: $0) }
    }

    private lazy var acceptQueue: dispatch_queue_t = dispatch_queue_create("LogReceptacle.acceptQueue", DISPATCH_QUEUE_SERIAL)

    private func logEntry(entry: LogEntry, usingConfiguration config: LogConfiguration)
    {
        let synchronous = config.synchronousMode
        let acceptDispatcher = dispatcherForQueue(acceptQueue, synchronous: synchronous)
        acceptDispatcher {
            if self.doesLogEntry(entry, passFilters: config.filters) {
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

    private func doesLogEntry(entry: LogEntry, passFilters filters: [LogFilter])
        -> Bool
    {
        for filter in filters {
            if !filter.shouldRecordLogEntry(entry) {
                return false
            }
        }
        return true
    }

    private func dispatcherForQueue(queue: dispatch_queue_t, synchronous: Bool) -> (dispatch_block_t) -> Void
    {
        let dispatcher: (dispatch_block_t) -> Void = { block in
            if synchronous {
                return dispatch_sync(queue, block)
            } else {
                return dispatch_async(queue, block)
            }
        }
        return dispatcher
    }
}
