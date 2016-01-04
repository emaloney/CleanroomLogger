//
//  ColorizingLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct ColorizingLogFormatter: LogFormatter
{
    public let formatter: LogFormatter
    public let colorizer: Colorizer
    public let colorTable: ColorTable

    public init(formatter: LogFormatter, colorizer: Colorizer, colorTable: ColorTable? = nil)
    {
        self.formatter = formatter
        self.colorizer = colorizer
        self.colorTable = colorTable ?? DefaultColorTable()
    }

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        guard let str = formatter.formatLogEntry(entry) else {
            return nil
        }

        let fg = colorTable.foregroundColorForSeverity(entry.severity)
        let bg = colorTable.backgroundColorForSeverity(entry.severity)

        return colorizer.colorizeString(str, foreground: fg, background: bg)
    }
}
