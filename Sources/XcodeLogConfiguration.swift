//
//  XcodeLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 A `LogConfiguration` optimized for use when running within Xcode.
 
 The `XcodeLogConfiguration` sets up a single recorder: an `ASLLogRecorder`
 configured to echo output to `stdout` as well as capturing to the ASL.
*/
open class XcodeLogConfiguration: BasicLogConfiguration
{
    /**
     Initializes a new `XcodeLogConfiguration` instance.
     
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

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.
    */
    public convenience init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, showCallSite: Bool = true, filters: [LogFilter] = [])
    {
        let formatter = XcodeLogFormatter(showCallSite: showCallSite)

        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, filters: filters, formatters: [formatter])
    }

    /**
     Initializes a new `XcodeLogConfiguration` instance.

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

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded.
     */
    public init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, filters: [LogFilter] = [], formatters: [LogFormatter])
    {
        var minimumSeverity = minimumSeverity
        if verboseDebugMode {
            minimumSeverity = .verbose
        }
        else if debugMode && minimumSeverity > .debug {
            minimumSeverity = .debug
        }

        //
        // OSLogRecorder is only available as of iOS 10.0, macOS 10.12, 
        // tvOS 10.0, and watchOS 3.0; on other systems, the initializer
        // will fail and output will fall back to StandardOutputLogRecorder
        //
        let recorder: LogRecorder = OSLogRecorder(formatters: formatters) ?? StandardOutputLogRecorder(formatters: formatters)

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: [recorder], synchronousMode: (debugMode || verboseDebugMode))
    }
}
