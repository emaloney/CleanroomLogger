//
//  XcodeLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` ideal for use within Xcode.

 By default, this formatter:

 - Uses `.default` as the default `TimestampStyle`
 - Uses `.xcode` as the default `SeverityStyle`
 - Uses default field separator delimiters
 - Outputs the call site 
 - Does not output the calling thread

 These defaults can be overridden by providing alternate values to the 
 initializer.
 */
open class XcodeLogFormatter: StandardLogFormatter
{
    /**
     Initializes a new `XcodeLogFormatter` instance.

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
     */
    public override init(timestampStyle: TimestampStyle? = .default, severityStyle: SeverityStyle? = .xcode, delimiterStyle: DelimiterStyle? = nil, showCallSite: Bool = true, showCallingThread: Bool = false)
    {
        super.init(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: delimiterStyle, showCallSite: showCallSite, showCallingThread: showCallingThread)
    }
}
