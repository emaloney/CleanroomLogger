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
    /** A strict translation from a `LogEntry`'s `severity` to an
     `OSLogType` value. Warnings are treated as errors.
     
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
     `OSLogType` value. Warnings are treated as informational log messages.
     
     LogSeverity|OSLogType
     -----------|---------
     `.verbose`|`.debug`
     `.debug`|`.debug`
     `.info`|`.default`
     `.warning`|`.default`
     `.error`|`.error`
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
                case .info:         return .default
                case .warning:      return .default
                case .error:        return .error
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
