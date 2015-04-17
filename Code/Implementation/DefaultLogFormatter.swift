//
//  DefaultLogFormatter.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public struct DefaultLogFormatter: LogFormatter
{
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        var severityTag = entry.severity.printableValueName.uppercaseString
        while count(severityTag.utf16) < 10 {
            severityTag = " " + severityTag
        }

        let file = entry.callingFilePath.pathComponents.last ?? "(unknown)"
        let line = entry.callingFileLine
        let message: String

        switch entry.payload {
        case .Trace:            message = entry.callingFunction
        case .Message(let msg): message = msg
        case .Data(let data):   message = "\(data)"
        }

        return "\(severityTag) | \(file):\(line) — \(message)"
    }
}
