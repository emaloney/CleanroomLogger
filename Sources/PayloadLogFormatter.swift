//
//  PayloadLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct PayloadLogFormatter: LogFormatter
{
    public init() {}

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        switch entry.payload {
        case .Trace:                return entry.callingStackFrame
        case .Message(let msg):     return msg
        case .Value(let value):     return "\(value)"
        }
    }
}
