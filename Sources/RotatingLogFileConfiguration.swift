//
//  RotatingLogFileConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public class RotatingLogFileConfiguration: BasicLogConfiguration
{
    public init(minimumSeverity: LogSeverity, daysToKeep: Int, directoryPath: String, synchronousMode: Bool = false, formatters: [LogFormatter] = [FileLogFormatter()], filters: [LogFilter] = [])
    {
        let recorder = RotatingLogFileRecorder(daysToKeep: daysToKeep, directoryPath: directoryPath)

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: [recorder], synchronousMode: synchronousMode)
    }
}
