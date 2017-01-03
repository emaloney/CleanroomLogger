//
//  LiteralLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns always returns a given literal string
 regardless of input.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct LiteralLogFormatter: LogFormatter
{
    /** The literal string used as the return value of the receiver's 
     `format(_:)` function. */
    public let literal: String

    /**
     Initializes a new `LiteralLogFormatter` to contain the given string.
     
     - parameter string: The literal string.
     */
    public init(_ string: String)
    {
        literal = string
    }

    /**
     Returns the value of the receiver's `literal` property.

     - parameter entry: Ignored by this implementation.

     - returns: The value of the receiver's `literal` property; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        return literal
    }
}
