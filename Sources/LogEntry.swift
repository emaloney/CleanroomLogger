//
//  LogEntry.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/20/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Represents an entry to be written to the log.
 */
public struct LogEntry
{
    /** Represents the payload contained within a log entry. */
    public enum Payload
    {
        /** The log entry is a trace call and contains no explicit payload. */
        case trace

        /** The payload contains a text message. */
        case message(String)

        /** The payload contains an arbitrary value, or `nil`. */
        case value(Any?)
    }

    /** The payload of the log entry. */
    public let payload: Payload

    /** The severity of the log entry. */
    public let severity: LogSeverity

    /** The path of the source file containing the calling function that issued
     the log request. */
    public let callingFilePath: String

    /** The line within the source file at which the log request was issued. */
    public let callingFileLine: Int

    /** The stack frame signature of the caller that issued the log request. */
    public let callingStackFrame: String

    /** The ID that uniquely identifies the calling thread during its lifetime.
     After a thread dies, its ID is no longer meaningful; over time, thread IDs
     are recycled. */
    public let callingThreadID: UInt64

    /** The time at which the `LogEntry` was created. */
    public let timestamp: Date
    
    /** The name by which the currently executing process is known to the
     operating system. */
    public let processName: String
    
    /** The ID that uniquely identifies the executing process during its
     lifetime. After a process exits, its ID is no longer meaningful; over 
     time, process IDs are recycled. */
    public let processID: Int32

    /**
     `LogEntry` initializer.
     
     - parameter payload: The payload of the `LogEntry` being constructed.
     
     - parameter severity: The `LogSeverity` of the message being logged.
     
     - parameter callingFilePath: The path of the source file containing the
     calling function that issued the log request.
     
     - parameter callingFileLine: The line within the source file at which the
     log request was issued.
     
     - parameter callingStackFrame: The stack frame signature of the caller
     that issued the log request.
     
     - parameter callingThreadID: A numeric identifier for the calling thread.
     Note that thread IDs are recycled over time.
     
     - parameter timestamp: The time at which the log entry was created. 
     Defaults to the current time if not explicitly specified.
     */
    public init(payload: Payload, severity: LogSeverity, callingFilePath: String, callingFileLine: Int, callingStackFrame: String, callingThreadID: UInt64, timestamp: Date = Date())
    {
        self.payload = payload
        self.severity = severity
        self.callingFilePath = callingFilePath
        self.callingFileLine = callingFileLine
        self.callingStackFrame = callingStackFrame
        self.callingThreadID = callingThreadID
        self.timestamp = timestamp
        self.processName = ProcessIdentification.current.processName
        self.processID = ProcessIdentification.current.processID
    }
}

fileprivate struct ProcessIdentification
{
    // this ensures we only look up process info once
    public static let current = ProcessIdentification()
    
    public let processName: String
    public let processID: Int32

    private init()
    {
        let process = ProcessInfo.processInfo
        processName = process.processName
        processID = process.processIdentifier
    }
}
