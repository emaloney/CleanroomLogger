//
//  ConsoleLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Darwin.C.stdlib

/**
 A standard `LogConfiguration` that, by default, uses the `os_log()` function
 (via the `OSLogRecorder`), which is only available as of iOS 10.0, macOS 10.12, 
 tvOS 10.0, and watchOS 3.0.
 
 If `os_log()` is not available, or if the `StandardLogConfiguration` is
 configured to bypass it, log messages will be written to either the `stdout`
 or `stderr` output stream of the running process.
 */
open class ConsoleLogConfiguration: BasicLogConfiguration
{
    /** Governs when a `ConsoleLogConfiguration` directs log messages to 
     `stdout` and `stderr`. */
    public enum StandardStreamsMode
    {
        /** Indicates that logging will be directed to `stdout` and `stderr`
         only as a fallback on platforms where `os_log()` is not available. */
        case useAsFallback

        /** Indicates that `stdout` and `stderr` will always be used,
         regardless of whether logging using `os_log()` is also occurring. */
        case useAlways

        /** Indicates that `stdout` and `stderr` are to be used exclusively;
         `os_log()` will not be used even when it is available. */
        case useExclusively
    }

    /**
     Initializes a new `ConsoleLogConfiguration` instance.

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

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatters: An array of `LogFormatter`s to use when
     formatting log entries.
     */
    public convenience init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, stdStreamsMode: StandardStreamsMode = .useAsFallback, filters: [LogFilter] = [], formatters: [LogFormatter])
    {
        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, stdStreamsMode: stdStreamsMode, filters: filters, osLogFormatters: formatters, stdoutFormatters: formatters)
    }

    /**
     Initializes a new `ConsoleLogConfiguration` instance.
     
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

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter osLogFormatters: An array of `LogFormatter`s to use when
     formatting log entries bound for the `OSLogRecorder`.

     - parameter stdoutFormatters: An array of `LogFormatter`s to use when
     formatting log entries bound for the `StandardOutputLogRecorder`.
     */
    public init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, stdStreamsMode: StandardStreamsMode = .useAsFallback, filters: [LogFilter] = [], osLogFormatters: [LogFormatter], stdoutFormatters: [LogFormatter])
    {
        var minimumSeverity = minimumSeverity
        if verboseDebugMode {
            minimumSeverity = .verbose
        }
        else if debugMode && minimumSeverity > .debug {
            minimumSeverity = .debug
        }

        var recorders = [LogRecorder]()
        if ConsoleLogConfiguration.willUseOSLog(mode: stdStreamsMode) {
            if let recorder = OSLogRecorder(formatters: osLogFormatters) {
                recorders.append(recorder)
            }
        }
        if ConsoleLogConfiguration.shouldUseStandardStreams(mode: stdStreamsMode) {
            recorders.append(StandardStreamsLogRecorder(formatters: stdoutFormatters))
        }

        super.init(minimumSeverity: minimumSeverity,
                   filters: filters,
                   recorders: recorders,
                   synchronousMode: (debugMode || verboseDebugMode))
    }
}

extension ConsoleLogConfiguration
{
    /**
     Determines whether the `os_log()` function will be used given the runtime
     environment and the value of `mode`.

     - parameter mode: A `StandardStreamsMode` value that governs when standard
     console streams (i.e., `stdout` and `stderr`) should be used for recording
     log output.

     - returns: `true` if `os_log()` is available and will be used given 
     the value of `mode`.
     */
    public static func willUseOSLog(mode: StandardStreamsMode)
        -> Bool
    {
        switch mode {
        case .useAlways, .useAsFallback:
            return OSLogRecorder.isAvailable

        case .useExclusively:
            return false
        }
    }

    /**
     Determines whether the `stdout` and `stderr` streams should be used given
     the runtime environment and the value of `mode`.

     - parameter mode: A `StandardStreamsMode` value that governs when standard
     console streams (i.e., `stdout` and `stderr`) should be used for recording
     log output.

     - returns: `true` if `stdout` and `stderr` will be used given the value of
     `mode`.
     */
    public static func shouldUseStandardStreams(mode: StandardStreamsMode)
        -> Bool
    {
        switch mode {
        case .useAlways, .useExclusively:
            return true

        case .useAsFallback:
            guard OSLogRecorder.isAvailable else {
                return true
            }

            guard let env = getenv("OS_ACTIVITY_MODE") else {
                return false
            }

            guard let str = String(validatingUTF8: env) else {
                return false
            }

            return str == "disable"
        }
    }
}
