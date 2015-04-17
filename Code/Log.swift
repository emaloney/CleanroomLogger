//
//  Log.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`Log` is a convenience that allows you to submit log messages at specific
log levels without having to use the more verbose, lower-level API provided
by `LogReceptacle`.

Before using `Log`, your application must call the `Log.enable()` function. 
This is typically done at the earliest possible place within your app delegate's
`application(_: didFinishLaunchingWithOptions:)` function.
*/
public struct Log
{
    /** The `LogChannel` that can be used to perform logging at the `.Error`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Error` or greater. */
    public static var error: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Warning`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Warning` or greater. */
    public static var warning: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Info`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Info` or greater. */
    public static var info: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Debug`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Debug` or greater. */
    public static var debug: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Verbose`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Verbose` or greater. */
    public static var verbose: LogChannel?

    /**
    Enables logging with the specified minimum `LogSeverity`.
    
    Typically, you would call this function early on in your application's
    lifecycle to enable system-wide logging.
    
    Note that this function has no effect after the first time it is called.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted.
    
    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
    */
    public static func enable(minimumSeverity: LogSeverity = .Info, synchronousMode: Bool = false)
    {
        dispatch_once(&enableOnce) {
            let config = LogConfiguration(severity: minimumSeverity, filters: [], recorders: [ASLLogRecorder()], synchronousMode: synchronousMode)
            let recept = LogReceptacle(configuration: [config])

            self.error = self.logChannelWithSeverity(.Error, receptacle: recept, minimumSeverity: minimumSeverity)
            self.warning = self.logChannelWithSeverity(.Warning, receptacle: recept, minimumSeverity: minimumSeverity)
            self.info = self.logChannelWithSeverity(.Info, receptacle: recept, minimumSeverity: minimumSeverity)
            self.debug = self.logChannelWithSeverity(.Debug, receptacle: recept, minimumSeverity: minimumSeverity)
            self.verbose = self.logChannelWithSeverity(.Verbose, receptacle: recept, minimumSeverity: minimumSeverity)
        }
    }

    private static var enableOnce = dispatch_once_t()

    private static func logChannelWithSeverity(severity: LogSeverity, receptacle: LogReceptacle, minimumSeverity: LogSeverity)
        -> LogChannel?
    {
        if severity.compare(.AsOrMoreSevereThan, against: minimumSeverity) {
            return LogChannel(severity: severity, receptacle: receptacle)
        }
        return nil
    }
}
