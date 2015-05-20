//
//  DailyRotatingLogFileRecorder.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 5/14/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
A `LogRecorder` implementation that maintains a set of daily rotating log
files, kept for a user-specified number of days.

**Important:** The `DailyRotatingLogFileRecorder` is expected to have full
control over the `directoryPath` with which it was instantiated. Any file not
explicitly known to be an active log file may be removed during the pruning
process. Therefore, be careful not to store anything in the `directoryPath`
that you wouldn't mind being deleted when pruning occurs.
*/
public class DailyRotatingLogFileRecorder: LogRecorderBase
{
    /** The number of days for which the receiver will retain log files
    before they're eligible for pruning. */
    public let daysToKeep: Int

    /** The filesystem path to a directory where the log files will be
    stored. */
    public let directoryPath: String

    private static let filenameFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'.log'"
        return fmt
    }()

    private var mostRecentLogTime: NSDate?
    private var currentFileRecorder: FileLogRecorder?

    /**
    Attempts to initialize a new `DailyRotatingLogFileRecorder` instance. This
    may fail if the `directoryPath` doesn't already exist as a directory and
    could not be created.
    
    **Important:** The new `DailyRotatingLogFileRecorder` will take 
    responsibility for managing the contents of the `directoryPath`. As part
    of the automatic pruning process, any file not explicitly known to be an
    active log file may be removed. Be careful not to put anything in this
    directory you might not want deleted when pruning occurs.

    :param:     daysToKeep The number of days for which log files should be
                retained.
    
    :param:     directoryPath The filesystem path of the directory where the
                log files will be stores.

    :param:     formatters The `LogFormatter`s to use for the recorder.
    */
    public init?(daysToKeep: Int, directoryPath: String, formatters: [LogFormatter] = [DefaultLogFormatter()])
    {
        self.daysToKeep = daysToKeep
        self.directoryPath = directoryPath

        // try to create the directory that will contain the log files
        var dirCreationFailed = false
        if let url = NSURL(fileURLWithPath: directoryPath, isDirectory: true) {
            var err: NSError?
            if !NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: &err)
            {
                dirCreationFailed = true
                println("Error attempting to create directory structure for path <\(directoryPath)>: \(err)")
            }
        }

        super.init(name: "DailyRotatingLogFileRecorder[\(directoryPath)]", formatters: formatters)

        if dirCreationFailed {
            return nil
        }
    }

    /**
    Returns a string representing the filename that will be used to store logs
    recorded on the given date.
    
    :param:     date The `NSDate` for which the log file name is desired.
    
    :returns:   The filename.
    */
    public class func logFilenameForDate(date: NSDate)
        -> String
    {
        return filenameFormatter.stringFromDate(date)
    }

    private class func fileLogRecorderForDate(date: NSDate, directoryPath: String, formatters: [LogFormatter])
        -> FileLogRecorder?
    {
        let fileName = self.logFilenameForDate(date)
        let filePath = directoryPath.stringByAppendingPathComponent(fileName)
        return FileLogRecorder(filePath: filePath, formatters: formatters)
    }

    private func fileLogRecorderForDate(date: NSDate)
        -> FileLogRecorder?
    {
        return self.dynamicType.fileLogRecorderForDate(date, directoryPath: directoryPath, formatters: formatters)
    }

    private func isDate(firstDate: NSDate, onSameDayAs secondDate: NSDate)
        -> Bool
    {
        let firstDateStr = self.dynamicType.logFilenameForDate(firstDate)
        let secondDateStr = self.dynamicType.logFilenameForDate(secondDate)
        return firstDateStr == secondDateStr
    }

    /**
    Called by the `LogReceptacle` to record the specified log message.

    **Note:** This function is only called if one of the `formatters` 
    associated with the receiver returned a non-`nil` string.
    
    :param:     message The message to record.

    :param:     entry The `LogEntry` for which `message` was created.

    :param:     currentQueue The GCD queue on which the function is being 
                executed.

    :param:     synchronousMode If `true`, the receiver should record the
                log entry synchronously. Synchronous mode is used during
                debugging to help ensure that logs reflect the latest state
                when debug breakpoints are hit. It is not recommended for
                production code.
    */
    public override func recordFormattedMessage(message: String, forLogEntry entry: LogEntry, currentQueue: dispatch_queue_t, synchronousMode: Bool)

    {
        if mostRecentLogTime == nil || !self.isDate(entry.timestamp, onSameDayAs: mostRecentLogTime!) {
            prune()
            currentFileRecorder = fileLogRecorderForDate(entry.timestamp)
        }
        mostRecentLogTime = entry.timestamp

        currentFileRecorder?.recordFormattedMessage(message, forLogEntry: entry, currentQueue: queue, synchronousMode: synchronousMode)
    }

    /**
    Deletes any expired log files (and any other detritus that may be hanging
    around inside our `directoryPath`).
    
    **Important:** The `DailyRotatingLogFileRecorder` is expected to have full
    ownership over its `directoryPath`. Any file not explicitly known to be an
    active log file may be removed during the pruning process. Therefore, be
    careful not to store anything in this directory that you wouldn't mind
    being deleted when pruning occurs.
    */
    public func prune()
    {
        // figure out what files we'd want to keep, then nuke everything else
        let cal = NSCalendar.currentCalendar()
        var date = NSDate()
        var filesToKeep = Set<String>()
        for _ in 0..<daysToKeep {
            let filename = self.dynamicType.logFilenameForDate(date)
            filesToKeep.insert(filename)
            date = cal.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: date, options: nil)!
        }

        let fileMgr = NSFileManager.defaultManager()
        var err: NSError?
        if let filenames = fileMgr.contentsOfDirectoryAtPath(directoryPath, error: &err) as? [String] {
            let pathsToRemove = filenames
                .filter { return !$0.hasPrefix(".") }
                .filter { return !filesToKeep.contains($0) }
                .map { return self.directoryPath.stringByAppendingPathComponent($0) }

            for path in pathsToRemove {
                if !fileMgr.removeItemAtPath(path, error: &err) {
                    println("Error attempting to delete the unneeded file <\(path)>: \(err)")
                }
            }
        }
        else {
            println("Error attempting to read directory at path <\(directoryPath)>: \(err)")
        }
    }
}

