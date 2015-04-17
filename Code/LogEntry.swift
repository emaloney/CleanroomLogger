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
    enum Payload
    {
        /** The log entry is a trace call and contains no explicit payload. */
        case Trace

        /** The payload contains a text message. */
        case Message(String)

        /** The payload contains arbitrary data. */
        case Data(Any)
    }

    /** The payload of the log entry. */
    let payload: Payload

    /** The severity of the log entry. */
    let severity: LogSeverity

    /** The signature of the function that issued the log request. */
    let callingFunction: String

    /** The path of the source file containing the calling function that issued
    the log request. */
    let callingFilePath: String

    /** The line within the source file at which the log request was issued. */
    let callingFileLine: Int

    /** A numeric identifier for the calling thread. Note that thread IDs are
    recycled over time. */
    let callingThreadID: Int
}
