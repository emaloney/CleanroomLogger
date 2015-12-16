//
//  ColorTable.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/16/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public protocol ColorTable
{
    func foregroundColorForSeverity(severity: LogSeverity) -> Color?

    func backgroundColorForSeverity(severity: LogSeverity) -> Color?

    func colorizeString(str: String, forSeverity severity: LogSeverity) -> String
}

extension ColorTable
{
    public func backgroundColorForSeverity(severity: LogSeverity)
        -> Color?
    {
        // by default, color tables only set a foreground color
        return nil
    }
}

extension ColorTable
{
    public func colorizeString(str: String, forSeverity severity: LogSeverity)
        -> String
    {
        let esc = "\u{001b}["

        var prefix = ""
        var suffix = ""
        if let fgColor = foregroundColorForSeverity(severity) {
            prefix += "\(esc)\(fgColor.foregroundColorDeclaration);"
            suffix = "\(esc);"
        }
        if let bgColor = backgroundColorForSeverity(severity) {
            prefix += "\(esc)\(bgColor.backgroundColorDeclaration);"
            suffix = "\(esc);"
        }

        return "\(prefix)\(str)\(suffix)"
    }
}
