//
//  DefaultColorTable.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/16/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public struct DefaultColorTable: ColorTable
{
    public static let VerboseColor  = Color(r: 0x99, g: 0x99, b: 0x99)
    public static let DebugColor    = Color(r: 0x66, g: 0x66, b: 0x66)
    public static let InfoColor     = Color(r: 0x00, g: 0x00, b: 0xCC)
    public static let WarningColor  = Color(r: 0xDD, g: 0x77, b: 0x22)
    public static let ErrorColor    = Color(r: 0xCC, g: 0x00, b: 0x00)

    public init?()
    {
        let env = getenv("XcodeColors")

        guard env != nil else {
            return nil
        }

        guard let str = String.fromCString(env) else {
            return nil
        }

        guard str == "YES" else {
            return nil
        }
    }

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
