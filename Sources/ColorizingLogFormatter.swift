//
//  ColorizingLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 Wraps another `LogFormatter` and colorizes its output according to the
 `LogSeverity` of the `LogEntry` being recorded.
 */
public struct ColorizingLogFormatter: LogFormatter
{
    /** The `LogFormatter` wrapped by the receiver. */
    public let formatter: LogFormatter

    /** The `TextColorizer` used to apply color formatting to the output of the
     receiver's `formatter`. */
    public let colorizer: TextColorizer

    /** The `ColorTable` used to supply foreground and background text color
     information. */
    public let colorTable: ColorTable

    /**
     Initializes a new `ColorizingLogFormatter` instance.
     
     - parameter formatter: The `LogFormatter` whose output will be colorized
     by the receiver.
     
     - parameter colorizer: The `TextColorizer` that will be used to colorize
     the output of `formatter`.
     
     - parameter colorTable: The `ColorTable` to use for supplying color
     information to the `TextColorizer`.
     */
    public init(formatter: LogFormatter, colorizer: TextColorizer, colorTable: ColorTable? = nil)
    {
        self.formatter = formatter
        self.colorizer = colorizer
        self.colorTable = colorTable ?? DefaultColorTable()
    }

    /**
     Formats the `LogEntry` by first passing it to the `LogFormatter` used
     to construct the receiver. Then, if a non-`nil` value is returned, the
     resulting string have color formatting codes applied to it using the
     `colorizer` and `colorTable` specified at instantiation.
     
     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result, or `nil` if the receiver's
     `formatter` returns `nil` when attempting to format `entry`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        guard let str = formatter.format(entry) else {
            return nil
        }

        let fg = colorTable.foreground(forSeverity: entry.severity)
        let bg = colorTable.background(forSeverity: entry.severity)

        return colorizer.colorize(str, foreground: fg, background: bg)
    }
}
