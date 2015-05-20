//
//  LogChannel.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/20/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
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

    /** The `LogReceptacle` into which this `LogChannel` will deposit
    the `LogEntry` instances it creates. */
    public let receptacle: LogReceptacle

    /**
    Initializes a new `LogChannel` instance using the specified parameters.
    
    :param:     severity The `LogSeverity` to use for log entries written to the
                receiving channel.
    
    :param:     receptacle A `LogFormatter` instance to use for formatting log
                entries.
    */
    public init(severity: LogSeverity, receptacle: LogReceptacle)
    {
        self.severity = severity
        self.receptacle = receptacle
    }

    /**
    Writes program execution trace information to the log. This information
    includes the signature of the calling function, as well as the source file
    and line at which the call to `trace()` was issued.
    
    :param:     function The default value provided for this parameter captures
                the signature of the calling function. **You should not provide
                a value for this parameter.**
    
    :param:     filePath The default value provided for this parameter captures
                the file path of the code issuing the call to this function. 
                **You should not provide a value for this parameter.**

    :param:     fileLine The default value provided for this parameter captures
                the line number issuing the call to this function. **You should
                not provide a value for this parameter.**
    */
    public func trace(function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(payload: .Trace, severity: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: threadID)

        receptacle.log(entry)
    }

    /**
    Writes a string-based message to the log.
    
    :param:     msg The message to log.
    
    :param:     function The default value provided for this parameter captures
                the signature of the calling function. **You should not provide
                a value for this parameter.**
    
    :param:     filePath The default value provided for this parameter captures
                the file path of the code issuing the call to this function. 
                **You should not provide a value for this parameter.**

    :param:     fileLine The default value provided for this parameter captures
                the line number issuing the call to this function. **You should
                not provide a value for this parameter.**
    */
    public func message(msg: String, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(payload: .Message(msg), severity: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: threadID)

        receptacle.log(entry)
    }

    /**
    Writes an arbitrary value to the log.

    :param:     value The value to write to the log. The underlying logging
                implementation is responsible for converting `value` into a
                text representation. If that is not possible, the log request
                may be silently ignored.
    
    :param:     function The default value provided for this parameter captures
                the signature of the calling function. **You should not provide
                a value for this parameter.**
    
    :param:     filePath The default value provided for this parameter captures
                the file path of the code issuing the call to this function. 
                **You should not provide a value for this parameter.**

    :param:     fileLine The default value provided for this parameter captures
                the line number issuing the call to this function. **You should
                not provide a value for this parameter.**
    */
    public func value(value: Any?, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)

        let entry = LogEntry(payload: .Value(value), severity: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: threadID)

        receptacle.log(entry)
    }
}
