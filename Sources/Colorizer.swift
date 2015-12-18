//
//  Colorizer.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 `Colorizer`s are used to apply color formatting to log messages.
 */
public protocol Colorizer
{
    /**
     Applies the color formatting appropriate for the given `LogSeverity` to
     the passed-in string.
     
     - parameter str: The string to be formatted
     
     - parameter severity: The log severity
     
     - parameter colorTable: A `ColorTable` whose color settings will be used
                 to format the message
     
     - returns:  A version of `str` with the appropriate color formatting
                 applied.
    */
    func colorizeString(str: String, forSeverity severity: LogSeverity, usingColorTable colorTable: ColorTable)
        -> String
}
