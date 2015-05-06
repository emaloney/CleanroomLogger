//
//  DefaultLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/5/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`DefaultLogConfiguration` is the implementation of the `LogConfiguration`
protocol used by default if no other is provided.

The `DefaultLogConfiguration` uses the `ASLLogRecorder` to write to the Apple
System Log as well as the `stderr` console.

Additional optional `LogRecorders` may be specified to record messages to
other arbitrary types of data stores, such as files or HTTP endpoints.
*/
public struct DefaultLogConfiguration: LogConfiguration
{
    /** The minimum `LogSeverity` supported by the configuration. */
    public let minimumSeverity: LogSeverity

    /** The list of `LogFilter`s to be used for filtering log messages. */
    public let filters: [LogFilter]

    /** The list of `LogRecorder`s to be used for recording messages to the 
    underlying logging facility. */
    public let recorders: [LogRecorder]

    /** A flag indicating when synchronous mode should be used for the
    configuration. */
    public let synchronousMode: Bool

    /**
    A `DefaultLogConfiguration` that uses the `ASLLogRecorder` for logging
    messages to the Apple System Log and the application's `stderr` output
    stream.

    :param:     minimumSeverity The minimum `LogSeverity` supported by the
                configuration.
    
    :param:     filters A list of `LogFilter`s to be used for filtering log
                messages.
    
    :param:     formatters A list of `LogFormatter`s to be used for formatting
                log messages.
    
    :param:     additionalRecorders A list of `LogRecorder`s to be used in
                addition to the `ASLLogRecorder`.
    
    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
    */
    public init(minimumSeverity: LogSeverity = .Info, filters: [LogFilter] = [], formatters: [LogFormatter] = [DefaultLogFormatter()], additionalRecorders: [LogRecorder] = [], synchronousMode: Bool = false)
    {
        var recorders: [LogRecorder] = [ASLLogRecorder(formatters: formatters)]
        recorders += additionalRecorders

        self.init(recorders: recorders, minimumSeverity: minimumSeverity, filters: filters, formatters: formatters, synchronousMode: synchronousMode)
    }

    /**
    A `DefaultLogConfiguration` initializer that uses the specified 
    `LogRecorder`s (and *does not* include the use of the `ASLLogRecorder` 
    unless explicitly specified).
    
    :param:     recorders A list of `LogRecorder`s to be used for recording
                log messages.

    :param:     minimumSeverity The minimum `LogSeverity` supported by the
                configuration.
    
    :param:     filters A list of `LogFilter`s to be used for filtering log
                messages.
    
    :param:     formatters A list of `LogFormatter`s to be used for formatting
                log messages.

    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
    */
    public init(recorders: [LogRecorder], minimumSeverity: LogSeverity = .Info, filters: [LogFilter] = [], formatters: [LogFormatter] = [DefaultLogFormatter()], synchronousMode: Bool = false)
    {
        self.minimumSeverity = minimumSeverity
        self.filters = filters
        self.synchronousMode = synchronousMode
        self.recorders = recorders
    }
}
