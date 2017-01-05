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
         The `CallingThreadStyle` specifies how the thread ID is represented. */
        case callingThread(CallingThreadStyle)

        /** Represents the `Payload` of a `LogEntry`. */
        case payload

        /** Represents the name of the currently executing process. */
        case processName
        
        /** Represents the ID of the currently executing process. */
        case processID
        
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
            case .callingThread(let style): return CallingThreadLogFormatter(style: style)
            case .payload:                  return PayloadLogFormatter()
            case .processName:              return ProcessNameLogFormatter()
            case .processID:                return ProcessIDLogFormatter()
            case .delimiter(let style):     return DelimiterLogFormatter(style: style)
            case .literal(let literal):     return LiteralLogFormatter(literal)
            case .custom(let formatter):    return formatter
            }
        }
    }

    /**
     Initializes the `FieldBasedLogFormatter` to use the specified fields.

     - parameter fields: The `Field`s that will be used by the receiver.

     - parameter hardFail: Determines the behavior of `format(_:)` when one of
     the receiver's `formatters` returns `nil`. When `false`, if any formatter
     returns `nil`, it is simply excluded from the concatenation, but formatting
     continues. Unless _none_ of the `formatters` returns a string, the
     receiver will always return a non-`nil` value. However, when `hardFail`
     is `true`, _all_ of the `formatters` must return strings; if _any_
     formatter returns `nil`, the receiver _also_ returns `nil`.
     */
    public init(fields: [Field], hardFail: Bool = false)
    {
        super.init(formatters: fields.map{ $0.createLogFormatter() }, hardFail: hardFail)
    }

    /**
     Initializes the `FieldBasedLogFormatter` to use the specified formatters.

     - parameter formatters: The `LogFormatter`s that will be used by the
     receiver.

     - parameter hardFail: Determines the behavior of `format(_:)` when one of
     the receiver's `formatters` returns `nil`. When `false`, if any formatter
     returns `nil`, it is simply excluded from the concatenation, but formatting
     continues. Unless _none_ of the `formatters` returns a string, the
     receiver will always return a non-`nil` value. However, when `hardFail`
     is `true`, _all_ of the `formatters` must return strings; if _any_
     formatter returns `nil`, the receiver _also_ returns `nil`.
     */
    public override init(formatters: [LogFormatter], hardFail: Bool = false)
    {
        super.init(formatters: formatters, hardFail: hardFail)
    }
}
