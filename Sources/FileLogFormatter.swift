//
//  FileLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public class FileLogFormatter: StandardLogFormatter
{
    public override init(timestampStyle: TimestampStyle? = .UNIX, severityStyle: SeverityStyle? = .Numeric, delimiterStyle: DelimiterStyle? = .Tab, showCallSite: Bool = true, showCallingThread: Bool = true, colorizer: TextColorizer? = nil, colorTable: ColorTable? = nil)
    {
        super.init(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: delimiterStyle, showCallSite: showCallSite, showCallingThread: showCallingThread, colorizer: colorizer, colorTable: colorTable)
    }
}
