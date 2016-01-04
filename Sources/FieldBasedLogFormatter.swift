//
//  FieldBasedLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public class FieldBasedLogFormatter: ConcatenatingLogFormatter
{
    public enum Field {
        case CallSite
        case CallingThread
        case Literal(String)
        case Payload
        case Timestamp
        case TimestampWithFormat(String)
        case StackFrame
        case Separator
        case Severity

        private func createLogFormatter(customFieldSeparator: String?)
            -> LogFormatter
        {
            switch self {
            case .CallSite:                         return CallSiteLogFormatter()
            case .CallingThread:                    return CallingThreadLogFormatter()
            case .Separator:                        return FieldSeparatorLogFormatter(customFieldSeparator)
            case .Literal(let literal):             return LiteralLogFormatter(literal)
            case .Payload:                          return PayloadLogFormatter()
            case .Timestamp:                        return TimestampLogFormatter()
            case .TimestampWithFormat(let format):  return TimestampLogFormatter(dateFormat: format)
            case .StackFrame:                       return StackFrameLogFormatter()
            case .Severity:                         return SeverityLogFormatter()
            }
        }
    }

    public override init(formatters: [LogFormatter])
    {
        super.init(formatters: formatters)
    }

    public init(fields: [Field], customFieldSeparator: String? = nil)
    {
        super.init(formatters: fields.map{ $0.createLogFormatter(customFieldSeparator) })
    }
}
