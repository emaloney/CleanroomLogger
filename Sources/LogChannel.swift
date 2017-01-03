//
//  LogChannel.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 3/20/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 `LogChannel` instances provide the high-level interface for accepting log
 messages.
 
 They are responsible for converting log requests into `LogEntry` instances
 that they then pass along to their associated `LogReceptacle`s to perform the
 actual logging.
 
 `LogChannel`s are provided as a convenience, exposed as static properties
 through `Log`. Use of `LogChannel`s and the `Log` is not required for logging;
 you can also perform logging by creating `LogEntry` instances manually and
 passing them along to a `LogReceptacle`.
 */
public struct LogChannel
{
    /** The `LogSeverity` of this `LogChannel`, which determines the severity
     of the `LogEntry` instances it creates. */
    public let severity: LogSeverity

    /** The `LogReceptacle` into which this `LogChannel` will deposit the
     `LogEntry` instances it creates. */
    public let receptacle: LogReceptacle

    /**
     Initializes a new `LogChannel` instance.

     - parameter severity: The `LogSeverity` to use for each `LogEntry` created
     by the channel.

     - parameter receptacle: The `LogReceptacle` to be used for depositing the
     `LogEntry` instances created by the channel.
     */
    public init(severity: LogSeverity, receptacle: LogReceptacle)
    {
        self.severity = severity
        self.receptacle = receptacle
    }

    /**
     Sends program execution trace information to the log using the receiver's
     severity. This information includes source-level call site information as
     well as the stack frame signature of the caller.

     - parameter function: The default value provided for this parameter 
     captures the signature of the calling function. You should not provide a 
     value for this parameter.

     - parameter filePath: The default value provided for this parameter 
     captures the file path of the code issuing the call to this function.
     You should not provide a value for this parameter.

     - parameter fileLine: The default value provided for this parameter 
     captures the line number issuing the call to this function. You should
     not provide a value for this parameter.
     */
    public func trace(_ function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(payload: .trace, severity: severity, callingFilePath: filePath, callingFileLine: fileLine, callingStackFrame: function, callingThreadID: threadID)

        receptacle.log(entry)
    }

    /**
     Sends a message string to the log using the receiver's severity.

     - parameter msg: The message to send to the log.

     - parameter function: The default value provided for this parameter
     captures the signature of the calling function. You should not provide a
     value for this parameter.

     - parameter filePath: The default value provided for this parameter
     captures the file path of the code issuing the call to this function.
     You should not provide a value for this parameter.

     - parameter fileLine: The default value provided for this parameter
     captures the line number issuing the call to this function. You should
     not provide a value for this parameter.
    */
    public func message(_ msg: String, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(payload: .message(msg), severity: severity, callingFilePath: filePath, callingFileLine: fileLine, callingStackFrame: function, callingThreadID: threadID)

        receptacle.log(entry)
    }

    /**
     Sends an arbitrary value to the log using the receiver's severity.

     - parameter value: The value to send to the log. Determining how (and
     whether) arbitrary values are captured and represented will be handled by
     the `LogRecorder` implementation(s) that are ultimately called upon to
     record the log entry.

     - parameter function: The default value provided for this parameter
     captures the signature of the calling function. You should not provide a
     value for this parameter.

     - parameter filePath: The default value provided for this parameter
     captures the file path of the code issuing the call to this function.
     You should not provide a value for this parameter.

     - parameter fileLine: The default value provided for this parameter
     captures the line number issuing the call to this function. You should
     not provide a value for this parameter.
    */
    public func value(_ value: Any?, function: String = #function, filePath: String = #file, fileLine: Int = #line)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(payload: .value(value), severity: severity, callingFilePath: filePath, callingFileLine: fileLine, callingStackFrame: function, callingThreadID: threadID)

        receptacle.log(entry)
    }
}
