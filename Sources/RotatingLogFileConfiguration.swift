//
//  RotatingLogFileConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/31/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 A `LogConfiguration` that uses an underlying `RotatingLogFileRecorder` to
 maintain a directory of log files that are rotated on a daily basis.
 */
open class RotatingLogFileConfiguration: BasicLogConfiguration
{
    /** The filesystem path to a directory where the log files will be
     stored. */
    open var directoryPath: String {
        return logFileRecorder.directoryPath
    }

    private let logFileRecorder: RotatingLogFileRecorder

    /**
     Initializes a new `RotatingLogFileConfiguration` instance.

     - warning: The `RotatingLogFileRecorder` created by this configuration
     assumes full control over the log directory specified as `directoryPath`.
     Any file not recognized as an active log file will be deleted during the
     automatic pruning process, which may occur at any time. Therefore, be
     __extremely careful__ when constructing the value passed in as the
     `directoryPath`.

     - parameter minimumSeverity: The minimum supported `LogSeverity`. Any
     `LogEntry` having a `severity` less than `minimumSeverity` will be silently
     ignored by the configuration.
     
     - parameter daysToKeep: The number of days for which log files should be
     retained.

     - parameter directoryPath: The filesystem path of the directory where the
     log files will be stored. Please note the warning above regarding the
     `directoryPath`.

     - parameter synchronousMode: Determines whether synchronous mode will be
     used by the underlying `RotatingLogFileRecorder`. Synchronous mode is
     helpful while debugging, as it ensures that logs are always up-to-date
     when debug breakpoints are hit. However, synchronous mode can have a 
     negative influence on performance and is therefore not recommended for
     use in production code.

     - parameter filters: The `LogFilter`s to use when deciding whether a given
     `LogEntry` should be passed along for recording.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.
     */
    public init(minimumSeverity: LogSeverity, daysToKeep: Int, directoryPath: String, synchronousMode: Bool = false, filters: [LogFilter] = [], formatters: [LogFormatter] = [ReadableLogFormatter()])
    {
        logFileRecorder = RotatingLogFileRecorder(daysToKeep: daysToKeep, directoryPath: directoryPath, formatters: formatters)

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: [logFileRecorder], synchronousMode: synchronousMode)
    }

    /**
     Attempts to create—if it does not already exist—the directory indicated
     by the `directoryPath` property.

     - throws: If the function fails to create a directory at `directoryPath`.
     */
    open func createLogDirectory()
        throws
    {
        try logFileRecorder.createLogDirectory()
    }
}
