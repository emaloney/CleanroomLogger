//
//  XcodeColorsColorizer.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `Colorizer` implementation that applies 
 [XcodeColors](https://github.com/robbiehanson/XcodeColors/)-compatible 
 formatting to log messages.
 */
public struct XcodeColorsColorizer: Colorizer
{
    /**
     Initializes a new instance if and only if XcodeColors is installed and
     enabled, as indicated by the presence of the `XcodeColors` environment
     variable. (Unless the value of this variable is the string `YES`, this
     initializer will fail.)
    */
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

    /**
     Applies XcodeColors-style formatting appropriate for the given
     `LogSeverity` to the passed-in string.

     - parameter str: The string to be formatted

     - parameter severity: The log severity

     - parameter colorTable: A `ColorTable` whose color settings will be used
                 to format the message

     - returns:  A version of `str` with the appropriate color formatting
                 applied.
     */
    public func colorizeString(str: String, forSeverity severity: LogSeverity, usingColorTable colorTable: ColorTable)
        -> String
    {
        let esc = "\u{001b}["

        var prefix = ""
        var suffix = ""
        if let fgColor = colorTable.foregroundColorForSeverity(severity) {
            prefix += "\(esc)\(fgColor.asXcodeColorsForegroundString);"
            suffix = "\(esc);"
        }
        if let bgColor = colorTable.backgroundColorForSeverity(severity) {
            prefix += "\(esc)\(bgColor.asXcodeColorsbackgroundString);"
            suffix = "\(esc);"
        }

        return "\(prefix)\(str)\(suffix)"
    }
}

extension Color
{
    /// A comma-separated string representation of the red, green and blue
    /// components of the color in base-10 integers.
    private var asXcodeColorsString: String {
        return "\(r),\(g),\(b)"
    }

    /// An XcodeColors-style string representation usable as a foreground color.
    private var asXcodeColorsForegroundString: String {
        return "fg\(asXcodeColorsString)"
    }

    /// An XcodeColors-style string representation usable as a background color.
    private var asXcodeColorsbackgroundString: String {
        return "bg\(asXcodeColorsString)"
    }
}

