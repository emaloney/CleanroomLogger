//
//  StringTrimExtension.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 2/19/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
A `String` extension that adds a `trim()` function for removing leading and
trailing whitespace.
*/
public extension String
{
    /**
    Returns a version of the receiver with whitespace and newline characters
    removed from the beginning and end of the string.
    
    :returns:       A trimmed version of the receiver.
    */
    public func trim()
        -> String
    {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}