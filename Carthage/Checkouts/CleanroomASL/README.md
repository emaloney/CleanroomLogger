![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# CleanroomASL

CleanroomASL is an iOS framework providing a Swift-based API for writing to and reading from [the Apple System Log (ASL) facility](#about-the-apple-system-log).

CleanroomASL is designed as a thin wrapper around ASL’s native C API that makes use of Swift concepts where appropriate to make coding easier-to-understand and less error-prone.

CleanroomASL is part of [the Cleanroom Project](https://github.com/gilt/Cleanroom) from [Gilt Tech](http://tech.gilt.com).


#### Who It’s For

If you need to read from your application’s log on the device, CleanroomASL is for you. CleanroomASL is also useful if you need low-level access to writing to the Apple System Log.

#### Who It’s Not For

Because CleanroomASL is a low-level API, it may be cumbersome to use for common logging tasks.

If you’d like to use a simple, high-level Swift API for logging within your iOS application, consider using [the CleanroomLogger project](https://github.com/emaloney/CleanroomLogger).

CleanroomLogger uses CleanroomASL under the hood, but provides a simpler API that will be more familiar to developers who’ve used other logging systems such as CocoaLumberjack or log4j.

CleanroomLogger is also extensible, allowing you to multiplex log output to multiple destinations and to add your own logger implementations.


### Swift 2.2 compatibility

The `master` branch of this project is **Swift 2.2 compliant** and therefore **requires Xcode 7.3 or higher** to compile.

### License

CleanroomASL is distributed under [the MIT license](/blob/master/LICENSE).

CleanroomASL is provided for your use—free-of-charge—on an as-is basis. We make no guarantees, promises or apologies. *Caveat developer.*


### Adding CleanroomASL to your project

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

You’ll need to [integrate CleanroomASL into your project](https://github.com/emaloney/CleanroomASL/blob/master/INTEGRATION.md) in order to use [the API](https://rawgit.com/emaloney/CleanroomASL/master/Documentation/API/index.html) it provides. You can choose:

- [Manual integration](https://github.com/emaloney/CleanroomASL/blob/master/INTEGRATION.md#manual-integration), wherein you embed CleanroomASL’s Xcode project within your own, **_or_**
- [Using the Carthage dependency manager](https://github.com/emaloney/CleanroomASL/blob/master/INTEGRATION.md#carthage-integration) to build a framework that you then embed in your application.

Once integrated, just add the following `import` statement to any Swift file where you want to use CleanroomASL:

```swift
import CleanroomASL
```

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



### API documentation

For detailed information on using CleanroomASL, [API documentation](https://rawgit.com/emaloney/CleanroomASL/master/Documentation/API/index.html) is available.


## About the Apple System Log

ASL may be most familiar to Mac and iOS developers as the subsystem that underlies the [`NSLog()`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/index.html#//apple_ref/c/func/NSLog) function.

When running within Xcode, `NSLog()` output shows up in the Console view.

On the Mac, messages written to ASL are available in the Console application.

For these reasons, people sometimes think of ASL as “the console,” even though that’s a bit of a misnomer:

- Xcode’s Console view shows the  `stdout` and `stderr` streams of the running process. Because `NSLog()` uses ASL configured in such a way that log messages are echoed to `stderr`, those messages show up in Xcode’s Console view. But the Console view can also show messages that *weren’t* sent through ASL.

- The Console application on the Mac can be thought of as a *viewer* for ASL log messages, but it only shows a subset of the information that can be sent along with an ASL message. Further, Console is not limited to ASL; it can also be used to follow the content of standard text log files.

#### Differences between the device and simulator

On iOS, the Apple System Log behaves differently depending on whether it is running on a device or in the iOS Simulator.

|Behavior|Simulator|Device|
|---|---------|------|
|Visibility|By default, log entries are visible to root and to the UID of the process that recorded them|By default, log entries are visible only to root|
|Searching|Searches can return log entries recorded by any process|Searches will only return log entries recorded by the calling process|

On the device, in order for an ASL log entry to be visible to the process that recorded it, the `.ReadUID` attribute of the `ASLMessageObject` must be explicitly set to `-1`. Otherwise, the log entry will be visible only to root, and if the process is trying to search for its own log entries, they won't be returned.

To avoid this causing confusion, the CleanroomASL framework automatically sets a message's `.ReadUID` attribute to `-1` if no value is explicitly specified.

> If you do in fact want your messages visible only to root, you can ensure that your log entries are recorded as you intend by specifying a `.ReadUID` attribute value of `0`. This will prevent CleanroomASL from automatically setting that attribute value to `-1`.

#### Learning more about ASL

Apple’s native API for ASL is written in C. The definitive documentation for ASL can be found in the manpage that can be accessed using the [`man 3 asl`](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/asl.3.html) Terminal command.

Peter Hosey’s *Idle Time* blog also has [a number of informative posts on ASL](http://boredzo.org/blog/archives/category/programming/apple-system-logger) helpful to anyone who wants to understand how it works.


## About

The Cleanroom Project began as an experiment to re-imagine Gilt’s iOS codebase in a legacy-free, Swift-based incarnation.

Since then, we’ve expanded the Cleanroom Project to include multi-platform support. Much of our codebase now supports tvOS in addition to iOS, and our lower-level code is usable on Mac OS X and watchOS as well.

Cleanroom Project code serves as the foundation of Gilt on TV, our tvOS app [featured by Apple during the launch of the new Apple TV](http://www.apple.com/apple-events/september-2015/). And as time goes on, we'll be replacing more and more of our existing Objective-C codebase with Cleanroom implementations.

In the meantime, we’ll be tracking the latest releases of Swift & Xcode, and [open-sourcing major portions of our codebase](https://github.com/gilt/Cleanroom#open-source-by-default) along the way.


### Contributing

CleanroomASL is in active development, and we welcome your contributions.

If you’d like to contribute to this or any other Cleanroom Project repo, please read [the contribution guidelines](https://github.com/gilt/Cleanroom#contributing-to-the-cleanroom-project).


### Acknowledgements

[API documentation for CleanroomASL](https://rawgit.com/emaloney/CleanroomASL/master/Documentation/API/index.html) is generated using [Realm](http://realm.io)’s [jazzy](https://github.com/realm/jazzy/) project, maintained by [JP Simard](https://github.com/jpsim) and [Samuel E. Giddins](https://github.com/segiddins).

