//
//  LogSeverity.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
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
    
    /**
    A convenience function to determine the minimum `LogSeverity` value to
    use by default, based on whether or not the application was compiled
    with debugging turned on.
    
    :param:     minimumForDebugMode The `LogSeverity` value to return when
                `isInDebugMode` is `true`.
    
    :param:     isInDebugMode Defaults to `false`. Pass the value `(DEBUG != 0)`
                to ensure the correct value for your build.
    */
    public static func defaultMinimumSeverity(minimumForDebugMode: LogSeverity = .Debug, isInDebugMode: Bool = false)
        -> LogSeverity
    {
        if isInDebugMode {
            return minimumForDebugMode
        } else {
            return .Info
        }
    }
}

/// :nodoc:
extension LogSeverity: Comparable {}

/// :nodoc:
public func <(lhs: LogSeverity, rhs: LogSeverity) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

/// :nodoc:
extension LogSeverity // DebugPrintableEnum
{
//    /// :nodoc:
//    public var description: String { return EnumPrinter.description(self) }
//
//    /// :nodoc:
//    public var debugDescription: String { return EnumPrinter.debugDescription(self) }

    /// :nodoc:
    public var printableEnumName: String { return "LogSeverity" }

    /// :nodoc:
    public var printableValueName: String {
        switch self {
        case Verbose:   return "Verbose"
        case Debug:     return "Debug"
        case Info:      return "Info"
        case Warning:   return "Warning"
        case Error:     return "Error"
        }
    }
}

