//
//  LogReceptacle.swift
//  Cleanroom
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

/**
`LogReceptacle`s provide the low-level interface for accepting log messages.

Although you could use a `LogReceptacle` directly to perform all logging
functions, the `Log` implementation provides a higher-level interface that's
more convenient to use within your code.
*/
public final class LogReceptacle
{
    /// The `LogConfiguration` instances used to construct the receiver.
    public let configuration: [LogConfiguration]

    private lazy var acceptQueue: dispatch_queue_t = dispatch_queue_create("LogReceptacle.acceptQueue", DISPATCH_QUEUE_SERIAL)
    private let criticalSection = CriticalSection() // for protecting access to recorderNamesToQueues
    private var recorderNamesToQueues: [String: dispatch_queue_t] = [:]

    /**
    Constructs a new `LogReceptacle` that will use the specified configuration.

    :param:     configuration An array of `LogConfiguration` instances that 
                specify how the logging system will behave when messages
                are added.
    */
    public init(configuration: [LogConfiguration])
    {
        self.configuration = configuration
    }

    private func configurationForLogEntry(entry: LogEntry)
        -> LogConfiguration?
    {
        for config in configuration {
            if entry.severity.compare(.AsOrMoreSevereThan, against: config.severity) {
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

    private func queueForRecorder(recorder: LogRecorder)
        -> dispatch_queue_t
    {
        var queue: dispatch_queue_t?
        criticalSection.execute {
            queue = self.recorderNamesToQueues[recorder.name]
            if queue == nil {
                queue = dispatch_queue_create("LogRecorder.\(recorder.name)", DISPATCH_QUEUE_SERIAL)
                self.recorderNamesToQueues[recorder.name] = queue!
            }
        }
        return queue!
    }

    private func dispatcherForQueue(queue: dispatch_queue_t, synchronous: Bool)(block: dispatch_block_t)
    {
        if synchronous {
            return dispatch_sync(queue, block)
        } else {
            return dispatch_async(queue, block)
        }
    }

    public func log(entry: LogEntry)
    {
        if let config = configurationForLogEntry(entry) {
            let synchronous = config.synchronousMode
            let acceptDispatcher = dispatcherForQueue(acceptQueue, synchronous: synchronous)
            acceptDispatcher {
                if self.logEntry(entry, passesFilters: config.filters) {
                    for recorder in config.recorders {
                        // each recorder also formats and records independently and
                        // potentially asynchronously, but using a single-threaded
                        // serial queue
                        let queue = self.queueForRecorder(recorder)
                        let recordDispatcher = self.dispatcherForQueue(queue, synchronous: synchronous)
                        recordDispatcher {
                            for formatter in recorder.formatters {
                                if let formatted = formatter.formatLogEntry(entry) {
                                    recorder.recordFormattedString(formatted, forLogEntry: entry)
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
