//
//  LogSeverity.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
Used to indicate the *severity*, or importance, of a log message.

Severity is a continuum, from `.Verbose` being least severe to `.Error` being
most severe.

The logging system may be configured so that messages lower than a given
severity are ignored.
*/
public enum LogSeverity: Int
{
    /** The lowest severity, used for detailed or frequently occurring
    debugging and diagnostic information. Not intended for use in production
    code. */
    case Verbose    = 1

    /** Used for debugging and diagnostic information. Not intended for use
    in production code. */
    case Debug      = 2

    /** Used to indicate something of interest that is not problematic. */
    case Info       = 3

    /** Used to indicate that something appears amiss and potentially
    problematic. The situation bears looking into before a larger problem
    arises. */
    case Warning    = 4

    /** The highest severity, used to indicate that something has gone wrong;
    a fatal error may be imminent. */
    case Error      = 5
}

extension LogSeverity: CustomStringConvertible
{
    /** Returns a human-readable textual representation of the receiver. */
    public var description: String {
        switch self {
        case Verbose:   return "Verbose"
        case Debug:     return "Debug"
        case Info:      return "Info"
        case Warning:   return "Warning"
        case Error:     return "Error"
        }
    }
}

/// :nodoc:
extension LogSeverity: Comparable {}

/// :nodoc:
public func <(lhs: LogSeverity, rhs: LogSeverity) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

