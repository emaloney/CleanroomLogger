//
//  ConcatenatingLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public class ConcatenatingLogFormatter: LogFormatter
{
    public let formatters: [LogFormatter]

    public init(formatters: [LogFormatter])
    {
        self.formatters = formatters
    }

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        let formatted = formatters.flatMap{ $0.formatLogEntry(entry) }

        guard formatted.count > 0 else {
            return nil
        }

        return formatted.joinWithSeparator("")
    }
}

