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
 
 - Uses `.UNIX` as the default `TimestampStyle`
 - Uses `.Numeric` as the default `SeverityStyle`
 - Uses `.Tab` as the default `DelimiterStyle`
 - Outputs the call site and calling thread
 - Does not perform text colorization
 
 These defaults can be overridden during instantiation.
 */
public class ParsableLogFormatter: StandardLogFormatter
{
    /**
     Initializes a new `ParsableLogFormatter` instance.

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
    public override init(timestampStyle: TimestampStyle? = .UNIX, severityStyle: SeverityStyle? = .Numeric, delimiterStyle: DelimiterStyle? = .Tab, showCallSite: Bool = true, showCallingThread: Bool = true, colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil)
    {
        super.init(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: delimiterStyle, showCallSite: showCallSite, showCallingThread: showCallingThread, colorizer: colorizer, colorTable: colorTable)
    }
}
