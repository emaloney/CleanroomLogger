//
//  LogSeverity.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

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
    The `LogSeverity.Comparator` is used to compare `LogSeverity` values.
    */
    public enum Comparator
    {
        /** Represents a comparator whose `compare()` function will return
        `true` when the value of the `lVal` argument is less severe than that
        of the `rVal` argument. */
        case LessSevereThan

        /** Represents a comparator whose `compare()` function will return
        `true` when the value of the `lVal` argument is as or less severe than
        that of the `rVal` argument. */
        case AsOrLessSevereThan

        /** Represents a comparator whose `compare()` function will return
        `true` when the value of the `lVal` argument is equal to that of the
        `rVal` argument. */
        case EqualToSeverityOf

        /** Represents a comparator whose `compare()` function will return
        `true` when the value of the `lVal` argument is as or more severe than
        that of the `rVal` argument. */
        case AsOrMoreSevereThan

        /** Represents a comparator whose `compare()` function will return
        `true` when the value of the `lVal` argument is more severe than
        that of the `rVal` argument. */
        case MoreSevereThan

        /**
        Executes the function represented by the comparator using the
        specified `lVal` and `rVal` arguments.
        
        :param:     lVal The lefthand value for the comparison
        
        :param:     rVal The righthand value for the comparison
        
        :returns:   The result of the comparison given the values `lVal` and
                    `rVal`.
        */
        public func compare(lVal: LogSeverity, against rVal: LogSeverity)
            -> Bool
        {
            switch self {
            case LessSevereThan:
                return lVal.rawValue < rVal.rawValue

            case AsOrLessSevereThan:
                return lVal.rawValue <= rVal.rawValue

            case EqualToSeverityOf:
                return lVal.rawValue == rVal.rawValue

            case AsOrMoreSevereThan:
                return lVal.rawValue >= rVal.rawValue
                
            case MoreSevereThan:
                return lVal.rawValue > rVal.rawValue
            }
        }
    }

    /**
    Compares the receiver against another `LogSeverity` value using the given
    comparator.

    :param:     comparator The `LogSeverity.Comparator` to use for the 
                comparison.
    
    :param:     severity The `LogSeverity` value being compared against the
                receiver. This value represents the righthand value in the
                comparison, while the receiver represents the lefthand value.
    
    :returns:   The result of the comparison.
    */
    public func compare(comparator: Comparator, against severity: LogSeverity)
        -> Bool
    {
        return comparator.compare(self, against: severity)
    }

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
extension LogSeverity: DebugPrintableEnum
{
    /// :nodoc:
    public var description: String { return EnumPrinter.description(self) }

    /// :nodoc:
    public var debugDescription: String { return EnumPrinter.debugDescription(self) }

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

