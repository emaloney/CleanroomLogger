//
//  LogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Defines an interface for specifying the configuration of the logging system.
*/
public protocol LogConfiguration
{
    /// The minimum `LogSeverity` supported by the configuration.
    var minimumSeverity: LogSeverity { get }

    /// The `LogFilter`s to use when deciding whether a given `LogEntry`
    /// should be passed along to the receiver's `recorders`. If any filter
    /// returns `false` from `shouldRecordLogEntry(_:)`, the `LogEntry` will
    /// be silently ignored when being processed for this configuration.
    var filters: [LogFilter]  { get }

    /// The `LogRecorder`s to use for recording any `LogEntry` that has
    /// passed the filtering process.
    var recorders: [LogRecorder]  { get }

    /// A flag indicating when synchronous mode should be used for the
    /// configuration. Synchronous mode is intended for use only when 
    /// debugging; it should not be used in production code.
    var synchronousMode: Bool  { get }

    /// For organizational purposes, a given `LogConfiguration` may in turn
    /// contain one or more additional `LogConfiguration`s. Note that these
    /// are handled as entirely separate entities; the receiver's state does
    /// not affect the behavior of the contained configurations in any way.
    var configurations: [LogConfiguration]? { get }
}

extension LogConfiguration
{
    /// The default implementation returns `nil`, indicating that the receiver
    /// containts no `LogConfiguration`s.
    public var configurations: [LogConfiguration]? {
        return nil
    }
}

extension LogConfiguration
{
    public func flatten()
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
