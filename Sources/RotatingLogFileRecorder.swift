//
//  RotatingLogFileRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/14/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `LogRecorder` implementation that maintains a set of daily rotating log
 files, kept for a user-specified number of days.

 - important: A `RotatingLogFileRecorder` instance assumes full control over
 the log directory specified by its `directoryPath` property. Please see the
 initializer documentation for details.
*/
open class RotatingLogFileRecorder: LogRecorderBase
{
    /** The number of days for which the receiver will retain log files
     before they're eligible for pruning. */
    public let daysToKeep: Int

    /** The filesystem path to a directory where the log files will be
     stored. */
    public let directoryPath: String
    
    /** The approximate maximum size (in bytes) to allow log files to grow.
     If a log file is larger than this value after a log statement is appended,
     then the log file is rolled.  */
    public let maximumFileSize: Int64?

    private static let filenameFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()

    private var mostRecentLogTime: Date?
    private var currentFileRecorder: FileLogRecorder?
    private static var currentNumberOfRolledFiles: Int?

    /**
     Initializes a new `RotatingLogFileRecorder` instance.

     - warning: The `RotatingLogFileRecorder` expects to have full control over
     the contents of its `directoryPath`. Any file not recognized as an active
     log file will be deleted during the automatic pruning process, which may
     occur at any time. Therefore, be __extremely careful__ when constructing
     the value passed in as the `directoryPath`.

     - parameter daysToKeep: The number of days for which log files should be
     retained.

     - parameter directoryPath: The filesystem path of the directory where the
     log files will be stored. Please note the warning above regarding the
     `directoryPath`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.
     
     - parameter maximumFileSize: The approximate maximum size (in bytes) to allow log files to grow.
     If a log file is larger than this value after a log statement is appended, then the log file is rolled.
    */
    public init(daysToKeep: Int, directoryPath: String, formatters: [LogFormatter] = [ReadableLogFormatter()], maximumFileSize: Int64? = nil)
    {
        self.daysToKeep = daysToKeep
        self.directoryPath = directoryPath
        self.maximumFileSize = maximumFileSize

        super.init(formatters: formatters)
    }

    /**
     Returns a string representing the filename that will be used to store logs
     recorded on the given date.

     - parameter date: The `Date` for which the log file name is desired.

     - returns: The filename.
    */
    open class func logFilename(forDate date: Date, rolledLogFileNumber: Int? = nil, withExtension: Bool = true)
        -> String
    {
        guard let rolledLogFileNumber = rolledLogFileNumber,
        rolledLogFileNumber > 0 else
        {
            return "\(filenameFormatter.string(from: date))\(withExtension ? ".log" : "")"
        }
        return "\(filenameFormatter.string(from: date))(\(rolledLogFileNumber))\(withExtension ? ".log" : "")"
    }
    
    private class func hasExceeded(fileSize: Int64, at path: String) -> Bool
    {
        guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: path),
              let bytes = fileAttributes[.size] as? Int64,
              bytes >= fileSize else
        {
            return false
        }
        
