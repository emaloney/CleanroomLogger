//
//  ASLLogRecorder.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 4/1/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomASL

extension LogSeverity
{
    public var aslPriorityLevel: ASLPriorityLevel {
        switch self {
        case .Verbose:      return .Debug
        case .Debug:        return .Info
        case .Info:         return .Notice
        case .Warning:      return .Warning
        case .Error:        return .Error
        }
    }
}

/**
The `ASLLogRecorder` is an implemention of the `LogRecorder` protocol that
records log entries to the Apple System Log (ASL) facility.
*/
public struct ASLLogRecorder: LogRecorder
{
    public let name: String
    public let formatters: [LogFormatter]
    public let client: ASLClient
    public var queue: dispatch_queue_t { return client.queue }

    public init()
    {
        self.init(name: "DefaultLogRecorder", formatter: DefaultLogFormatter())
    }

    public init(name: String)
    {
        self.init(name: name, formatter: DefaultLogFormatter())
    }

    public init(name: String, formatter: LogFormatter)
    {
        self.init(name: name, formatters: [formatter])
    }

    public init(name: String, formatters: [LogFormatter])
    {
        self.client = ASLClient()
        self.name = name
        self.formatters = formatters
    }

    public func recordFormattedString(str: String, forLogEntry entry: LogEntry)
    {
        // by default, NSLog() uses the ASL_LEVEL_WARNING priority;
        // we'll do the same since it's familiar to Cocoa developers
        let msg = ASLMessageObject(priorityLevel: .Warning, message: str)

        client.log(msg)
    }
}

