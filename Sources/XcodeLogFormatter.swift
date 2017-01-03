//
//  XcodeLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` ideal for use within Xcode. This format is not well-suited
 for parsing.
 */
public final class XcodeLogFormatter: LogFormatter
{
    private let traceFormatter: XcodeTraceLogFormatter
    private let defaultFormatter: FieldBasedLogFormatter
    
    /**
     Initializes a new `XcodeLogFormatter` instance.

     - parameter showCallSite: If `true`, the source file and line indicating
     the call site of the log request will be added to formatted log messages.
     */
    public init(showCallSite: Bool = true)
    {
        traceFormatter = XcodeTraceLogFormatter()
        
        var fields: [FieldBasedLogFormatter.Field] = []
        fields.append(.severity(.xcode))
        fields.append(.delimiter(.space))
        fields.append(.payload)
        if showCallSite {
            fields.append(.literal(" ("))
            fields.append(.callSite)
            fields.append(.literal(")"))
        }

        defaultFormatter = FieldBasedLogFormatter(fields: fields)
    }
    
    /**
     Called to create a string representation of the passed-in `LogEntry`.
     
     - parameter entry: The `LogEntry` to attempt to convert into a string.
     
     - returns:  A `String` representation of `entry`, or `nil` if the
     receiver could not format the `LogEntry`.
     */
    open func format(_ entry: LogEntry) -> String?
    {
        return traceFormatter.format(entry) ?? defaultFormatter.format(entry)
    }
}
