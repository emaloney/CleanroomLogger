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
    public init(showTimestamp: Bool, showCallSite: Bool, showCallingThread: Bool, showSeverity: Bool, customFieldSeparator: String? = nil, colorizer: Colorizer? = nil, colorTable: ColorTable? = nil)
    {
        var fields: [Field] = []
        var addSeparator = false

        if showTimestamp {
            fields += [.Timestamp]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Separator]
            addSeparator = false
        }
        if showSeverity {
            fields += [.Severity]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Separator]
            addSeparator = false
        }
        if showCallingThread {
            fields += [.CallingThread]
            addSeparator = true
        }
        if addSeparator {
            fields += [.Separator]
            addSeparator = false
        }
        if showCallSite {
            fields += [.CallSite]
            addSeparator = true
        }
        if addSeparator {
            fields += [customFieldSeparator != nil ? .Separator : .Literal(" - ")]
            addSeparator = false
        }
        fields += [.Payload]

        if colorizer == nil {
            super.init(fields: fields, customFieldSeparator: customFieldSeparator)
        }
        else {
            super.init(formatters: [ColorizingLogFormatter(formatter: FieldBasedLogFormatter(fields: fields, customFieldSeparator: customFieldSeparator), colorizer: colorizer!, colorTable: colorTable ?? DefaultColorTable())])
        }
    }

    public init(fields: [Field], customFieldSeparator: String? = nil, colorizer: Colorizer? = nil, colorTable: ColorTable? = nil)
    {
        if colorizer == nil {
            super.init(fields: fields, customFieldSeparator: customFieldSeparator)
        }
        else {
            super.init(formatters: [ColorizingLogFormatter(formatter: FieldBasedLogFormatter(fields: fields, customFieldSeparator: customFieldSeparator), colorizer: colorizer!, colorTable: colorTable ?? DefaultColorTable())])
        }
    }
}
