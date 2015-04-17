//
//  LogSeverity.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

public enum LogSeverity: Int
{
    case Verbose    = 1
    case Debug      = 2
    case Info       = 3
    case Warning    = 4
    case Error      = 5
}

extension LogSeverity
{
    public enum Comparator
    {
        case LessSevereThan
        case AsOrLessSevereThan
        case EqualToSeverityOf
        case AsOrMoreSevereThan
        case MoreSevereThan

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
    
    public func compare(comparator: Comparator, against severity: LogSeverity)
        -> Bool
    {
        return comparator.compare(self, against: severity)
    }
}

extension LogSeverity: DebugPrintableEnum
{
    public var description: String { return EnumPrinter.description(self) }

    public var debugDescription: String { return EnumPrinter.debugDescription(self) }

    public var printableEnumName: String { return "LogSeverity" }

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

