//
//  Log.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`Log` is the primary public API for CleanroomLogger.

If you wish to send a message to the log, you do so by calling the appropriae
function provided by the appropriate `LogChannel` given the importance of your
message.

There are five levels of severity at which log messages can be recorded. Each
level is represented by a read-only static variable maintained by the `Log`:

- `Log.error` — The highest severity; something has gone wrong and a fatal error
may be imminent

- `Log.warning` — Something appears amiss and might bear looking into before a
larger problem arises

- `Log.info` — Something notable happened, but it isn't anything to worry about

- `Log.debug` — Used for debugging and diagnostic information

- `Log.verbose` - The lowest severity; used for detailed or frequently occurring
debugging and diagnostic information

Each `LogChannel` can be used in one of three ways:

- The `trace()` function records a short log message detailing the source
file, source line, and function name of the caller. It is intended to be called
with no arguments, as follows:

```
Log.debug?.trace()
```

- The `message()` function records a message specified by the caller:

```
Log.info?.message("The application has finished launching.")
```

`message()` is intended to be called with a single parameter, the message 
string, as shown above. Unlike `NSLog()`, no `printf`-like functionality
is provided; instead, use Swift string interpolation to construct parameterized
messages.

- Finally, the `value()` function records a string representation of an 
arbitrary `Any` value:

```
Log.verbose?.value(delegate)
```

The `value()` function is intended to be called with a single parameter, of
type `Any?`.

The underlying logging implementation is responsible for converting this value
into a string representation.

Note that some implementations may not be able to convert certain values into
strings; in those cases, log requests may be silently ignored.

### Enabling logging

By default, logging is disabled, meaning that none of the `Log`'s *log channels*
have been populated. As a result, attempts to perform any logging will silently
fail.

It is the responsibility of the *application developer* to enable logging, which
is done by calling the appropriate `Log.enable()` function.
*/
public struct Log
{
    /** The `LogChannel` that can be used to perform logging at the `.Error`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Error` or greater. */
    public static var error: LogChannel? { return _error }

    /** The `LogChannel` that can be used to perform logging at the `.Warning`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Warning` or greater. */
    public static var warning: LogChannel? { return _warning }

    /** The `LogChannel` that can be used to perform logging at the `.Info`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Info` or greater. */
    public static var info: LogChannel? { return _info }

    /** The `LogChannel` that can be used to perform logging at the `.Debug`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Debug` or greater. */
    public static var debug: LogChannel? { return _debug }

    /** The `LogChannel` that can be used to perform logging at the `.Verbose`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Verbose` or greater. */
    public static var verbose: LogChannel? { return _verbose }

    /**
    Enables logging with the specified minimum `LogSeverity` using the
    `DefaultLogConfiguration`.
    
    This variant logs to the Apple System Log and to the `stderr` output
    stream of the application process. In Xcode, log messages will appear in
    the console.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted. Attempts to log messages less severe than
                `minimumSeverity` will be silently ignored.
    
    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
    */
    public static func enable(minimumSeverity: LogSeverity = .Info, synchronousMode: Bool = false)
    {
        let config = DefaultLogConfiguration(minimumSeverity: minimumSeverity, synchronousMode: synchronousMode)
        enable(config)
    }

    /**
    Enables logging using the specified `LogConfiguration`.

    :param:     configuration The `LogConfiguration` to use for controlling
                the behavior of logging.
    */
    public static func enable(configuration: LogConfiguration)
    {
        enable([configuration], minimumSeverity: configuration.minimumSeverity)
    }

    /**
    Enables logging using the specified list of `LogConfiguration`s.

    :param:     configuration The list of `LogConfiguration`s to use for controlling
                the behavior of logging.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted. Attempts to log messages less severe than
                `minimumSeverity` will be silently ignored.
    */
    public static func enable(configuration: [LogConfiguration], minimumSeverity: LogSeverity = .Info)
    {
        let recept = LogReceptacle(configuration: configuration)
        enable(recept, minimumSeverity: minimumSeverity)
    }

    /**
    Enables logging using the specified `LogReceptacle`.
    
    Individual `LogChannel`s for `error`, `warning`, `info`, `debug`, and 
    `verbose` will be constructed based on the specified `minimumSeverity`.
    Each channel will use `receptacle` as the underlying `LogReceptacle`.

    :param:     receptacle The list of `LogConfiguration`s to use for controlling
                the behavior of logging.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted. Attempts to log messages less severe than
                `minimumSeverity` will be silently ignored.
    */
    public static func enable(receptacle: LogReceptacle, minimumSeverity: LogSeverity = .Info)
    {
        enable(
            errorChannel: self.createLogChannelWithSeverity(.Error, receptacle: receptacle, minimumSeverity: minimumSeverity),
            warningChannel: self.createLogChannelWithSeverity(.Warning, receptacle: receptacle, minimumSeverity: minimumSeverity),
            infoChannel: self.createLogChannelWithSeverity(.Info, receptacle: receptacle, minimumSeverity: minimumSeverity),
            debugChannel: self.createLogChannelWithSeverity(.Debug, receptacle: receptacle, minimumSeverity: minimumSeverity),
            verboseChannel: self.createLogChannelWithSeverity(.Verbose, receptacle: receptacle, minimumSeverity: minimumSeverity)
        )
    }

