//
//  BufferedLogRecorder.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/16/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Dispatch

/**
 The `BufferedLogRecorder` is a generic `LogRecorder` that buffers the log
 messages passed to its `record()` function.
 
 Construction requires a `createBufferItem` function, which is responsible
 for converting the `LogEntry` and formatted message `String` into the
 generic `BufferItem` type.
 
 Three specific subclasses are also provided which will buffer a different
 `BufferItem` type for each call to `record()`:
 
 - `BufferedMessageRecorder` stores `String`s containing the formatted log
 message.
 - `BufferedLogEntryRecorder` stores the `LogEntry` values passed to `record()`.
 - `BufferedLogEntryMessageRecorder` stores a `(LogEntry, String)` tuple
 containing the `LogEntry` and formatted log message.
 */
open class BufferedLogRecorder<BufferItem>: LogRecorderBase
{
    /** The maximum number if items that will be stored in the receiver's
     buffer. */
    open let bufferLimit: Int

    /** If `true`, the items in the buffer are stored in reverse chronological
     order: the first item in the buffer array will be the newest, while the
     last item will be the oldest. Otherwise, the array will be ordered from
     oldest to newest. */
    open let reverseChronological: Bool

    /** The function used to create a `BufferItem` given a `LogEntry` and a
     formatted message string. */
    open let createBufferItem: (LogEntry, String) -> BufferItem

    /** The buffer, an array of `BufferItem`s created to represent the 
     `LogEntry` values recorded by the receiver. */
    open private(set) var buffer: [BufferItem]

    private var didRecordItemCallbacks: CallbackRegistry<(_ recorder: BufferedLogRecorder<BufferItem>, _ item: BufferItem, _ didTruncateBuffer: Bool) -> Void>
    private var didClearBufferCallbacks: CallbackRegistry<(_ recorder: BufferedLogRecorder<BufferItem>) -> Void>

    /**
     Initializes a new `BufferedLogRecorder`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter bufferLimit: If this value is positive, it specifies the
     maximum number of items to store in the buffer. If `record()` is called
     when the buffer limit has been reached, the oldest item in the buffer will
     be dropped. If this value is zero or negative, no limit will be applied.
     Note that this is potentially dangerous in production code, since memory
     consumption will grow endlessly unless you manually clear the buffer
     periodically.

     - parameter reverseChronological: If `true`, the items in the buffer will
     be stored in reverse chronological order: the first item in the buffer
     array will be the newest, while the last item will be the oldest. 
     Otherwise, the array will be ordered from oldest to newest.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.

     - parameter createBufferItem: The function used to create `BufferItem`
     instances for each `LogEntry` and formatted message string passed to the
     receiver's `record`()` function.
     */
    public init(formatters: [LogFormatter], bufferLimit: Int = 10_000, reverseChronological: Bool = false, queue: DispatchQueue? = nil, createBufferItem: @escaping (LogEntry, String) -> BufferItem)
    {
        self.buffer = []
        self.bufferLimit = bufferLimit
        self.reverseChronological = reverseChronological
        self.createBufferItem = createBufferItem

        self.didRecordItemCallbacks = CallbackRegistry<(_ recorder: BufferedLogRecorder<BufferItem>, _ item: BufferItem, _ didTruncateBuffer: Bool) -> Void>()
        self.didClearBufferCallbacks = CallbackRegistry<(_ recorder: BufferedLogRecorder<BufferItem>) -> Void>()

        super.init(formatters: formatters, queue: queue)
    }

    /**
     Adds a callback function that will be executed on the main thread once for
     each call to `record()`.
     
     When the callback function is executed, the receiver will be passed as the
     `recorder` parameter, along with the recorded `BufferItem` and a boolean
     flag indicating whether the buffer was truncated due to hitting the
     `bufferLimit`.
     
     - note: By the time `callback` is executed, the item will have already
     been added to the buffer array.

     - parameter callback: The callback function to be executed whenever a
     log entry is recorded.
     
     - returns: A `CallbackHandle` that governs the time during which `callback`
     is eligible for execution. Once the `CallbackHandle` deallocates—or its
     `stop()` function—`callback` will no longer be executed. You must therefore
     retain this `CallbackHandle` for as long as you want `callback` to be
     considered for execution.
     */
    open func addCallback(didRecordBufferItem callback: @escaping (_ recorder: BufferedLogRecorder<BufferItem>, _ item: BufferItem, _ didTruncateBuffer: Bool) -> Void)
        -> CallbackHandle
    {
        return didRecordItemCallbacks.addCallback(callback)
    }

    /**
     Adds a callback function that will be executed on the main thread whenever
     the receiver's `clear()` function is called.

     When the callback function is executed, the receiver will be passed as 
     the `recorder` parameter.

     - note: By the time `callback` is executed, the buffer will have already 
     been cleared.

     - parameter callback: The callback function to be executed whenever the
     buffer is cleared.

     - returns: A `CallbackHandle` that governs the time during which `callback`
     is eligible for execution. Once the `CallbackHandle` deallocates—or its
     `stop()` function—`callback` will no longer be executed. You must therefore
     retain this `CallbackHandle` for as long as you want `callback` to be 
     considered for execution.
     */
    open func addCallback(didClearBuffer callback: @escaping (_ recorder: BufferedLogRecorder<BufferItem>) -> Void)
        -> CallbackHandle
    {
        return didClearBufferCallbacks.addCallback(callback)
    }

