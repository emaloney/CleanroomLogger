//
//  SeverityLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct SeverityLogFormatter: LogFormatter
{
    private let uppercase: Bool
    private let padToWidth: Int
    private let rightAlign: Bool

    public init(uppercase: Bool = true, padToWidth: Int = 7, rightAlign: Bool = true)
    {
        self.uppercase = uppercase
        self.padToWidth = padToWidth
        self.rightAlign = rightAlign
    }

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        var severityTag = entry.severity.printableValueName
        if uppercase {
            severityTag = severityTag.uppercaseString
        }
        if padToWidth > 0 {
            while severityTag.utf16.count < padToWidth {
                if rightAlign {
                    severityTag = " " + severityTag
                } else {
                    severityTag += " "
                }
            }
        }
        return severityTag
    }
}
