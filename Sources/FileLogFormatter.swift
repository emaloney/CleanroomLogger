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
    public override init(showTimestamp: Bool = true, showCallSite: Bool = true, showCallingThread: Bool = true, showSeverity: Bool = true, customFieldSeparator: String? = nil, colorizer: Colorizer? = nil, colorTable: ColorTable? = nil)
    {
        super.init(showTimestamp: showTimestamp, showCallSite: showCallSite, showCallingThread: showCallingThread, showSeverity: showSeverity, customFieldSeparator: customFieldSeparator, colorizer: colorizer, colorTable: colorTable)
    }
}
