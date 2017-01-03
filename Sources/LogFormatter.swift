//
//  LogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 `LogFormatter`s are used to attempt to create string representations of
 `LogEntry` instances.
 */
public protocol LogFormatter
{
    /**
     Called to create a string representation of the passed-in `LogEntry`.
     
     - parameter entry: The `LogEntry` to attempt to convert into a string.
     
     - returns:  A `String` representation of `entry`, or `nil` if the
     receiver could not format the `LogEntry`.
     */
    func format(_ entry: LogEntry) -> String?
}
