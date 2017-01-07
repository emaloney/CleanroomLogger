//
//  PayloadValueLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/6/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 A `LogFormatter` that returns the message content of a `LogEntry` whose
 `payload` is a `.value` value.
 */
public struct PayloadValueLogFormatter: LogFormatter
{
    /**
     The initializer.
     */
    public init() {}

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `payload` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The message content, or `nil` if `entry` doesn't have a
     `payload` with a `.value` value.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        guard case .value(let v) = entry.payload else { return nil }

        guard let value = v else {
            return "= nil"
        }

        var pieces = [String]()
        pieces.append("= ")
        pieces.append(String(describing: type(of: value)))
        pieces.append(": ")
        if let custom = value as? CustomDebugStringConvertible {
            pieces.append(custom.debugDescription)
        }
        else if let custom = value as? CustomStringConvertible {
            pieces.append(custom.description)
        }
        else {
            pieces.append(String(describing: value))
        }

        return pieces.joined()
    }
}
