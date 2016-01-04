//
//  CallingThreadLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct CallingThreadLogFormatter: LogFormatter
{
    public init() {}

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return NSString(format: "%08X", entry.callingThreadID) as String
    }
}
