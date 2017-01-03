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
    case spacedPipe

    /** Specifies a hyphen character with a space character on each side. */
    case spacedHyphen

    /** Specifies the tab character: ASCII `0x09`. */
    case tab

    /** Specifies the space character: ASCII `0x20`. */
    case space

    /** Specifies a custom field delimiters. */
    case custom(String)
}

public extension DelimiterStyle
{
    /**
     Returns the field delimiter string indicated by the receiver's value.
     */
    public var delimiter: String {
        switch self {
        case .spacedPipe:       return " | "
        case .spacedHyphen:     return " - "
        case .tab:              return "\t"
        case .space:            return " "
        case .custom(let sep):  return sep
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
     receiver's `format(_:)` function. */
    public let style: DelimiterStyle

    /** 
     Initializes a new `DelimiterLogFormatter` instance using the given
     `DelimiterStyle`.
     
     - parameter style: The field separator style.
     */
    public init(style: DelimiterStyle = .spacedPipe)
    {
        self.style = style
    }

    /**
     Returns the value of the `separatorString` property from the receiver's
     `style` property.

     - parameter entry: Ignored by this implementation.

     - returns: The value of `style.delimiter` property; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        return style.delimiter
    }
}
