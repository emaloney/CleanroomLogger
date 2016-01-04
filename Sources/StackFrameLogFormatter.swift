//
//  StackFrameLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct StackFrameLogFormatter: LogFormatter
{
    public init() {}

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return entry.callingStackFrame
    }
}
