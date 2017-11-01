//
//  SeverityLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 Specifies the manner in which `LogSeverity` values should be rendered by
 the `SeverityLogFormatter`.
 */
public enum SeverityStyle
{
    /** Specifies how a `LogSeverity` value should be represented in text. */
    public enum TextRepresentation {
        /** Specifies that the `LogSeverity` should be output as a
         human-readable word with the initial capitalization. */
        case capitalized

        /** Specifies that the `LogSeverity` should be output as a 
         human-readable word in all lowercase characters. */
        case lowercase

        /** Specifies that the `LogSeverity` should be output as a 
         human-readable word in all uppercase characters. */
        case uppercase
        
        /** Specifies that the `rawValue` of the `LogSeverity` should be output
         as an integer within a string. */
        case numeric
        
        /** Specifies that the `rawValue` of the `LogSeverity` should be output
         as an emoji character whose color represents the level of severity. 
         The specific characters used to represent each severity level may
         change over time, so this representation is *not* suitable for 
         parsing. */
        case colorCoded
    }

    /** Indicates that the `LogSeverity` will be output as a human-readable
     string with initial capitalization. No padding, truncation or alignment
     will occur. */
    case simple

    /** Indicates that the `LogSeverity` will be output using defaults
     suitable for viewing within Xcode. The current implementation
     uses a `TextRepresentation` of `.colorCoded`, making it easier to spot
     important messages in the Xcode console. */
    case xcode

    /** Indicates that the `LogSeverity` will be output as an integer contained
     in a string. No padding, truncation or alignment will occur. */
    case numeric

    /** Allows customization of the `SeverityStyle`. The `LogSeverity` value
     will be converted to text as specified by the `TextRepresentation` value.
     If a value is provided for `truncateAtWidth`, fields longer than that will
     be truncated. Finally, if `padToWidth` is supplied, the field will be
     padded with spaces as appropriate. The value of `rightAlign` determines
     how padding occurs.
     */
    case custom(textRepresentation: TextRepresentation, truncateAtWidth: Int?, padToWidth: Int?, rightAlign: Bool)
}

fileprivate extension SeverityStyle
{
    var textRepresentation: TextRepresentation {
        switch self {
        case .simple:                       return .capitalized
        case .xcode:                        return .colorCoded
        case .numeric:                      return .numeric
        case .custom(let rep, _, _, _):     return rep
        }
    }

    var truncateAtWidth: Int? {
        switch self {
        case .custom(_, let trunc, _, _):   return trunc
        default:                            return nil
        }
    }

    var padToWidth: Int? {
        switch self {
        case .custom(_, _, let pad, _):     return pad
        default:                            return nil
        }
    }

    var rightAlign: Bool {
        switch self {
        case .custom(_, _, _, let right):   return right
        default:                            return false
        }
    }
}

extension SeverityStyle.TextRepresentation
{
    /**
     Returns a specific text representation of a given `LogSeverity` value.

     - parameter severity: The `LogSeverity` for which a text representation is
     sought.
     
     - returns: A `String` containing a text representation of `severity`.
     */
    public func format(severity: LogSeverity)
        -> String
    {
        switch self {
        case .capitalized:  return severity.description.capitalized
        case .lowercase:    return severity.description.lowercased()
        case .uppercase:    return severity.description.uppercased()
        case .numeric:      return String(describing: severity.rawValue)
        case .colorCoded:
            switch severity {
            case .verbose:  return "▫️"
            case .debug:    return "▪️"
            case .info:     return "🔷"
            case .warning:  return "🔶"
            case .error:    return "❌"
            }
        }
    }
}

/**
 A `LogFormatter` that returns a string representation of the passed-in
 `LogEntry`'s `severity`.

 This is typically combined with other `LogFormatter`s within a
 `ConcatenatingLogFormatter`.
 */
public struct SeverityLogFormatter: LogFormatter
{
    /** The `SeverityStyle` that determines the return value of the
     receiver's `format(_:)` function. */
    public let style: SeverityStyle

    /**
     Initializes a new `SeverityLogFormatter` to use the specified
     `SeverityStyle` when formatting output.
     
     - parameter style: The `SeverityStyle` to use.
     */
    public init(style: SeverityStyle = .simple)
    {
        self.style = style
    }

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `severity` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result; never `nil`.
     */
    public func format(_ entry: LogEntry)
        -> String?
    {
        var severityTag = style.textRepresentation.format(severity: entry.severity)

        if let trunc = style.truncateAtWidth {
            if severityTag.count > trunc {
                let startIndex = severityTag.startIndex
                let endIndex = severityTag.index(startIndex, offsetBy: trunc)
                severityTag = String(severityTag[..<endIndex])
            }
        }

        if let pad = style.padToWidth {
            let rightAlign = style.rightAlign
            while severityTag.count < pad {
                if rightAlign {
                    severityTag = " " + severityTag
                } else {
                    severityTag += " "
                }
            }
        }

        return severityTag
    }
}
