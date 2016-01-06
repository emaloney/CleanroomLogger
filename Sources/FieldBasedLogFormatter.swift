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
        case Timestamp(TimestampStyle)
        case Severity(SeverityStyle)
        case CallSite
        case StackFrame
        case CallingThread
        case Payload
        case Delimiter(DelimiterStyle)
        case Literal(String)

        private func createLogFormatter()
            -> LogFormatter
        {
            switch self {
            case .Timestamp(let style):             return TimestampLogFormatter(style: style)
            case .Severity(let style):              return SeverityLogFormatter(style: style)
            case .CallSite:                         return CallSiteLogFormatter()
            case .StackFrame:                       return StackFrameLogFormatter()
            case .CallingThread:                    return CallingThreadLogFormatter()
            case .Payload:                          return PayloadLogFormatter()
            case .Delimiter(let style):             return DelimiterLogFormatter(style: style)
            case .Literal(let literal):             return LiteralLogFormatter(literal)
            }
        }
    }

    public override init(formatters: [LogFormatter])
    {
        super.init(formatters: formatters)
    }

    public init(fields: [Field])
    {
        super.init(formatters: fields.map{ $0.createLogFormatter() })
    }
}
