//
//  LogConfiguration.swift
//  Cleanroom
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Defines an interface for specifying the configuration of the logging system.
*/
public protocol LogConfiguration
{
    /** The minimum `LogSeverity` supported by the configuration. */
    var minimumSeverity: LogSeverity { get }

    /** The list of `LogFilter`s to be used. */
    var filters: [LogFilter]  { get }

    /** The list of `LogRecorder`s to be used. */
    var recorders: [LogRecorder]  { get }

    /** A flag indicating when synchronous mode should be used for the
    configuration. */
    var synchronousMode: Bool  { get }
}
