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
     Applies the specified foreground and background `Color`s to the passed-in
     string.

     - parameter str: The string to be colorized

     - parameter foreground: An optional foreground color to apply `str`.

     - parameter background: An optional background color to apply `str`.

     - returns:  A version of `str` with the appropriate color formatting
                 applied.
     */
    func colorizeString(str: String, foreground: Color?, background: Color?)
        -> String
}