    /**
    Enables logging using the specified `LogChannel`s.

    The static `error`, `warning`, `info`, `debug`, and `verbose` properties of
    `Log` will be set using the specified values.
    
    If you know that the configuration of a given `LogChannel` guarantees that
    it will never perform logging, it is best to pass `nil` instead. Otherwise,
    needless overhead will be added to the application.

    :param:     errorChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Error`.

    :param:     warningChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Warning`.

    :param:     infoChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Info`.

    :param:     debugChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Debug`.

    :param:     verboseChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Verbose`.
    */
    public static func enable(#errorChannel: LogChannel?, warningChannel: LogChannel?, infoChannel: LogChannel?, debugChannel: LogChannel?, verboseChannel: LogChannel?)
    {
        dispatch_once(&enableOnce) {
            self._error = errorChannel
            self._warning = warningChannel
            self._info = infoChannel
            self._debug = debugChannel
            self._verbose = verboseChannel
        }
    }

    private static var _error: LogChannel?
    private static var _warning: LogChannel?
    private static var _info: LogChannel?
    private static var _debug: LogChannel?
    private static var _verbose: LogChannel?

    private static var enableOnce = dispatch_once_t()

    /**
    Returns the `LogChannel` responsible for logging at the given severity.
    
    :param:     severity The `LogSeverity` level of the `LogChannel` to
                return.
    
    :returns:   The `LogChannel` used by `Log` to perform logging at the given
                severity; will be `nil` if `Log` is not configured to
                perform logging at that severity.
    */
    public static func channelForSeverity(severity: LogSeverity)
        -> LogChannel?
    {
        switch severity {
        case .Verbose:  return _verbose
        case .Debug:    return _debug
        case .Info:     return _info
        case .Warning:  return _warning
        case .Error:    return _error
        }
    }

    /**
    Writes program execution trace information to the log using the specified
    severity. This information includes the signature of the calling function, 
    as well as the source file and line at which the call to `trace()` was
    issued.
    
    :param:     severity The `LogSeverity` for the message being recorded.

    :param:     function The default value provided for this parameter captures
                the signature of the calling function. **You should not provide
                a value for this parameter.**
    
    :param:     filePath The default value provided for this parameter captures
                the file path of the code issuing the call to this function. 
                **You should not provide a value for this parameter.**

    :param:     fileLine The default value provided for this parameter captures
                the line number issuing the call to this function. **You should
                not provide a value for this parameter.**
    */
    public static func trace(severity: LogSeverity, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.trace(function: function, filePath: filePath, fileLine: fileLine)
    }

    /**
    Writes a string-based message to the log using the specified severity.
    
    :param:     severity The `LogSeverity` for the message being recorded.

    :param:     msg The message to log.
    
    :param:     function The default value provided for this parameter captures
                the signature of the calling function. **You should not provide
                a value for this parameter.**
    
    :param:     filePath The default value provided for this parameter captures
                the file path of the code issuing the call to this function. 
                **You should not provide a value for this parameter.**

    :param:     fileLine The default value provided for this parameter captures
                the line number issuing the call to this function. **You should
                not provide a value for this parameter.**
    */
    public static func message(severity: LogSeverity, message: String, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.message(message, function: function, filePath: filePath, fileLine: fileLine)
    }

    /**
    Writes an arbitrary value to the log using the specified severity.

    :param:     severity The `LogSeverity` for the message being recorded.

    :param:     value The value to write to the log. The underlying logging
                implementation is responsible for converting `value` into a
                text representation. If that is not possible, the log request
                may be silently ignored.
    
    :param:     function The default value provided for this parameter captures
                the signature of the calling function. **You should not provide
                a value for this parameter.**
    
    :param:     filePath The default value provided for this parameter captures
                the file path of the code issuing the call to this function. 
                **You should not provide a value for this parameter.**

    :param:     fileLine The default value provided for this parameter captures
                the line number issuing the call to this function. **You should
                not provide a value for this parameter.**
    */
    public static func value(severity: LogSeverity, value: Any?, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.value(value, function: function, filePath: filePath, fileLine: fileLine)
    }

    private static func createLogChannelWithSeverity(severity: LogSeverity, receptacle: LogReceptacle, minimumSeverity: LogSeverity)
        -> LogChannel?
    {
        if severity >= minimumSeverity {
            return LogChannel(severity: severity, receptacle: receptacle)
        }
        return nil
    }
}
