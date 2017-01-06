//
//  ReadableLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/6/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` configured to be ideal for writing human-readable log files.

 By default, this formatter:

 - Uses `.default` as the `TimestampStyle`
 - Uses a custom `SeverityStyle` that pads the capitalized severity name
 - Uses `.hex` as the `CallingThreadStyle`
 - Uses default field separator delimiters
 - Outputs the source code filename and line number of the call site

 Each of these settings can be overridden during instantiation.
 */
open class ReadableLogFormatter: StandardLogFormatter
{
    /**
     Initializes a new `ReadableLogFormatter` instance.

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
    public override init(timestampStyle: TimestampStyle? = .default, severityStyle: SeverityStyle? = .custom(textRepresentation: .capitalized, truncateAtWidth: 7, padToWidth: 7, rightAlign: false), delimiterStyle: DelimiterStyle? = nil, callingThreadStyle: CallingThreadStyle? = .hex, showCallSite: Bool = true)
    {
        super.init(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: delimiterStyle, callingThreadStyle: callingThreadStyle, showCallSite: showCallSite)
    }
}
