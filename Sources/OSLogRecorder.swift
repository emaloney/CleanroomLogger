//
//  OSLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Dispatch
import os.log

/**
 The `OSLogRecorder` is an implemention of the `LogRecorder` protocol that
 records log entries using the new unified logging system available
 as of iOS 10.0, macOS 10.12, tvOS 10.0, and watchOS 3.0.

 Unless a `LogTypeTranslator` is specified during construction, the
 `OSLogRecorder` will record log messages with an `OSLogType` of `.default`.
 This is consistent with the behavior of `NSLog()`.
 */
public struct OSLogRecorder: LogRecorder
{
    /** `true` if the `os_log()` function is available at runtime. */
    public static let isAvailable: Bool = {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) else {
            return false
        }
        return true
    }()
    
    /** The `LogFormatter`s to be used in conjunction with the receiver. */
    public let formatters: [LogFormatter]

    /** Governs how `OSLogType` values are generated from `LogEntry` values. */
    public let logTypeTranslator: OSLogTypeTranslator
    
    /** The `OSLog` used to perform logging. */
    public let log: OSLog

    /** The GCD queue used by the receiver to record messages. */
    public let queue: DispatchQueue

    /**
     Initialize an `OSLogRecorder` instance, which will record log entries
     using the `os_log()` function.
     
     - important: `os_log()` is only supported as of iOS 10.0, macOS 10.12,
     tvOS 10.0, and watchOS 3.0. On incompatible systems, this initializer
     will fail.
     
     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded (and subsequent formatters, if
     any, are skipped). The log entry is silently ignored and not recorded if
     every formatter returns `nil`.
     
     - parameter subsystem: The name of the subsystem performing the logging.
     Defaults to the empty string (`""`) if not specified.
     
     - parameter logTypeTranslator: An `OSLogTypeTranslator` value that governs
     how `OSLogType` values are determined for log entries.
     
     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public init?(formatters: [LogFormatter], subsystem: String = "", logTypeTranslator: OSLogTypeTranslator = .default, queue: DispatchQueue? = nil)
    {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) else {
            return nil
        }
        
        self.log = OSLog(subsystem: subsystem, category: "CleanroomLogger")
        self.queue = queue != nil ? queue! : DispatchQueue(label: String(describing: type(of: self)), attributes: [])
        self.formatters = formatters
        self.logTypeTranslator = logTypeTranslator
    }

    /**
     Called to record the specified using the `os_log()` function.

     - note: This function is only called if one of the `formatters` associated
     with the receiver returned a non-`nil` string for the given `LogEntry`.

     - parameter message: The message to record.

     - parameter entry: The `LogEntry` for which `message` was created.

     - parameter currentQueue: The GCD queue on which the function is being
     executed.

     - parameter synchronousMode: If `true`, the recording is being done in
     synchronous mode, and the recorder should act accordingly.
     */
    public func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) else {
            fatalError("os.log module not supported on this platform")    // things should never get this far; failable initializers should prevent this condition
        }
        
        let type = self.logTypeTranslator.osLogType(logEntry: entry)
        os_log("%{public}@", log: self.log, type: type, message)
    }
}
