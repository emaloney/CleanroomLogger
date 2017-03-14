//
//  FileLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 5/12/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Darwin.C.stdio
import Dispatch

/**
 A `LogRecorder` implementation that appends log entries to a file.

 - note: `FileLogRecorder` is a simple log appender that provides no mechanism
 for file rotation or truncation. Unless you manually manage the log file when
 a `FileLogRecorder` doesn't have it open, you will end up with an ever-growing
 file. Use a `RotatingLogFileRecorder` instead if you'd rather not have to
 concern yourself with such details.
 */
open class FileLogRecorder: LogRecorderBase
{
    /** The path of the file to which log entries will be written. */
    open let filePath: String

    private let file: UnsafeMutablePointer<FILE>?
    private let newlines: [Character] = ["\n", "\r"]

    /**
     Attempts to initialize a new `FileLogRecorder` instance to use the
     given file path and log formatters. This will fail if `filePath` could
     not be opened for writing.

     - parameter filePath: The path of the file to be written. The containing
     directory must exist and be writable by the process. If the file does not
     yet exist, it will be created; if it does exist, new log messages will be
     appended to the end of the file.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.
     */
    public init?(filePath: String, formatters: [LogFormatter])
    {
        let f = fopen(filePath, "a")
        guard f != nil else {
            return nil
        }

        self.filePath = filePath
        self.file = f

        super.init(formatters: formatters)
    }

    deinit {
        // we've implemented FileLogRecorder as a class so we
        // can have a de-initializer to close the file
        if file != nil {
            fclose(file)
        }
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
        var addNewline = true
        let chars = message.characters
        if chars.count > 0 {
            let lastChar = chars[chars.index(before: chars.endIndex)]
            addNewline = !newlines.contains(lastChar)
        }

        fputs(message, file)

        if addNewline {
            fputc(0x0A, file)
        }

        fflush(file)
    }
}

