//
//  ASLClient.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

/**
The signature of the `ASLClient`'s search query callback function.

When a client's `search` function is called, the callback function is provided
as a parameter. The callback is also provided the client instance executing the
query, as well as the query instance itself.

For each query result, the callback is executed once, receiving
the `ASLLogEntry` associated with the result. When there are no more results
to deliver, the callback is executed one final time with a `nil` value
passed as the result.

Each time the callback is executed, it should return `true` unless it wants
to stop receiving further callbacks.

Once the callback returns `false`, it will not be called again.
*/
public typealias ASLQueryCallback = (client: ASLClient, query: ASLQueryObject, result: ASLLogEntry?) -> Bool

/**
`ASLClient` instances maintain a connection to the ASL daemon. Because the
underlying client connection is not intended to be shared across threads,
you should only ever use a given `ASLClient` instance from a single thread.
*/
public class ASLClient
{
    /**
    Represents ASL client creation option values, which are used to determine
    the behavior of an `ASLClient`. These are bit-flag values that can be
    combined and otherwise manipulated with bitwise operators.
    */
    public struct Options: RawOptionSetType, BooleanType
    {
        /// Returns the raw `UInt32` value representing the receiver's bit
        /// flags.
        public var rawValue: UInt32 { return self.value }

        /// `true` if the receiver has at least one bit flag set; `false` if
        /// none are set.
        public var boolValue: Bool { return self.value != 0 }

        private var value: UInt32

        /**
        Initializes a new `ASLClient.Options` value with the specified
        raw value.
        
        :param:     rawValue A `UInt32` value containing the raw bit flag
                    values to use.
        */
        public init(_ rawValue: UInt32) { self.value = rawValue }

        /**
        Initializes a new `ASLClient.Options` value with the specified
        raw value.
        
        :param:     rawValue A `UInt32` value containing the raw bit flag
                    values to use.
        */
        public init(rawValue: UInt32) { self.value = rawValue }

        /**
        Initializes a new `ASLClient.Options` value with a nil literal,
        which would be the equivalent of the `.None` value.
        */
        public init(nilLiteral: ()) { self.value = 0 }

        /// Returns an `ASLClient.Options` value wherein none of the bit
        /// flags are set.
        public static var allZeros: Options   { return self(0) }

        /// Returns an `ASLClient.Options` value wherein none of the bit
        /// flags are set. Equivalent to `allZeros`.
        public static var None: Options       { return self(0) }

        /// Returns an `ASLClient.Options` value with the `ASL_OPT_STDERR` flag
        /// set.
        public static var StdErr: Options     { return self(0x00000001) }

        /// Returns an `ASLClient.Options` value with the `ASL_OPT_NO_DELAY`
        /// flag set.
        public static var NoDelay: Options    { return self(0x00000002) }

        /// Returns an `ASLClient.Options` value with the `ASL_OPT_NO_REMOTE`
        /// flag set.
        public static var NoRemote: Options   { return self(0x00000004) }
    }

    public let sender: String?
    public let facility: String?
    public let options: Options
    public let queue: dispatch_queue_t

    private var client: aslclient?

    public var isOpen: Bool { return client != nil }

    public init(sender: String? = nil, facility: String? = nil, options: Options = .StdErr)
    {
        self.sender = sender
        self.facility = facility
        self.options = options
        self.queue = dispatch_queue_create("ASLClient.\(sender)", DISPATCH_QUEUE_SERIAL)
    }

    deinit {
        if let c = client {
            asl_close(c)
        }
    }

    public func open()
    {
        if client == nil {
            client = asl_open(sender ?? nil, facility ?? nil, options.rawValue)
        }
    }

    public func close()
    {
        if let c = client {
            asl_close(c)
            client = nil
        }
    }

    private func acquireClient()
        -> aslclient
    {
        if !isOpen {
            open()
        }
        return client!
    }

    private func dispatcher(synchronously: Bool = false)(block: dispatch_block_t)
    {
        if synchronously {
            return dispatch_sync(queue, block)
        } else {
            return dispatch_async(queue, block)
        }
    }

    public func log(message: ASLMessageObject, logSynchronously: Bool = false)
    {
        let dispatch = dispatcher(synchronously: logSynchronously)
        dispatch {
            asl_send(client!, message.aslObject)
        }
    }

    /**
    Asynchronously reads the ASL log, issuing one call to the callback function
    for each relevant entry in the log.

    Only entries that have a valid timestamp and message will be provided to
    the callback.

    :param:     query The `ASLQueryObject` representing the search query to run.

    :param:     callback The callback function to be invoked for each log entry.
                Make no assumptions about which thread will be calling the
                function.
    */
    public func search(query: ASLQueryObject, callback: ASLQueryCallback)
    {
        let dispatch = dispatcher()
        dispatch {
            let results = asl_search(self.acquireClient(), query.aslObject)

            var keepGoing = true
            var record = asl_next(results)
            while record != nil && keepGoing {
                if let message = record[.Message] {
                    if let timestampStr = record[.Time] {
                        if let timestampInt = timestampStr.toInt() {
                            var timestamp = NSTimeInterval(timestampInt)

                            if let nanoStr = record[.TimeNanoSec] {
                                if let nanoInt = nanoStr.toInt() {
                                    let nanos = Double(nanoInt) / Double(NSEC_PER_SEC)
                                    timestamp += nanos
                                }
                            }

                            let logEntryTime = NSDate(timeIntervalSinceReferenceDate: timestamp)

                            var priority = ASLPriorityLevel.Notice
                            if let logLevelStr = record[.Level],
                                let logLevelInt = logLevelStr.toInt(),
                                let level = ASLPriorityLevel(rawValue: logLevelInt)
                            {
                                priority = level
                            }

                            keepGoing = callback(client: self, query: query, result: ASLLogEntry(priority: priority, message: message, timestamp: logEntryTime))
                        }
                    }
                }
                record = asl_next(results)
            }

            if keepGoing {
                callback(client: self, query: query, result: nil)
            }

            asl_release(results)
        }
    }
}
