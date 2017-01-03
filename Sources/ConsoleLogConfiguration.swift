//
//  ConsoleLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 A standard `LogConfiguration` that, by default, uses the `os_log()` function
 (via the `OSLogRecorder`), which is only available as of iOS 10.0, macOS 10.12, 
 tvOS 10.0, and watchOS 3.0.
 
 If `os_log()` is not available, or if the `StandardLogConfiguration` is
 configured to bypass it, log messages will be written to the `stdout`
 output stream of the running process (via the `StandardOutputLogRecorder`).
 */
open class ConsoleLogConfiguration: BasicLogConfiguration
{
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
     
     - parameter useStdoutOnly: If `true`, the `os_log()` function is not used
     even if available; instead, all log messages are sent to `stdout` using 
     the `StandardOutputLogRecorder`.
     
     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.
     
     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded.
     */
    public init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, useStdoutOnly: Bool = false, filters: [LogFilter] = [], formatters: [LogFormatter])
    {
        var minimumSeverity = minimumSeverity
        if verboseDebugMode {
            minimumSeverity = .verbose
        }
        else if debugMode && minimumSeverity > .debug {
            minimumSeverity = .debug
        }
        
        let recorder = ConsoleLogRecorder(formatters: formatters, useStdoutOnly: useStdoutOnly)
        
        super.init(minimumSeverity: minimumSeverity,
                   filters: filters,
                   recorders: [recorder],
                   synchronousMode: (debugMode || verboseDebugMode))
    }
}
