//
//  LogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 Defines an interface for specifying the configuration of the logging system.
*/
public protocol LogConfiguration
{
    /** The minimum `LogSeverity` supported by the configuration. */
    var minimumSeverity: LogSeverity { get }

    /** The `LogFilter`s to use when deciding whether a given `LogEntry` should
     be passed along to the receiver's `recorders`. If any filter returns
     `false` from `shouldRecordLogEntry(_:)`, the `LogEntry` will be silently
     ignored when being processed for this `LogConfiguration`. */
    var filters: [LogFilter]  { get }

    /** The `LogRecorder`s to use for recording any `LogEntry` that has passed
     the filtering process. */
    var recorders: [LogRecorder]  { get }

    /** A flag indicating whether synchronous mode will be used when passing
     `LogEntry` instances to the receiver's `recorders`. Synchronous mode is
     helpful while debugging, as it ensures that logs are always up-to-date
     when debug breakpoints are hit. However, synchronous mode can have a
     negative influence on performance and is therefore not recommended for use 
     in production code. */
    var synchronousMode: Bool  { get }

    /** For organizational purposes, a given `LogConfiguration` may in turn
     contain one or more additional `LogConfiguration`s. Each contained 
     `LogConfiguration` is an entirely separate entity; children do not inherit
     any state from parent containers. */
    var configurations: [LogConfiguration]? { get }
}

extension LogConfiguration
{
    /** A default implementation returning `nil`, indicating that the receiver
     contains no `LogConfiguration`s. */
    public var configurations: [LogConfiguration]? {
        return nil
    }
}

extension LogConfiguration
{
    internal func flatten()
        -> [LogConfiguration]
    {
        var configs: [LogConfiguration] = []

        if recorders.count > 0 {
            configs += [self as LogConfiguration]
        }

        if let innerConfigs = configurations {
            configs += innerConfigs.flatMap{ $0.flatten() }
        }

        return configs
    }
}
