//
//  XcodeLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 A `LogConfiguration` optimized for use when running within Xcode.
*/
open class XcodeLogConfiguration: ConsoleLogConfiguration
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
     
     - parameter useStdoutOnly: If `true`, the `os_log()` function is not used
     even if available; instead, all log messages are sent to `stdout` using
     the `StandardOutputLogRecorder`.
     
     - parameter mimicOSLogOutput: If `true`, any output sent to `stdout` will
     be formatted in such a way as to mimic the output seen when `os_log()` is
     used.
     
     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.
    */
    public init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, useStdoutOnly: Bool = false, mimicOSLogOutput: Bool = true, showCallSite: Bool = true, filters: [LogFilter] = [])
    {
        let origFormatter = XcodeLogFormatter(showCallSite: showCallSite)

        let formatter: LogFormatter
        if mimicOSLogOutput && !ConsoleLogRecorder.willUseOSLog(useStdoutOnly: useStdoutOnly) {
            formatter = ConcatenatingLogFormatter(formatters: [OSLogMimicFormatter(), origFormatter])
        } else {
            formatter = origFormatter
        }
        
        super.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, useStdoutOnly: useStdoutOnly, filters: filters, formatters: [formatter])
    }
}
