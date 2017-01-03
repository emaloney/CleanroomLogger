//
//  FieldBasedLogFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/4/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 The `FieldBasedLogFormatter` provides a simple interface for constructing
 a customized `LogFormatter` by specifying different *fields*.
 
 Let's say you wanted to construct a `LogFormatter` that outputs the following
 fields separated by tabs:
 
 - The `LogEntry`'s `timestamp` property as a UNIX time value
 - The `severity` of the `LogEntry` as a numeric value
 - The `Payload` of the `LogEntry`

 You could do this by constructing a `FieldBasedLogFormatter` as follows:
 
 ```swift
 let formatter = FieldBasedLogFormatter(fields: [.timestamp(.unix),
                                                 .delimiter(.tab),
                                                 .severity(.numeric),
                                                 .delimiter(.tab),
                                                 .payload])
 ```
 */
open class FieldBasedLogFormatter: ConcatenatingLogFormatter
{
    /**
     The individual `Field` declarations for the `FieldBasedLogFormatter`.
     */
    public enum Field {
        /** Represents the timestamp field rendered in a specific
         `TimestampStyle`. */
        case timestamp(TimestampStyle)

        /** Represents the `LogSeverity` field rendered in a specific
         `SeverityStyle`. */
        case severity(SeverityStyle)

        /** Represents the call site field. The call site includes the
         filename and line number corresponding to the call site's source. */
        case callSite

        /** Represents the stack frame of the caller. Assuming the call site
         is within a function, this field will contain the signature of the
         function. */
        case stackFrame

        /** Represents the ID of the thread on which the call was executed. 
         You should treat thread IDs as opaque strings whose values may be
         recycled over time. */
        case callingThread

        /** Represents the `Payload` of a `LogEntry. */
        case payload

        /** Represents a text delimiter. The `DelimiterStyle` specifies the
         content of the delimiter string. */
        case delimiter(DelimiterStyle)

        /** Represents a string literal. */ 
        case literal(String)

        /** Represents a field containing the output of the given 
         `LogFormatter`. */
        case custom(LogFormatter)

        fileprivate func createLogFormatter()
            -> LogFormatter
        {
            switch self {
            case .timestamp(let style):     return TimestampLogFormatter(style: style)
            case .severity(let style):      return SeverityLogFormatter(style: style)
            case .callSite:                 return CallSiteLogFormatter()
            case .stackFrame:               return StackFrameLogFormatter()
            case .callingThread:            return CallingThreadLogFormatter()
            case .payload:                  return PayloadLogFormatter()
            case .delimiter(let style):     return DelimiterLogFormatter(style: style)
            case .literal(let literal):     return LiteralLogFormatter(literal)
            case .custom(let formatter):    return formatter
            }
        }
    }

    /**
     Initializes the `FieldBasedLogFormatter` to use the specified fields.

     - parameter fields: The `Field`s that will be used by the receiver.
     */
    public init(fields: [Field])
    {
        super.init(formatters: fields.map{ $0.createLogFormatter() })
    }

    /**
     Initializes the `FieldBasedLogFormatter` to use the specified formatters.

     - parameter formatters: The `LogFormatter`s that will be used by the
     receiver.
     */
    public override init(formatters: [LogFormatter])
    {
        super.init(formatters: formatters)
    }
}
