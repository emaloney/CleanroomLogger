//
//  DelimiterLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 Allows the specification of different field delimiters.
 */
public enum DelimiterStyle
{
    /** Specifies a pipe character with a space character on each side. */
    case SpacedPipe

    /** Specifies a hyphen character with a space character on each side. */
    case SpacedHyphen

    /** Specifies the tab character: ASCII `0x09`. */
    case Tab

    /** Specifies the space character: ASCII `0x20`. */
    case Space

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
        case .SpacedPipe:       return " | "
        case .SpacedHyphen:     return " - "
        case .Tab:              return "\t"
        case .Space:            return " "
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
    public init(style: DelimiterStyle = .SpacedPipe)
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
