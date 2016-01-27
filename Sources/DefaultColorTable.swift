//
//  DefaultColorTable.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/16/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 A default implementation of the `ColorTable` protocol.
 */
public struct DefaultColorTable: ColorTable
{
    /** A light gray `Color` (`#999999`) used as the foreground color
     for the `.Verbose` severity. */
    public static let VerboseColor  = Color(r: 0x99, g: 0x99, b: 0x99)

    /** A dark gray `Color` (`#666666`) used as the foreground color
     for the `.Debug` severity. */
    public static let DebugColor    = Color(r: 0x66, g: 0x66, b: 0x66)

    /** A blue `Color` (`#0000CC`) used as the foreground color
     for the `.Info` severity. */
    public static let InfoColor     = Color(r: 0x00, g: 0x00, b: 0xCC)

    /** An orange `Color` (`#DD7722`) used as the foreground color
     for the `.Warning` severity. */
    public static let WarningColor  = Color(r: 0xDD, g: 0x77, b: 0x22)

    /** A red `Color` (`#CC0000`) used as the foreground color
     for the `.Error` severity. */
    public static let ErrorColor    = Color(r: 0xCC, g: 0x00, b: 0x00)

    /**
     Returns the foreground color to use (if any) for colorizing messages
     at the given `LogSeverity`.
     
     - parameter severity: The `LogSeverity` whose color information is
                 being retrieved.

     - returns:  The foreground `Color` to use for `severity`, or `nil` if no
                 color is specified.
    */
    public func foregroundColorForSeverity(severity: LogSeverity)
        -> Color?
    {
        switch severity {
        case .Verbose:      return self.dynamicType.VerboseColor
        case .Debug:        return self.dynamicType.DebugColor
        case .Info:         return self.dynamicType.InfoColor
        case .Warning:      return self.dynamicType.WarningColor
        case .Error:        return self.dynamicType.ErrorColor
        }
    }
}
