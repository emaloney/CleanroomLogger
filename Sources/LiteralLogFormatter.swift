//
//  LiteralLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct LiteralLogFormatter: LogFormatter
{
    private let literal: String

    public init(_ string: String)
    {
        literal = string
    }

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return literal
    }
}
