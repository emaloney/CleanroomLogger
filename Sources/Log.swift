//
//  Log.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
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
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.Error` severity has not been configured. */
    public private(set) static var error: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Warning`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.Warning` severity has not been configured. */
    public private(set) static var warning: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Info`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.Info` severity has not been configured. */
    public private(set) static var info: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Debug`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.Debug` severity has not been configured. */
    public private(set) static var debug: LogChannel?

    /** The `LogChannel` that can be used to perform logging at the `.Verbose`
     log severity level. Will be `nil` if logging hasn't yet been enabled, or
     if logging for the `.Verbose` severity has not been configured. */
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
     be lowered (if necessary) to `.Debug` and `synchronousMode` will be used
     when recording log entries.

     - parameter verboseDebugMode: If `true`, the value of `minimumSeverity` 
     will be lowered (if necessary) to `.Verbose` and `synchronousMode` will be
     used when recording log entries.

     - parameter timestampStyle: Governs the formatting of the timestamp in the
     log output. Pass `nil` to suppress output of the timestamp.

     - parameter severityStyle: Governs the formatting of the `LogSeverity` in
     the log output. Pass `nil` to suppress output of the severity.

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.

     - parameter showCallingThread: If `true`, a hexadecimal string containing
     an opaque identifier for the calling thread will be added to formatted log
     messages.

     - parameter suppressColors: If `true`, log message colorization will be
     disabled. By default, if the third-party XcodeColors plug-in for Xcode
     is installed, and if CleanroomLogger detects that it is enabled, log
     messages are colorized automatically.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.
     */
    public static func enable(minimumSeverity minimumSeverity: LogSeverity = .Info, debugMode: Bool = false, verboseDebugMode: Bool = false, timestampStyle: TimestampStyle? = .Default, severityStyle: SeverityStyle? = .Xcode, showCallSite: Bool = true, showCallingThread: Bool = false, suppressColors: Bool = false, filters: [LogFilter] = [])
    {
        let config = XcodeLogConfiguration(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, timestampStyle: timestampStyle, severityStyle: severityStyle, showCallSite: showCallSite, showCallingThread: showCallingThread, suppressColors: suppressColors, filters: filters)

        enable(configuration: config)
    }

    /**
     Enables logging using the specified `LogConfiguration`.

     - parameter configuration: The `LogConfiguration` to use for controlling
     the behavior of logging.
     */
    public static func enable(configuration configuration: LogConfiguration)
    {
        enable(configuration: [configuration])
    }

    /**
     Enables logging using the specified `LogConfiguration`s.

     - parameter configuration: An array of `LogConfiguration`s specifying
     the behavior of logging.
     */
    public static func enable(configuration configuration: [LogConfiguration])
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
    public static func enable(receptacle receptacle: LogReceptacle)
    {
        enable(
            errorChannel: createLogChannelWithSeverity(.Error, forReceptacle: receptacle),
            warningChannel: createLogChannelWithSeverity(.Warning, forReceptacle: receptacle),
            infoChannel: createLogChannelWithSeverity(.Info, forReceptacle: receptacle),
            debugChannel: createLogChannelWithSeverity(.Debug, forReceptacle: receptacle),
            verboseChannel: createLogChannelWithSeverity(.Verbose, forReceptacle: receptacle)
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
     a `severity` of `.Error`.

     - parameter warningChannel: The `LogChannel` to use for logging messages
     with a `severity` of `.Warning`.

     - parameter infoChannel: The `LogChannel` to use for logging messages with
     a `severity` of `.Info`.

     - parameter debugChannel: The `LogChannel` to use for logging messages with
     a `severity` of `.Debug`.

     - parameter verboseChannel: The `LogChannel` to use for logging messages
     with a `severity` of `.Verbose`.
     */
    public static func enable(errorChannel errorChannel: LogChannel?, warningChannel: LogChannel?, infoChannel: LogChannel?, debugChannel: LogChannel?, verboseChannel: LogChannel?)
    {
        dispatch_once(&enableOnce) {
            self.error = errorChannel
            self.warning = warningChannel
            self.info = infoChannel
            self.debug = debugChannel
            self.verbose = verboseChannel
        }
    }

    private static var enableOnce = dispatch_once_t()

    /**
     Returns the `LogChannel` responsible for logging at the given severity.

     - parameter severity: The `LogSeverity` level of the `LogChannel` to
     return.

     - returns:  The `LogChannel` used by `Log` to perform logging at the given
     severity; will be `nil` if `Log` is not configured to perform logging at
     that severity.
     */
    public static func channelForSeverity(severity: LogSeverity)
        -> LogChannel?
    {
        switch severity {
        case .Verbose:  return verbose
        case .Debug:    return debug
        case .Info:     return info
        case .Warning:  return warning
        case .Error:    return error
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
    public static func trace(severity: LogSeverity, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.trace(function, filePath: filePath, fileLine: fileLine)
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
    public static func message(severity: LogSeverity, message: String, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.message(message, function: function, filePath: filePath, fileLine: fileLine)
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
    public static func value(severity: LogSeverity, value: Any?, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        channelForSeverity(severity)?.value(value, function: function, filePath: filePath, fileLine: fileLine)
    }

    private static func createLogChannelWithSeverity(severity: LogSeverity, forReceptacle receptacle: LogReceptacle)
        -> LogChannel?
    {
        guard severity >= receptacle.minimumSeverity else {
            return nil
        }

        return LogChannel(severity: severity, receptacle: receptacle)
    }
}
