//
//  Log.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`LogFormatter`s are used to attempt to create string representations of
`LogEntry` instances.
*/
public protocol LogFormatter
{
    /**
    Called to create a string representation of the passed-in `LogEntry`.
    
    :param:     entry The `LogEntry` to attempt to convert into a string.
    
    :returns:   A `String` representation of `entry`, or `nil` if the
                receiver could not format the `LogEntry`.
    */
    func formatLogEntry(entry: LogEntry)
        -> String?
}
