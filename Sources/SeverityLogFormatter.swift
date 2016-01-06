//
//  SeverityLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 */
public enum SeverityStyle
{
    public enum TextRepresentation {
        case Capitalized
        case Lowercase
        case Uppercase
        case Numeric
    }

    case Simple
    case Xcode
    case Numeric
    case Custom(textRepresentation: TextRepresentation, padToWidth: Int?, truncateAtWidth: Int?, rightAlign: Bool)
}

extension SeverityStyle
{
    private var textRepresentation: TextRepresentation {
        switch self {
        case .Simple:                       return .Capitalized
        case .Xcode:                        return .Uppercase
        case .Numeric:                      return .Numeric
        case .Custom(let rep, _, _, _):     return rep
        }
    }

    private var padToWidth: Int? {
        switch self {
        case .Xcode:                        return 7
        case .Custom(_, let pad, _, _):     return pad
        default:                            return nil
        }
    }

    private var truncateAtWidth: Int? {
        switch self {
        case .Custom(_, _, let trunc, _):   return trunc
        default:                            return nil
        }
    }

    private var rightAlign: Bool {
        switch self {
        case .Xcode:                        return true
        case .Custom(_, _, _, let right):   return right
        default:                            return false
        }
    }
}

extension SeverityStyle.TextRepresentation
{
    private func formatSeverity(severity: LogSeverity)
        -> String
    {
        switch self {
        case .Capitalized:  return severity.description.capitalizedString
        case .Lowercase:    return severity.description.lowercaseString
        case .Uppercase:    return severity.description.uppercaseString
        case .Numeric:      return "\(severity.rawValue)"
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
    let style: SeverityStyle

    public init(style: SeverityStyle = .Simple)
    {
        self.style = style
    }

    /**
     Formats the passed-in `LogEntry` by returning a string representation of
     its `severity` property.

     - parameter entry: The `LogEntry` to be formatted.

     - returns: The formatted result; never `nil`.
     */
    public func formatLogEntry(entry: LogEntry)
        -> String?
    {
        var severityTag = style.textRepresentation.formatSeverity(entry.severity)

        if let trunc = style.truncateAtWidth {
            if severityTag.characters.count > trunc {
                let startIndex = severityTag.characters.startIndex
                let endIndex = startIndex.advancedBy(trunc)
                severityTag = severityTag.substringToIndex(endIndex)
            }
        }

        if let pad = style.padToWidth {
            let rightAlign = style.rightAlign
            while severityTag.characters.count < pad {
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
