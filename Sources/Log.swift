//
//  Log.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Dispatch
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
    /** The `LogChannel` that can be used to perform logging at the `.error`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.error` severity has not been configured. */
    public private(set) static var error: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.warning`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.warning` severity has not been configured. */
    public private(set) static var warning: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.info`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.info` severity has not been configured. */
    public private(set) static var info: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.debug`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.debug` severity has not been configured. */
    public private(set) static var debug: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.verbose`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.verbose` severity has not been configured. */
    public private(set) static var verbose: LogChannel?

    /**
     Enables logging using an `XcodeLogConfiguration`.

     Log entries are recorded by being written to the Apple System Log and to
     the `stderr` output stream of the running process. In Xcode, log entries
     will appear in the console.

     - warning: Setting either `debugMode` or `verboseDebugMode` to `true` will
     result in `synchronousMode` being used when recording log entries.
     Synchronous mode is helpful while debugging, as it ensures that logs are
     always up-to-date when debug breakpoints are hit. However, synchronous
     mode can have a negative influence on performance and is therefore not
     recommended for use in production code.

     - parameter minimumSeverity: The minimum supported `LogSeverity`. Any
     `LogEntry` having a `severity` less than `minimumSeverity` will be silently
     ignored.

     - parameter debugMode: If `true`, the value of `minimumSeverity` will
     be lowered (if necessary) to `.debug` and `synchronousMode` will be used
     when recording log entries.

     - parameter verboseDebugMode: If `true`, the value of `minimumSeverity`
     will be lowered (if necessary) to `.verbose` and `synchronousMode` will be
     used when recording log entries.

     - parameter stdStreamsMode: A `StandardStreamsMode` value that governs
     when standard console streams (i.e., `stdout` and `stderr`) should be used
     for recording log output.

     - parameter mimicOSLogOutput: If `true`, any output sent to `stdout` will
     be formatted in such a way as to mimic the output seen when `os_log()` is
     used.
     
     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.
    
     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.
     */
    public static func enable(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, stdStreamsMode: ConsoleLogConfiguration.StandardStreamsMode = .useAsFallback, mimicOSLogOutput: Bool = true, showCallSite: Bool = true, filters: [LogFilter] = [])
    {
        let config = XcodeLogConfiguration(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, stdStreamsMode: stdStreamsMode, mimicOSLogOutput: mimicOSLogOutput, showCallSite: showCallSite, filters: filters)

        enable(configuration: config)
    }

    /**
     Enables logging using the specified `LogConfiguration`.

     - parameter configuration: The `LogConfiguration` to use for controlling
     the behavior of logging.
     */
    public static func enable(configuration: LogConfiguration)
    {
        enable(configuration: [configuration])
    }

    /**
     Enables logging using the specified `LogConfiguration`s.

     - parameter configuration: An array of `LogConfiguration`s specifying
     the behavior of logging.
     */
    public static func enable(configuration: [LogConfiguration])
    {
        enable(receptacle: LogReceptacle(configuration: configuration))
    }

    /**
     Enables logging using the specified `LogReceptacle`.

     Individual `LogChannel`s for `error`, `warning`, `info`, `debug`, and
     `verbose` may or may not be constructed depending on the receptacle's
     `minimumSeverity`.

     - parameter receptacle: The `LogReceptacle` to use when creating the
     `LogChannel`s for the five severity levels.
     */
    public static func enable(receptacle: LogReceptacle)
    {
        enable(
            errorChannel: createLogChannel(severity: .error, receptacle: receptacle),
            warningChannel: createLogChannel(severity: .warning, receptacle: receptacle),
            infoChannel: createLogChannel(severity: .info, receptacle: receptacle),
            debugChannel: createLogChannel(severity: .debug, receptacle: receptacle),
            verboseChannel: createLogChannel(severity: .verbose, receptacle: receptacle)
        )
    }

    /**
     Enables logging using the specified `LogChannel`s.

     The static `error`, `warning`, `info`, `debug`, and `verbose` properties of
     `Log` will be set using the specified values.

     If you know that the configuration of a given `LogChannel` guarantees that
     it will never perform logging, it is best to pass `nil` instead. Otherwise,
     needless overhead will be added to the application.

     - parameter errorChannel: The `LogChannel` to use for logging messages with
     a `severity` of `.error`.

     - parameter warningChannel: The `LogChannel` to use for logging messages
     with a `severity` of `.warning`.

     - parameter infoChannel: The `LogChannel` to use for logging messages with
     a `severity` of `.info`.

     - parameter debugChannel: The `LogChannel` to use for logging messages with
     a `severity` of `.debug`.

     - parameter verboseChannel: The `LogChannel` to use for logging messages
     with a `severity` of `.verbose`.
     */
    public static func enable(errorChannel: LogChannel?, warningChannel: LogChannel?, infoChannel: LogChannel?, debugChannel: LogChannel?, verboseChannel: LogChannel?)
    {
        logLock.lock()
        if !didEnable {
            self.error = errorChannel
            self.warning = warningChannel
            self.info = infoChannel
            self.debug = debugChannel
            self.verbose = verboseChannel
            didEnable = true
        }
        logLock.unlock()
    }

    private static let logLock = NSLock()
    private static var didEnable = false

    /**
     Assuming CleanroomLogger has not yet been enabled, calling this function
     prevents any other caller from enabling CleanroomLogger for the remainder
     of the lifetime of the running executable.

     The ability to prevent CleanroomLogger from being enabled may be useful
     in applications that link against libraries requiring CleanroomLogger.
     Application developers who did not choose to use CleanroomLogger can
     ensure that embedded third-party libraries don't use it, either.

     - important: If `Log.enable()` has already been called, calling
     `Log.neverEnable()` will have no effect.
     */
    public static func neverEnable()
    {
        enable(errorChannel: nil, warningChannel: nil, infoChannel: nil, debugChannel: nil, verboseChannel: nil)
    }

    /**
     Returns the `LogChannel` responsible for logging at the given severity.

     - parameter severity: The `LogSeverity` level of the `LogChannel` to
     return.

     - returns:  The `LogChannel` used by `Log` to perform logging at the given
     severity; will be `nil` if `Log` is not configured to perform logging at
     that severity.
     */
    public static func channel(severity: LogSeverity)
        -> LogChannel?
    {
        switch severity {
        case .verbose:  return verbose
        case .debug:    return debug
        case .info:     return info
        case .warning:  return warning
        case .error:    return error
        }
    }

    /**
     Sends program execution trace information to the log using the specified
     severity. This information includes source-level call site information as
     well as the stack frame signature of the caller.

     - parameter severity: The `LogSeverity` for the message being recorded.

     - parameter function: The default value provided for this parameter
     captures the signature of the calling function. You should not provide a
     value for this parameter.

     - parameter filePath: The default value provided for this parameter
     captures the file path of the code issuing the call to this function.
     You should not provide a value for this parameter.

     - parameter fileLine: The default value provided for this parameter
     captures the line number issuing the call to this function. You should
     not provide a value for this parameter.
     */
    public static func trace(_ severity: LogSeverity, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        channel(severity: severity)?.trace(function, filePath: filePath, fileLine: fileLine)
    }

    /**
     Sends a message string to the log using the specified severity.

     - parameter severity: The `LogSeverity` for the log entry.

     - parameter msg: The message to log.

     - parameter function: The default value provided for this parameter
     captures the signature of the calling function. You should not provide a
     value for this parameter.

     - parameter filePath: The default value provided for this parameter
     captures the file path of the code issuing the call to this function.
     You should not provide a value for this parameter.

     - parameter fileLine: The default value provided for this parameter
     captures the line number issuing the call to this function. You should
     not provide a value for this parameter.
     */
    public static func message(_ severity: LogSeverity, message: String, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        channel(severity: severity)?.message(message, function: function, filePath: filePath, fileLine: fileLine)
    }

    /**
     Sends an arbitrary value to the log using the specified severity.

     - parameter severity: The `LogSeverity` for the log entry.

     - parameter value: The value to send to the log. Determining how (and
     whether) arbitrary values are captured and represented will be handled by
     the `LogRecorder` implementation(s) that are ultimately called upon to
     record the log entry.

     - parameter function: The default value provided for this parameter
     captures the signature of the calling function. You should not provide a
     value for this parameter.

     - parameter filePath: The default value provided for this parameter
     captures the file path of the code issuing the call to this function.
     You should not provide a value for this parameter.

     - parameter fileLine: The default value provided for this parameter
     captures the line number issuing the call to this function. You should
     not provide a value for this parameter.
     */
    public static func value(_ severity: LogSeverity, value: Any?, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        channel(severity: severity)?.value(value, function: function, filePath: filePath, fileLine: fileLine)
    }

    private static func createLogChannel(severity: LogSeverity, receptacle: LogReceptacle)
        -> LogChannel?
    {
        guard severity >= receptacle.minimumSeverity else {
            return nil
        }
        
        return LogChannel(severity: severity, receptacle: receptacle)
    }
}
