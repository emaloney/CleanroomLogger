//
//  StandardLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A standard `LogFormatter` that provides some common customization points.
 */
open class StandardLogFormatter: FieldBasedLogFormatter
{
    /**
     Initializes a new `StandardLogFormatter` instance.

     - parameter timestampStyle: Governs the formatting of the timestamp in the
     log output. Pass `nil` to suppress output of the timestamp.

     - parameter severityStyle: Governs the formatting of the `LogSeverity` in
     the log output. Pass `nil` to suppress output of the severity.

     - parameter delimiterStyle: If provided, overrides the default field
     separator delimiters. Pass `nil` to use the default delimiters.
     
     - parameter callingThreadStyle: If provided, specifies a 
     `CallingThreadStyle` to use for representing the calling thread. If `nil`,
     the calling thread is not shown.

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.
     */
    public init(timestampStyle: TimestampStyle? = .default, severityStyle: SeverityStyle? = .simple, delimiterStyle: DelimiterStyle? = nil, callingThreadStyle: CallingThreadStyle? = .hex, showCallSite: Bool = true)
    {
        var fields: [Field] = []
        var addSeparator = false

        if let timestampStyle = timestampStyle {
            fields += [.timestamp(timestampStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.delimiter(delimiterStyle ?? .spacedPipe)]
            addSeparator = false
        }
        if let severityStyle = severityStyle {
            fields += [.severity(severityStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.delimiter(delimiterStyle ?? .spacedPipe)]
            addSeparator = false
        }
        if let callingThreadStyle = callingThreadStyle {
            fields += [.callingThread(callingThreadStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.delimiter(delimiterStyle ?? .spacedPipe)]
            addSeparator = false
        }
        if showCallSite {
            fields += [.callSite]
            addSeparator = true
        }
        if addSeparator {
            fields += [.delimiter(delimiterStyle ?? .spacedHyphen)]
            addSeparator = false
        }
        fields += [.payload]

        super.init(fields: fields)
    }
}
