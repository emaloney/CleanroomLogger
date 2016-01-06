//
//  StandardLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public class StandardLogFormatter: FieldBasedLogFormatter
{
    public init(timestampStyle: TimestampStyle?, severityStyle: SeverityStyle?, delimiterStyle: DelimiterStyle? = nil, showCallSite: Bool, showCallingThread: Bool, colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil)
    {
        var fields: [Field] = []
        var addSeparator = false

        if let timestampStyle = timestampStyle {
            fields += [.Timestamp(timestampStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .Pipe)]
            addSeparator = false
        }
        if let severityStyle = severityStyle {
            fields += [.Severity(severityStyle)]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .Pipe)]
            addSeparator = false
        }
        if showCallingThread {
            fields += [.CallingThread]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .Pipe)]
            addSeparator = false
        }
        if showCallSite {
            fields += [.CallSite]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Delimiter(delimiterStyle ?? .Hyphen)]
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

    public init(fields: [Field], colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil)
    {
        if colorizer == nil {
            super.init(fields: fields)
        }
        else {
            super.init(formatters: [ColorizingLogFormatter(formatter: FieldBasedLogFormatter(fields: fields), colorizer: colorizer!, colorTable: colorTable ?? DefaultColorTable())])
        }
    }
}
