//
//  BasicLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/5/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 In case the name didn't give it away, the `BasicLogConfiguration` class 
 provides a basic implementation of the `LogConfiguration` protocol.
 */
open class BasicLogConfiguration: LogConfiguration
{
    /** The minimum `LogSeverity` supported by the configuration. */
    open let minimumSeverity: LogSeverity

    /** The `LogFilter`s to use when deciding whether a given `LogEntry` should
     be passed along to the receiver's `recorders`. If any filter returns
     `false` from `shouldRecordLogEntry(_:)`, the `LogEntry` will be silently
     ignored when being processed for this `LogConfiguration`. */
    open let filters: [LogFilter]

    /** The `LogRecorder`s to use for recording any `LogEntry` that has passed
     the filtering process. */
    open let recorders: [LogRecorder]

    /** A flag indicating whether synchronous mode will be used when passing
     `LogEntry` instances to the receiver's `recorders`. Synchronous mode is
     helpful while debugging, as it ensures that logs are always up-to-date
     when debug breakpoints are hit. However, synchronous mode can have a
     negative influence on performance and is therefore not recommended for use 
     in production code. */
    open let synchronousMode: Bool

    /** For organizational purposes, a given `LogConfiguration` may in turn
     contain one or more additional `LogConfiguration`s. Each contained
     `LogConfiguration` is an entirely separate entity; children do not inherit
     any state from parent containers. */
    open let configurations: [LogConfiguration]?

    /**
     Initializes a new `BasicLogConfiguration` instance.

     - parameter minimumSeverity: The minimum `LogSeverity` supported by the
     configuration. Log entries having a `severity` less than `minimumSeverity`
     will not be passed to the receiver's `recorders`.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along to the receiver's `LogRecorder`s.

     - parameter recorders: The `LogRecorder`s to use for recording any 
     `LogEntry` that has passed the filtering process.

     - parameter synchronousMode: Determines whether synchronous mode will be
     used when passing `LogEntry` instances to the receiver's `recorders`.
     Synchronous mode is helpful while debugging, as it ensures that logs are
     always up-to-date when debug breakpoints are hit. However, synchronous 
     mode can have a negative influence on performance and is therefore not
     recommended for use in production code.
     
     - parameter configurations: Optional `LogConfiguration`s. For
     organizational purposes, a given `LogConfiguration` may in turn contain
     one or more additional `LogConfiguration`s. Note that these are handled
     as entirely separate entities; the receiver's state does not affect the
     behavior of the contained configurations in any way.
    */
    public init(minimumSeverity: LogSeverity = .info, filters: [LogFilter] = [], recorders: [LogRecorder] = [], synchronousMode: Bool = false, configurations: [LogConfiguration]? = nil)
    {
        self.minimumSeverity = minimumSeverity
        self.filters = filters
        self.synchronousMode = synchronousMode
        self.recorders = recorders
        self.configurations = configurations
    }
}
