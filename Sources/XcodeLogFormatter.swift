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
    public override init(showTimestamp: Bool = true, showCallSite: Bool = true, showCallingThread: Bool = false, showSeverity: Bool = true, customFieldSeparator: String? = nil, colorizer: Colorizer? = XcodeColorsColorizer(), colorTable: ColorTable? = nil)
    {
        super.init(showTimestamp: showTimestamp, showCallSite: showCallSite, showCallingThread: showCallingThread, showSeverity: showSeverity, customFieldSeparator: customFieldSeparator, colorizer: colorizer, colorTable: colorTable)
    }
}
