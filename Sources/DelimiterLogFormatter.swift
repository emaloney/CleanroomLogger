//
//  DelimiterLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Allows the specification of different field delimiters.
 */
public enum DelimiterStyle
{
    /** Specifies a pipe character with a space character on either side. */
    case Pipe

    /** Specifies a hyphen character with a space character on either side. */
    case Hyphen

    /** Specifies the tab character: ASCII 0x09. */
    case Tab

    /** Specifies a custom field delimiters. */
    case Custom(String)
}

public extension DelimiterStyle
{
    /**
     Returns the field delimiter string indicated by the receiver's value.
     */
    public var delimiter: String {
        switch self {
        case .Pipe:             return " | "
        case .Hyphen:           return " - "
        case .Tab:              return "\t"
        case .Custom(let sep):  return sep
        }
    }
}

/**
 A `LogFormatter` used to output field separator strings.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct DelimiterLogFormatter: LogFormatter
{
    /** The `DelimiterStyle` that determines the return value of the
     receiver's `formatLogEntry()` function. */
    public let style: DelimiterStyle

    /** 
     Initializes a new `DelimiterLogFormatter` instance using the given
     `DelimiterStyle`.
     
     - parameter style: The field separator style.
     */
    public init(style: DelimiterStyle = .Pipe)
    {
        self.style = style
    }

    /**
     Returns the value of the `separatorString` property from the receiver's
     `style` property.

     - parameter entry: Ignored by this implementation.

     - returns: The value of `style.delimiter` property; never `nil`.
     */
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        return style.delimiter
    }
}
