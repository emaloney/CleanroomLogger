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
     for the `.verbose` severity. */
    public static let verboseColor  = Color(r: 0x99, g: 0x99, b: 0x99)

    /** A dark gray `Color` (`#666666`) used as the foreground color
     for the `.debug` severity. */
    public static let debugColor    = Color(r: 0x66, g: 0x66, b: 0x66)

    /** A blue `Color` (`#0000CC`) used as the foreground color
     for the `.info` severity. */
    public static let infoColor     = Color(r: 0x00, g: 0x00, b: 0xCC)

    /** An orange `Color` (`#DD7722`) used as the foreground color
     for the `.warning` severity. */
    public static let warningColor  = Color(r: 0xDD, g: 0x77, b: 0x22)

    /** A red `Color` (`#CC0000`) used as the foreground color
     for the `.error` severity. */
    public static let errorColor    = Color(r: 0xCC, g: 0x00, b: 0x00)

    /**
     Returns the foreground color to use (if any) for colorizing messages
     at the given `LogSeverity`.
     
     - parameter severity: The `LogSeverity` whose color information is
                 being retrieved.

     - returns:  The foreground `Color` to use for `severity`, or `nil` if no
                 color is specified.
    */
    public func foreground(forSeverity severity: LogSeverity)
        -> Color?
    {
        switch severity {
        case .verbose:      return self.dynamicType.verboseColor
        case .debug:        return self.dynamicType.debugColor
        case .info:         return self.dynamicType.infoColor
        case .warning:      return self.dynamicType.warningColor
        case .error:        return self.dynamicType.errorColor
        }
    }
}
