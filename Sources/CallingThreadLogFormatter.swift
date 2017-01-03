//
//  CallingThreadLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 Governs how a `CallingThreadLogFormatter` will represent a `LogEntry`'s 
 `callingThreadID`.
 */
public enum CallingThreadStyle
{
    /** Renders the `callingThreadID` as a hex string.  */
    case hex

    /** Renders the `callingThreadID` as an integer string.  */
    case integer
}

extension CallingThreadStyle
{
    fileprivate func format(_ callingThreadID: UInt64)
        -> String
    {
        switch self {
        case .hex:      return String(format: "%08X", callingThreadID)
        case .integer:  return String(describing: callingThreadID)
        }
    }
}

/**
 A `LogFormatter` that returns a string representation of a `LogEntry`'s
 `callingThreadID`.
 
 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct CallingThreadLogFormatter: LogFormatter
{
    /** Governs how the receiver represents `callingThreadID`s. */
    public let style: CallingThreadStyle
    
    /** 
     The `CallingThreadLogFormatter` initializer.
     
     - parameter style: The style to use for representing `callingThreadID`s.
     */
    public init(style: CallingThreadStyle = .hex)
    {
        self.style = style
    }

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `callingThreadID`. The format is governed by the value of the 
     receiver's `style` property.
     
     - parameter entry: The `LogEntry` to format.
     
     - returns: The formatted result; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        return style.format(entry.callingThreadID)
    }
}
