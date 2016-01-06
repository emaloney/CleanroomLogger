//
//  XcodeLogConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
*/
public class XcodeLogConfiguration: BasicLogConfiguration
{
    /**
    */
    public convenience init(minimumSeverity: LogSeverity = .Info, debugMode: Bool = false, verboseDebugMode: Bool = false, timestampStyle: TimestampStyle? = .Default, severityStyle: SeverityStyle? = .Xcode, showCallSite: Bool = true, showCallingThread: Bool = false, showSeverity: Bool = true, suppressColors: Bool = false, filters: [LogFilter] = [])
    {
        var minimumSeverity = minimumSeverity
        if verboseDebugMode {
            minimumSeverity = .Verbose
        }
        else if debugMode && minimumSeverity > .Debug {
            minimumSeverity = .Debug
        }

        var colorizer: TextColorizer?
        if !suppressColors {
            colorizer = XcodeColorsTextColorizer()
        }

        let formatter = XcodeLogFormatter(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: nil, showCallSite: showCallSite, showCallingThread: showCallingThread, colorizer: nil)

        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, colorizer: colorizer, formatter: formatter, filters: filters)
    }

    public convenience init(minimumSeverity: LogSeverity = .Info, debugMode: Bool = false, verboseDebugMode: Bool = false, colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil, formatter: LogFormatter, filters: [LogFilter] = [])
    {
        self.init(minimumSeverity: minimumSeverity, debugMode: debugMode, verboseDebugMode: verboseDebugMode, colorizer: colorizer, formatters: [formatter], filters: filters)
    }

    public init(minimumSeverity: LogSeverity = .Info, debugMode: Bool = false, verboseDebugMode: Bool = false, colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil, formatters: [LogFormatter], filters: [LogFilter] = [])
    {
        let recorders: [LogRecorder]
        if let colorizer = colorizer {
            let colorFormatters: [LogFormatter] = formatters.map{ ColorizingLogFormatter(formatter: $0, colorizer: colorizer, colorTable: colorTable) }

            recorders = [
                ASLLogRecorder(formatters: formatters, echoToStdErr: false),
                StandardOutputLogRecorder(formatters: colorFormatters)
            ]
        }
        else {
            recorders = [ASLLogRecorder(formatters: formatters)]
        }

        let synchronous = debugMode || verboseDebugMode

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: recorders, synchronousMode: synchronous)
    }
}
