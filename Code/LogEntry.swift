//
//  LogEntry.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/20/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
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
        case Trace

        /** The payload contains a text message. */
        case Message(String)

        /** The payload contains an arbitrary value, or `nil`. */
        case Value(Any?)
    }

    /** The payload of the log entry. */
    public let payload: Payload

    /** The severity of the log entry. */
    public let severity: LogSeverity

    /** The signature of the function that issued the log request. */
    public let callingFunction: String

    /** The path of the source file containing the calling function that issued
    the log request. */
    public let callingFilePath: String

    /** The line within the source file at which the log request was issued. */
    public let callingFileLine: Int

    /** A numeric identifier for the calling thread. Note that thread IDs are
    recycled over time. */
    public let callingThreadID: UInt64

    /** The time at which the `LogEntry` was created. */
    public let timestamp: NSDate

    /**
    `LogEntry` initializer.
    
    - parameter     payload: The payload of the `LogEntry` being constructed.
    
    - parameter     severity: The `LogSeverity` of the message being logged.
    
    - parameter     callingFunction: The signature of the function that issued the 
                log request.
    
    - parameter     callingFilePath: The path of the source file containing the 
                calling function that issued the log request.
    
    - parameter     callingFileLine: The line within the source file at which the log
                request was issued.

    - parameter     callingThreadID: A numeric identifier for the calling thread. 
                Note that thread IDs are recycled over time.
    
    - parameter     timestamp: The time at which the log entry was created. Defaults
                to the current time if not specified.
    */
    public init(payload: Payload, severity: LogSeverity, callingFunction: String, callingFilePath: String, callingFileLine: Int, callingThreadID: UInt64, timestamp: NSDate = NSDate())
    {
        self.payload = payload
        self.severity = severity
        self.callingFunction = callingFunction
        self.callingFilePath = callingFilePath
        self.callingFileLine = callingFileLine
        self.callingThreadID = callingThreadID
        self.timestamp = timestamp
    }
}
