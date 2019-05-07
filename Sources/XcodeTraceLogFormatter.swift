//
//  XcodeTraceLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that outputs Xcode-bound trace information for each
 `LogEntry` that has a `Payload` of `.trace`.
 */
public final class XcodeTraceLogFormatter: FieldBasedLogFormatter
{
    /** 
     Initalizes a new `XcodeTraceLogFormatter` instance.
     */
    public init()
    {
        super.init(fields: [.severity(.xcode),
                            .literal(" —> "),
                            .callSite,
                            .delimiter(.spacedHyphen),
                            .payload])
    }
    
    /**
     Called to create a string representation of the passed-in `LogEntry`.
     
     - parameter entry: The `LogEntry` to attempt to convert into a string.
     
     - returns:  A `String` representation of `entry`, or `nil` if the
     receiver could not format the `LogEntry`.
     */
    public override func format(_ entry: LogEntry)
        -> String?
    {
        guard case .trace = entry.payload else {
            // we are only to be used for outputting trace information
            return nil
        }
        
        return super.format(entry)
    }
}
