//
//  ParsableLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/6/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` configured to be ideal for writing machine-parsable log files.
 
 By default, this formatter:
 
 - Uses `.unix` as the `TimestampStyle`
 - Uses `.numeric` as the `SeverityStyle`
 - Uses `.hex` as the `CallingThreadStyle`
 - Uses `.tab` as the `DelimiterStyle`
 - Outputs the source code filename and line number of the call site
 
 Each of these settings can be overridden during instantiation.
 */
open class ParsableLogFormatter: StandardLogFormatter
{
    /**
     Initializes a new `ParsableLogFormatter` instance.

     - parameter timestampStyle: Governs the formatting of the timestamp in the
     log output. Pass `nil` to suppress output of the timestamp.

     - parameter severityStyle: Governs the formatting of the `LogSeverity` in
     the log output. Pass `nil` to suppress output of the severity.

     - parameter callingThreadStyle: If provided, specifies a
     `CallingThreadStyle` to use for representing the calling thread. If `nil`,
     the calling thread is not shown.

     - parameter delimiterStyle: If provided, overrides the default field
     separator delimiters. Pass `nil` to use the default delimiters.

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.
     */
    public override init(timestampStyle: TimestampStyle? = .unix, severityStyle: SeverityStyle? = .numeric, delimiterStyle: DelimiterStyle? = .tab, callingThreadStyle: CallingThreadStyle? = .hex, showCallSite: Bool = true)
    {
        super.init(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: delimiterStyle, callingThreadStyle: callingThreadStyle, showCallSite: showCallSite)
    }
}
