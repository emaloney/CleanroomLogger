//
//  BasicLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/5/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`BasicLogConfiguration` is a basic implementation of the `LogConfiguration`
protocol.
*/
public class BasicLogConfiguration: LogConfiguration
{
    /// The minimum `LogSeverity` supported by the configuration.
    public let minimumSeverity: LogSeverity

    /// The `LogFilter`s to use when deciding whether a given `LogEntry`
    /// should be passed along to the receiver's `recorders`. If any filter
    /// returns `false` from `shouldRecordLogEntry(_:)`, the `LogEntry` will
    /// be silently ignored when being processed for this configuration.
    public let filters: [LogFilter]

    /// The `LogRecorder`s to use for recording any `LogEntry` that has
    /// passed the filtering process.
    public let recorders: [LogRecorder]

    /// A flag indicating when synchronous mode should be used for the
    /// configuration. Synchronous mode is intended for use only when
    /// debugging; it should not be used in production code.
    public let synchronousMode: Bool

    /// For organizational purposes, a given `LogConfiguration` may in turn
    /// contain one or more additional `LogConfiguration`s. Note that these
    /// are handled as entirely separate entities; the receiver's state does
    /// not affect the behavior of the contained configurations in any way.
    public let configurations: [LogConfiguration]?

    /**
     Constructs a new `BasicLogConfiguration` instance.

     - parameter minimumSeverity: The minimum `LogSeverity` supported by the
     configuration.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along to the receiver's `LogRecorder`s.

     - parameter recorders: The `LogRecorder`s to use for recording any 
     `LogEntry` that has passed the filtering process.

     - parameter synchronousMode: Determines whether synchronous mode logging
     will be used. **Use of synchronous mode is not recommended in production
     code**; it is provided for use during debugging, to help ensure that
     messages send prior to hitting a breakpoint will appear in the console
     when the breakpoint is hit.

     - parameter configurations: Optional `LogConfiguration`s. For
     organizational purposes, a given `LogConfiguration` may in turn contain
     one or more additional `LogConfiguration`s. Note that these are handled
     as entirely separate entities; the receiver's state does not affect the
     behavior of the contained configurations in any way.
    */
    public init(minimumSeverity: LogSeverity = .Info, filters: [LogFilter] = [], recorders: [LogRecorder] = [], synchronousMode: Bool = false, configurations: [LogConfiguration]? = nil)
    {
        self.minimumSeverity = minimumSeverity
        self.filters = filters
        self.synchronousMode = synchronousMode
        self.recorders = recorders
        self.configurations = configurations
    }
}
