//
//  TextColorizer.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 `TextColorizer`s are used to apply color formatting to log messages.
 */
public protocol TextColorizer
{
    /**
     Applies the specified foreground and background `Color`s to the passed-in
     string.

     - parameter string: The string to be colorized.

     - parameter foreground: An optional foreground color to apply to `string`.

     - parameter background: An optional background color to apply to `string`.

     - returns: A version of `string` with the appropriate color formatting
     applied.
     */
    func colorize(_ str: String, foreground: Color?, background: Color?) -> String
}
