//
//  ConcatenatingLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 The `ConcatenatingLogFormatter` lets you combine the output of multiple
 `LogFormatter`s by concatenating their output and returning the result.
 */
open class ConcatenatingLogFormatter: LogFormatter
{
    /** The `LogFormatter`s whose output will be concatenated. */
    open let formatters: [LogFormatter]

    /** Determines the behavior of `format(_:)` when one of the receiver's
     `formatters` returns `nil`. When `false`, if any formatter returns
     `nil`, it is simply excluded from the concatenation, but formatting
     continues. Unless _none_ of the `formatters` returns a string, the 
     receiver will always return a non-`nil` value. However, when `hardFail`
     is `true`, _all_ of the `formatters` must return strings; if _any_
     formatter returns `nil`, the receiver _also_ returns `nil`. */
    open let hardFail: Bool

    /**
     Initializes a new `ConcatenatingLogFormatter` instance.
     
     - parameter formatters: The `LogFormatter`s whose output will be
     concatenated.
     
     - parameter hardFail: Determines the behavior of `format(_:)` when one of 
     the receiver's `formatters` returns `nil`. When `false`, if any formatter
     returns `nil`, it is simply excluded from the concatenation, but formatting
     continues. Unless _none_ of the `formatters` returns a string, the
     receiver will always return a non-`nil` value. However, when `hardFail`
     is `true`, _all_ of the `formatters` must return strings; if _any_
     formatter returns `nil`, the receiver _also_ returns `nil`.
     */
    public init(formatters: [LogFormatter], hardFail: Bool = false)
    {
        self.formatters = formatters
        self.hardFail = hardFail
    }

    /**
     Formats the `LogEntry` by passing it to each of the receiver's
     `LogFormatter`s and concatenating the output.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result, or `nil` if formatting failed according
     to the receiver's `hardFail` property.
     */
    open func format(_ entry: LogEntry)
        -> String?
    {
        var allFormatted = [String]()
        for f in formatters {
            if let formatted = f.format(entry) {
                allFormatted.append(formatted)
            } else if hardFail {
                return nil
            }
        }

        guard allFormatted.count > 0 else {
            return nil
        }

        return allFormatted.joined(separator: "")
    }
}

