//
//  CallSiteLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public struct CallSiteLogFormatter: LogFormatter
{
    public init() {}

    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        let file = (entry.callingFilePath as NSString).pathComponents.last ?? "(unknown)"
        return "\(file):\(entry.callingFileLine)"
    }
}
