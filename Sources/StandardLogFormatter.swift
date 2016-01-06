//
//  StandardLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A standard `LogFormatter` that provides some common customization points.
 */
public class StandardLogFormatter: FieldBasedLogFormatter
{
    /**
     Initializes a new `StandardLogFormatter` instance.

     - parameter timestampStyle: Governs the formatting of the timestamp in the
     log output. Pass `nil` to suppress output of the timestamp.

     - parameter severityStyle: Governs the formatting of the `LogSeverity` in
     the log output. Pass `nil` to suppress output of the severity.

     - parameter delimiterStyle: If provided, overrides the default field
     separator delimiters. Pass `nil` to use the default delimiters.

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.

     - parameter showCallingThread: If `true`, a hexadecimal string containing
     an opaque identifier for the calling thread will be added to formatted log
     messages.

     - parameter colorizer: The `TextColorizer` that will be used to colorize
     the output of the receiver. If `nil`, no colorization will occur.

     - parameter colorTable: If a `colorizer` is provided, an optional 
     `ColorTable` may also be provided to supply color information. If `nil`,
     `DefaultColorTable` will be used for colorization.
     */
    public init(timestampStyle: TimestampStyle? = .Default, severityStyle: SeverityStyle? = .Simple, delimiterStyle: DelimiterStyle? = nil, showCallSite: Bool = true, showCallingThread: Bool = false, colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil)
    {
        var fields: [Field] = []
        var addSeparator = false

        if let timestampStyle = timestampStyle {
            fields += [.Timestamp(timestampStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .SpacedPipe)]
            addSeparator = false
        }
        if let severityStyle = severityStyle {
            fields += [.Severity(severityStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .SpacedPipe)]
            addSeparator = false
        }
        if showCallingThread {
            fields += [.CallingThread]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .SpacedPipe)]
            addSeparator = false
        }
        if showCallSite {
            fields += [.CallSite]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .SpacedHyphen)]
            addSeparator = false
        }
        fields += [.Payload]

        if colorizer == nil {
            super.init(fields: fields)
        }
        else {
            super.init(formatters: [ColorizingLogFormatter(formatter: FieldBasedLogFormatter(fields: fields), colorizer: colorizer!, colorTable: colorTable ?? DefaultColorTable())])
        }
    }
}
