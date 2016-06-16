//
//  ColorTable.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/16/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 `ColorTable`s are used to supply foreground and background `Color` values
 for a given `LogSeverity`.
 */
public protocol ColorTable
{
    /**
     Returns the foreground color to use (if any) for colorizing messages
     at the given `LogSeverity`.
     
     - parameter severity: The `LogSeverity` whose color information is
                 being retrieved.

     - returns: The foreground `Color` to use for `severity`, or `nil` if no
                color is specified.
    */
    func foreground(forSeverity severity: LogSeverity) -> Color?

    /**
     Returns the background color to use (if any) for colorizing messages
     at the given `LogSeverity`.
     
     - parameter severity: The `LogSeverity` whose color information is
                 being retrieved.
     
     - returns: The background `Color` to use for `severity`, or `nil` if no
                color is specified.
    */
    func background(forSeverity severity: LogSeverity) -> Color?
}

extension ColorTable
{
    /**
     A default function implementation to always return `nil` indicating
     that no background color information is specified. By default, 
     `ColorTable` implementations only supply foreground color information.
     
     - parameter severity: The `LogSeverity` whose color information is
                 being retrieved.
     
     - returns: Always `nil`.
    */
    public func background(forSeverity severity: LogSeverity)
        -> Color?
    {
        return nil
    }
}
