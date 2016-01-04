//
//  FieldSeparatorLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct FieldSeparatorLogFormatter: LogFormatter
{
    private let separator: String

    public init()
    {
        separator = " | "
    }

    public init(separator: String)
    {
        self.separator = separator
    }

    public init(_ customSeparator: String?)
    {
        if let separator = customSeparator {
            self.init(separator: separator)
        } else {
            self.init()
        }
    }

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return separator
    }
}
