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

They are responsible for converting requests to log information into 
`LogEntry` instances, which they then pass along to their associated
`LogReceptacle`s to perform the actual logging.

`LogChannel`s are provided as a convenience, exposed as static properties
through the `Log` struct. Use of `LogChannel`s and the `Log` is not required
for logging; you can also perform logging by creating `LogEntry` instances
manually and passing them along to a `LogReceptacle`.
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
        let threadID = pthread_mach_thread_np(pthread_self())

        let entry = LogEntry(payload: .Trace, severity: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: Int(threadID))

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
        let threadID = pthread_mach_thread_np(pthread_self())

        let entry = LogEntry(payload: .Message(msg), severity: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: Int(threadID))

        receptacle.log(entry)
    }

    /**
    Writes arbitrary data to the log.

    :param:     data The data to write to the log. The underlying logging
                implementation must support the data type provided or else the
                log request may be silently ignored.
    
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
    public func data(data: Any, function: String = __FUNCTION__, filePath: String = __FILE__, fileLine: Int = __LINE__)
    {
        let threadID = pthread_mach_thread_np(pthread_self())

        let entry = LogEntry(payload: .Data(data), severity: severity, callingFunction: function, callingFilePath: filePath, callingFileLine: fileLine, callingThreadID: Int(threadID))

        receptacle.log(entry)
    }
}