        return true
    }

    private class func fileLogRecorder(_ date: Date, directoryPath: String, formatters: [LogFormatter], maximumFileSize: Int64? = nil)
        -> FileLogRecorder?
    {
        let fileNameWithoutExtension = logFilename(forDate: date, withExtension: false)
        var fileName = logFilename(forDate: date)
        var filePath = (directoryPath as NSString).appendingPathComponent(fileName)
        
        guard let maximumFileSize = maximumFileSize else
        {
            return FileLogRecorder(filePath: filePath, formatters: formatters)
        }

        if FileManager.default.fileExists(atPath: filePath)
        {
            // Check if the first file is larger than the maxLogSize
            guard hasExceeded(fileSize: maximumFileSize, at: filePath) else
            {
                return FileLogRecorder(filePath: filePath, formatters: formatters)
            }
            
            if let currentNumberOfRolledFiles = self.currentNumberOfRolledFiles
            {
                let nextRolledNumber = currentNumberOfRolledFiles + 1
                
                fileName = logFilename(forDate: date, rolledLogFileNumber: nextRolledNumber)
                filePath = (directoryPath as NSString).appendingPathComponent(fileName)
                self.currentNumberOfRolledFiles = nextRolledNumber
                return FileLogRecorder(filePath: filePath, formatters: formatters)
            }
            else
            {
                // Identify the current number of rolled log files for this date
                let directoryContents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath)
                    .filter { return $0 != fileName }
                    .filter { return $0.contains(fileNameWithoutExtension) }
                    .sorted()
                
                guard directoryContents?.isEmpty == false else
                {
                    // If no rolled files, start with 1
                    fileName = logFilename(forDate: date, rolledLogFileNumber: 1)
                    filePath = (directoryPath as NSString).appendingPathComponent(fileName)
                    self.currentNumberOfRolledFiles = 1
                    return FileLogRecorder(filePath: filePath, formatters: formatters)
                }
                
                // Check if the newest rolled file exceeds the limit or not
                let newestFilePath = (directoryPath as NSString).appendingPathComponent(directoryContents!.last!)
                guard hasExceeded(fileSize: maximumFileSize, at: newestFilePath) else
                {
                    self.currentNumberOfRolledFiles = directoryContents!.count
                    fileName = logFilename(forDate: date, rolledLogFileNumber: directoryContents!.count)
                    filePath = (directoryPath as NSString).appendingPathComponent(fileName)
                    return FileLogRecorder(filePath: filePath, formatters: formatters)
                }
                
                // If it does, create a new file
                // +1 because the initial (non-rolled) file has been filtered from the directoryContents
                fileName = logFilename(forDate: date, rolledLogFileNumber: directoryContents!.count + 1)
                filePath = (directoryPath as NSString).appendingPathComponent(fileName)
                self.currentNumberOfRolledFiles = directoryContents!.count + 1
                    
                }
            }
        
        return FileLogRecorder(filePath: filePath, formatters: formatters)
    }

    private func fileLogRecorder(_ date: Date)
        -> FileLogRecorder?
    {
        return type(of: self).fileLogRecorder(date, directoryPath: directoryPath, formatters: formatters, maximumFileSize: self.maximumFileSize)
    }

    private func isDate(_ firstDate: Date, onSameDayAs secondDate: Date)
        -> Bool
    {
        let firstDateStr = type(of: self).logFilename(forDate: firstDate)
        let secondDateStr = type(of: self).logFilename(forDate: secondDate)
        return firstDateStr == secondDateStr
    }
    
    /**
     Checks if the current log file exceeds the maximum file size allowed, if it does, the log files are rolled.

     - parameter entry: the log entry to base the new log file off if required
     */
    private func rollLogFileIfNeeded(_ entry: LogEntry)
    {
        guard let maximumFileSize = self.maximumFileSize,
              let filePath = currentFileRecorder?.filePath,
              RotatingLogFileRecorder.hasExceeded(fileSize: maximumFileSize, at: filePath) else { return }
        
        currentFileRecorder = fileLogRecorder(entry.timestamp)
    }

    /**
     Attempts to create—if it does not already exist—the directory indicated
     by the `directoryPath` property.
     
     - throws: If the function fails to create a directory at `directoryPath`.
     */
    open func createLogDirectory()
        throws
    {
        let url = URL(fileURLWithPath: directoryPath, isDirectory: true)

        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }

    /**
     Called by the `LogReceptacle` to record the specified log message.

     - note: This function is only called if one of the `formatters` associated
     with the receiver returned a non-`nil` string for the given `LogEntry`.

     - parameter message: The message to record.

     - parameter entry: The `LogEntry` for which `message` was created.

     - parameter currentQueue: The GCD queue on which the function is being
     executed.

     - parameter synchronousMode: If `true`, the recording is being done in
     synchronous mode, and the recorder should act accordingly.
    */
    open override func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        if mostRecentLogTime == nil || !self.isDate(entry.timestamp as Date, onSameDayAs: mostRecentLogTime!) {
            prune()
            currentFileRecorder = fileLogRecorder(entry.timestamp)
        }
        mostRecentLogTime = entry.timestamp as Date

        currentFileRecorder?.record(message: message, for: entry, currentQueue: queue, synchronousMode: synchronousMode)
        
        rollLogFileIfNeeded(entry)
    }

    /**
     Deletes any expired log files (and any other detritus that may be hanging
     around inside our `directoryPath`).

     - warning: Any file within the `directoryPath` not recognized as an active
     log file will be deleted during pruning.
    */
    open func prune()
    {
        // figure out what files we'd want to keep, then nuke everything else
        let cal = Calendar.current
        var date = Date()
        var filesToKeep = Set<String>()
        for _ in 0..<daysToKeep {
            let filename = type(of: self).logFilename(forDate: date, withExtension: false)
            filesToKeep.insert(filename)
            date = cal.date(byAdding: .day, value: -1, to: date, wrappingComponents: true)!
        }

        do {
            let fileMgr = FileManager.default
            let filenames = try fileMgr.contentsOfDirectory(atPath: directoryPath)
            
            let pathsToRemove = filenames
                .filter { return !$0.hasPrefix(".") }
                .filter { return !$0.contains(Array(filesToKeep)) }
                .map { return (self.directoryPath as NSString).appendingPathComponent($0) }

            for path in pathsToRemove {
                do {
                    try fileMgr.removeItem(atPath: path)
                }
                catch {
                    print("Error attempting to delete the unneeded file <\(path)>: \(error)")
                }
            }
        }
        catch {
            print("Error attempting to read directory at path <\(directoryPath)>: \(error)")
        }
    }
}

extension String {
    func contains(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
}
