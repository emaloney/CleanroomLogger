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

     - parameter logToASL: If `true`, messages sent to the Xcode console will
     also be sent to the Apple System Log (ASL) facility.

     - parameter timestampStyle: Governs the formatting of the timestamp in the
     log output. Pass `nil` to suppress output of the timestamp.

     - parameter severityStyle: Governs the formatting of the `LogSeverity` in
     the log output. Pass `nil` to suppress output of the severity.

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.

     - parameter showCallingThread: If `true`, a hexadecimal string containing
     an opaque identifier for the calling thread will be added to formatted log
     messages.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.
    */
    public convenience init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, logToASL: Bool = true, timestampStyle: TimestampStyle? = .default, severityStyle: SeverityStyle? = .xcode, showCallSite: Bool = true, showCallingThread: Bool = false, showSeverity: Bool = true, filters: [LogFilter] = [])
    {
        let formatter = XcodeLogFormatter(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: nil, showCallSite: showCallSite, showCallingThread: showCallingThread)

        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, logToASL: logToASL, filters: filters, formatter: formatter)
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

     - parameter logToASL: If `true`, messages sent to the Xcode console will
     also be sent to the Apple System Log (ASL) facility.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatter: A `LogFormatter` to use for formatting log entries
     to be recorded.
     */
    public convenience init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, logToASL: Bool = true, filters: [LogFilter] = [], formatter: LogFormatter)
    {
        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, logToASL: logToASL, filters: filters, formatters: [formatter])
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

     - parameter logToASL: If `true`, messages sent to the Xcode console will
     also be sent to the Apple System Log (ASL) facility.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded.
     */
    public init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, logToASL: Bool = true, filters: [LogFilter] = [], formatters: [LogFormatter])
    {
        var minimumSeverity = minimumSeverity
        if verboseDebugMode {
            minimumSeverity = .verbose
        }
        else if debugMode && minimumSeverity > .debug {
            minimumSeverity = .debug
        }

        let recorders: [LogRecorder]
        if logToASL {
            recorders = [ASLLogRecorder(formatters: formatters, echoToStdErr: true, addTraceAttributes: debugMode || verboseDebugMode)]
        } else {
            recorders = [StandardOutputLogRecorder(formatters: formatters)]
        }

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: recorders, synchronousMode: (debugMode || verboseDebugMode))
    }
}
