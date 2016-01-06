//
//  XcodeLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public class XcodeLogFormatter: StandardLogFormatter
{
    public override init(timestampStyle: TimestampStyle? = .Default, severityStyle: SeverityStyle? = .Xcode, delimiterStyle: DelimiterStyle? = nil, showCallSite: Bool = true, showCallingThread: Bool = false, colorizer: TextColorizer? = XcodeColorsTextColorizer(), colorTable: ColorTable? = nil)
    {
        super.init(timestampStyle: timestampStyle, severityStyle: severityStyle, delimiterStyle: delimiterStyle, showCallSite: showCallSite, showCallingThread: showCallingThread, colorizer: colorizer, colorTable: colorTable)
    }
}
