//
//  OSLogTypeTranslator.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/2/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import os.log

/**
 Specifies the manner in which an `OSLogType` is selected to represent a
 given `LogEntry`.
 
 When a log entry is being recorded by an `OSLogRecorder`, an `OSLogType`
 value is used to specify the importance of the message; it is similar in
 concept to the `LogSeverity`.
 
 Because there is not an exact one-to-one mapping between `OSLogType` and
 `LogSeverity` values, `OSLogTypeTranslation` provides a mechanism for 
 deriving the appropriate `OSLogType` for a given `LogEntry`.
  */
public enum OSLogTypeTranslator
{
    /** The most direct translation from a `LogEntry`'s `severity` to the
     corresponding `OSLogType` value.

     This value strikes a sensible balance between the higher-overhead logging
     provided by `.strict` and the more ephemeral logging of `.relaxed`.

     LogSeverity|OSLogType
     -----------|---------
     `.verbose`|`.debug`
     `.debug`|`.debug`
     `.info`|`.info`
     `.warning`|`.default`
     `.error`|`.error`
     */
    case `default`

    /** A strict translation from a `LogEntry`'s `severity` to an
     `OSLogType` value. Warnings are treated as errors; errors are
     treated as faults.
     
     This will result in additional logging overhead being recorded by OSLog,
     and is not recommended unless you have a specific need for this.

     LogSeverity|OSLogType
     -----------|---------
     `.verbose`|`.debug`
     `.debug`|`.debug`
     `.info`|`.default`
     `.warning`|`.error`
     `.error`|`.fault`
     */
    case strict

    /** A relaxed translation from a `LogEntry`'s `severity` to an
     `OSLogType` value. Nothing is treated as an error.
     
     This results in low-overhead logging, but log entries are more
     ephemeral and may not contain as much OSLog metadata.
     
     LogSeverity|OSLogType
     -----------|---------
     `.verbose`|`.debug`
     `.debug`|`.debug`
     `.info`|`.info`
     `.warning`|`.default`
     `.error`|`.default`
     */
    case relaxed

    /** `OSLogType.default` is used for all messages. */
    case allAsDefault

    /** `OSLogType.info` is used for all messages. */
    case allAsInfo
    
    /** `OSLogType.debug` is used for all messages. */
    case allAsDebug
    
    /** Uses a custom function to determine the `OSLogType` to use for each
     `LogEntry`. */
    case function((LogEntry) -> OSLogType)
}

extension OSLogTypeTranslator
{
    internal func osLogType(logEntry: LogEntry)
        -> OSLogType
    {
        return logTypeFunction()(logEntry)
    }

    private func logTypeFunction() -> ((LogEntry) -> OSLogType)
    {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) else {
            fatalError("os.log module not supported on this platform")    // things should never get this far
        }
        
        switch self {
        case .default:
            return { entry -> OSLogType in
                switch entry.severity {
                case .verbose:      return .debug
                case .debug:        return .debug
                case .info:         return .info
                case .warning:      return .default
                case .error:        return .error
                }
            }

        case .strict:
            return { entry -> OSLogType in
                switch entry.severity {
                case .verbose:      return .debug
                case .debug:        return .debug
                case .info:         return .default
                case .warning:      return .error
                case .error:        return .fault
                }
            }

        case .relaxed:
            return { entry -> OSLogType in
                switch entry.severity {
                case .verbose:      return .debug
                case .debug:        return .debug
                case .info:         return .info
                case .warning:      return .default
                case .error:        return .default
                }
            }
            
       case .allAsDefault:
            return { _ in return OSLogType.default }
            
        case .allAsInfo:
            return { _ in return OSLogType.info }
            
        case .allAsDebug:
            return { _ in return OSLogType.debug }
            
        case .function(let f):
            return f
        }
    }
}
