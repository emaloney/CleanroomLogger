## Using CleanroomASL

The CleanroomASL framework provides a simple mechanism for writing to the Apple System Log, and it can also be used to query the contents of the Apple System Log in order to find messages matching specific criteria.

#### The ASLClient class

The `ASLClient` class provides a `log()` function for writing to the Apple System Log, and also provides a `search()` function for reading.

Each `ASLClient` instance represents a connection to the ASL daemon. If you're only writing to ASL, a single `ASLClient` instance per application is sufficient for most uses, but if you find cases where you need to use multiple instances for writing, that will work as well.

Because the underlying ASL connections are not inherently thread-safe, the `ASLClient` class maintains its own Grand Central Dispatch queue which it uses to serialize use of the connection. This enforces a reliable ordering of log writes when using a single `ASLClient` and also ensures safe access to the shared client resource.

> **Note:** Because of this design, each `ASLClient` instance may be used safely from any thread without any additional work on your part.

If your application is going to be writing to ASL *and* querying it, you may want to use a separate `ASLClient` instance for each individual search session to ensure that multiple concurrent searches do not slow down log writing or each other in the GCD queue.

By default, logging is performed asynchronously, which also provides performance benefits; on device, writing to ASL and mirroring to `stderr` can be expensive. Using `NSLog()` indiscriminately from the main thread can cause a noticeable performance degradation for UI operations such as scrolling and refreshing the display. `ASLClient` avoids this and allows your scrolling to be buttery smooth—and if scrolling isn't buttery smooth, *at least you'll know it's not the fault of your logging code!*

#### Writing to the Apple System Log

To write to the Apple System Log, construct an `ASLMessageObject` and pass it to the `log()` function of an `ASLClient` instance:

```swift
let client = ASLClient()
let message = ASLMessageObject(priorityLevel: .Notice, message: "This is my message. There are many like it, but this one is mine.")
client.log(message)
```

In the example above, the text "`This is my message. There are many like it, but this one is mine.`" will be written asynchronously to the Apple System Log at the `.Notice` priority level.

#### Querying the Apple System Log

The `ASLQueryObject` class is used to perform search queries of the Apple System Log. Using the `setQueryKey()` function, you can specify search criteria for the messages you want to find:

```swift
let query = ASLQueryObject()
query.setQueryKey(.Message, value: nil, operation: .KeyExists, modifiers: .None)
query.setQueryKey(.Level, value: ASLPriorityLevel.Warning.priorityString, operation: .LessThanOrEqualTo, modifiers: .None)
query.setQueryKey(.Time, value: Int(NSDate().timeIntervalSince1970 - (60 * 5)), operation: .GreaterThanOrEqualTo, modifiers: .None)
```

The code above creates a search query that will find all log entries with a minimum priority level of `.Warning` recorded in the last 5 minutes that also have a value for the `.Message` attribute key.

> **Note:** The sort order of ASL priority levels is counter-intuitive; the *highest priority level* (`.Emergency`) has the *lowest numeric value* (`0`) whereas the *lowest priority level* (`.Debug`) has the *highest numeric value* (`7`). Because CleanroomASL aims to be as thin a wrapper around ASL as possible, we do not change this behavior. That's why the `.LessThanOrEqualTo` operation is used to find messages with an `ASLPriorityLevel` of `.Warning` and higher.

To start the search, pass the `query` object to the client's `search()` function and provide a callback that will be executed once for each log entry matching the search criteria specified by `query`:

```swift
client.search(query) { record in
    if let record = record {
      // we have a search query result record; process it here
    } else {
      // there are no more records to process; no further callbacks will be issued
    }
    return true   // returning true to indicate we want more results if available
}
```

The second parameter to the `search()` function is of type `ASLQueryObject.ResultCallback`, a closure having the signature `(ResultRecord?) -> Bool`. The callback is passed a non-`nil` `ASLQueryObject.ResultRecord` instance for each record matching the search criteria, and when no more results are available, `nil` is passed.

Using its return value, the callback can control whether subsequent records are reported by the search operation. As long as the callback is willing to accept further results, it should return `true`. When the callback no longer wishes to process results, it should return `false`.

> Once `nil` is passed to the callback or the callback returns `false`, the callback will not be executed again for the given search operation.