    /**
     Called by the `LogReceptacle` to record the formatted log message.

     - note: This function is only called if one of the `formatters` associated
     with the receiver returned a non-`nil` string for the given `LogEntry`.

     - parameter message: The message to record.

     - parameter entry: The `LogEntry` for which `message` was created.

     - parameter currentQueue: The GCD queue on which the function is being
     executed.

     - parameter synchronousMode: If `true`, the receiver should record the log
     entry synchronously and flush any buffers before returning.
     */
    open override func record(message: String, for entry: LogEntry, currentQueue: DispatchQueue, synchronousMode: Bool)
    {
        let item = createBufferItem(entry, message)

        var didTruncate = false
        if bufferLimit > 0 && buffer.count + 1 > bufferLimit {
            if reverseChronological {
                buffer.removeLast()
            } else {
                buffer.removeFirst()
            }
            didTruncate = true
        }

        if reverseChronological {
            buffer.insert(item, at: 0)
        } else {
            buffer.append(item)
        }

        for callback in didRecordItemCallbacks.callbacks() {
            callback(self, item, didTruncate)
        }
    }

    /**
     Clears the contents of the buffer.
     
     This operation is performed synchronously on the receiver's `queue`
     to ensure thread safety.
     */
    public func clear()
    {
        // ensures consistent access to buffer
        queue.sync {
            self.buffer.removeAll(keepingCapacity: true)

            for callback in didClearBufferCallbacks.callbacks() {
                callback(self)
            }
        }
    }
}

/**
 The `BufferedMessageRecorder` buffers the formatted log messages passed to
 its `record()` function.
 */
open class BufferedMessageRecorder: BufferedLogRecorder<String>
{
    /**
     Initializes a new `BufferedMessageRecorder`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter bufferLimit: If this value is positive, it specifies the
     maximum number of items to store in the buffer. If `record()` is called
     when the buffer limit has been reached, the oldest item in the buffer will
     be dropped. If this value is zero or negative, no limit will be applied.
     Note that this is potentially dangerous in production code, since memory
     consumption will grow endlessly unless you manually clear the buffer
     periodically.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public init(formatters: [LogFormatter], bufferLimit: Int = 10_000, queue: DispatchQueue? = nil)
    {
        super.init(formatters: formatters, bufferLimit: bufferLimit, queue: queue) { _, message in
            return message
        }
    }
}

/**
 The `BufferedLogEntryRecorder` buffers each `LogEntry` passed to its
 `record()` function.
 */
open class BufferedLogEntryRecorder: BufferedLogRecorder<LogEntry>
{
    /**
     Initializes a new `BufferedLogEntryRecorder`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter bufferLimit: If this value is positive, it specifies the
     maximum number of items to store in the buffer. If `record()` is called
     when the buffer limit has been reached, the oldest item in the buffer will
     be dropped. If this value is zero or negative, no limit will be applied.
     Note that this is potentially dangerous in production code, since memory
     consumption will grow endlessly unless you manually clear the buffer
     periodically.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public init(formatters: [LogFormatter], bufferLimit: Int = 10_000, queue: DispatchQueue? = nil)
    {
        super.init(formatters: formatters, bufferLimit: bufferLimit, queue: queue) { entry, _ in
            return entry
        }
    }
}

/**
 The `BufferedLogEntryMessageRecorder` buffers each `LogEntry` and formatted
 message passed to its `record()` function.
 */
open class BufferedLogEntryMessageRecorder: BufferedLogRecorder<(LogEntry, String)>
{
    /**
     Initializes a new `BufferedLogEntryMessageRecorder`.

     - parameter formatters: An array of `LogFormatter`s to use for formatting
     log entries to be recorded by the receiver. Each formatter is consulted in
     sequence, and the formatted string returned by the first formatter to
     yield a non-`nil` value will be recorded. If every formatter returns `nil`,
     the log entry is silently ignored and not recorded.

     - parameter bufferLimit: If this value is positive, it specifies the
     maximum number of items to store in the buffer. If `record()` is called
     when the buffer limit has been reached, the oldest item in the buffer will
     be dropped. If this value is zero or negative, no limit will be applied.
     Note that this is potentially dangerous in production code, since memory
     consumption will grow endlessly unless you manually clear the buffer
     periodically.

     - parameter queue: The `DispatchQueue` to use for the recorder. If `nil`,
     a new queue will be created.
     */
    public init(formatters: [LogFormatter], bufferLimit: Int = 10_000, queue: DispatchQueue? = nil)
    {
        super.init(formatters: formatters, bufferLimit: bufferLimit, queue: queue) { entry, message in
            return (entry, message)
        }
    }
}
