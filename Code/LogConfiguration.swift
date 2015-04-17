//
//  LogConfiguration.swift
//  Cleanroom
//
//  Created by Evan Maloney on 3/30/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public struct LogConfiguration
{
    public let severity: LogSeverity
    public let filters: [LogFilter]
    public let recorders: [LogRecorder]
    public let synchronousMode: Bool
}
