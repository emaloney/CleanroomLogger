//
//  XcodeLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 A `LogConfiguration` optimized for use when running within Xcode.
 
 By default, this configuration will attempt to detect the presence of
 the XcodeColors plug-in, and—if it is present—will enable text colorization.
 
 If text colorization is used, the `XcodeLogConfiguration` will enable two
 separate `LogRecorder`s: a `StandardOutputLogRecorder`, which will be
 configured to perform colorization of the logs within the Xcode console,
 and an `ASLLogRecorder` which will not use colorization. This ensures that
 the colorization escape sequences used within Xcode do not end up in the
 Apple System Log (ASL), where they will look like garbage characters.
 
 If no colorization is used, then the `XcodeLogConfiguration` will configure
 only a single recorder: an `ASLLogRecorder` configured to echo output to
 `stdout` as well as capturing to the ASL.
*/
public class XcodeLogConfiguration: BasicLogConfiguration
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
     also be sent to the Apple System Log (ASL) facility, minus any 
     colorization codes, which look like corrupted characters in the ASL.

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
    public convenience init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, logToASL: Bool = true, timestampStyle: TimestampStyle? = .`default`, severityStyle: SeverityStyle? = .xcode, showCallSite: Bool = true, showCallingThread: Bool = false, showSeverity: Bool = true, suppressColors: Bool = false, filters: [LogFilter] = [])
    {
        var colorizer: TextColorizer?
        if !suppressColors {
            colorizer = XcodeColorsTextColorizer()
        }

        let formatter = XcodeLogFormatter(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: nil, showCallSite: showCallSite, showCallingThread: showCallingThread, colorizer: nil)

        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, logToASL: logToASL, colorizer: colorizer, filters: filters, formatter: formatter)
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
     also be sent to the Apple System Log (ASL) facility, minus any
     colorization codes, which look like corrupted characters in the ASL.
     
     - parameter colorizer: The `TextColorizer` that will be used to colorize
     the output of the receiver. If `nil`, no colorization will occur.

     - parameter colorTable: If a `colorizer` is provided, an optional
     `ColorTable` may also be provided to supply color information. If `nil`,
     `DefaultColorTable` will be used for colorization.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatter: A `LogFormatter` to use for formatting log entries
     to be recorded.
     */
    public convenience init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, logToASL: Bool = true, colorizer: TextColorizer? = XcodeColorsTextColorizer(), colorTable: ColorTable? = nil, filters: [LogFilter] = [], formatter: LogFormatter)
    {
        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, logToASL: logToASL, colorizer: colorizer, filters: filters, formatters: [formatter])
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
     also be sent to the Apple System Log (ASL) facility, minus any
     colorization codes, which look like corrupted characters in the ASL.
     
     - parameter colorizer: The `TextColorizer` that will be used to colorize
     the output of the receiver. If `nil`, no colorization will occur.

     - parameter colorTable: If a `colorizer` is provided, an optional
     `ColorTable` may also be provided to supply color information. If `nil`,
     `DefaultColorTable` will be used for colorization.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded.
     */
    public init(minimumSeverity: LogSeverity = .info, debugMode: Bool = false, verboseDebugMode: Bool = false, logToASL: Bool = true, colorizer: TextColorizer? = XcodeColorsTextColorizer(), colorTable: ColorTable? = nil, filters: [LogFilter] = [], formatters: [LogFormatter])
    {
        var minimumSeverity = minimumSeverity
        if verboseDebugMode {
            minimumSeverity = .verbose
        }
        else if debugMode && minimumSeverity > .debug {
            minimumSeverity = .debug
        }

        let recorders: [LogRecorder]
        if let colorizer = colorizer {
            let colorFormatters: [LogFormatter] = formatters.map{ ColorizingLogFormatter(formatter: $0, colorizer: colorizer, colorTable: colorTable) }

            if logToASL {
                recorders = [
                    ASLLogRecorder(formatters: formatters, echoToStdErr: false),
                    StandardOutputLogRecorder(formatters: colorFormatters)
                ]
            }
            else {
                recorders = [StandardOutputLogRecorder(formatters: colorFormatters)]
            }
        }
        else if logToASL {
            recorders = [ASLLogRecorder(formatters: formatters)]    // automatically echoes to stdout
        }
        else {
            recorders = [StandardOutputLogRecorder(formatters: formatters)]
        }

        let synchronous = debugMode || verboseDebugMode

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: recorders, synchronousMode: synchronous)
    }
}
