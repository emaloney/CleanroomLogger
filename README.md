![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# CleanroomLogger

CleanroomLogger provides a simple, lightweight Swift logging API designed to be readily understood by anyone familiar with packages such as [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) and [log4j](https://en.wikipedia.org/wiki/Log4j).

By default, CleanroomLogger messages are directed to the Apple System Log and to the `stderr` output stream of the running process. 

Because CleanroomLogger is designed to be *configurable* and *extensible*, however, it's easy to change the behavior of logging or to add code to write log messages to a database, local files, remote HTTP endpoints, or any other sort of data store you might desire.

## Quick Intro

The main public API for CleanroomLogger is provided by [the `Log` struct](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html).

`Log` maintains five static read-only `LogChannel` properties that correspond to one of five [*severity levels*](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Enums/LogSeverity.html) indicating the importance of messages sent through that channel. When sending a message, you would select a severity appropriate for that message, and use the corresponding channel:

- `Log.error` — The highest severity; something has gone wrong and a fatal error may be imminent
- `Log.warning` — Something appears amiss and might bear looking into before a larger problem arises
- `Log.info` — Something notable happened, but it isn't anything to worry about
- `Log.debug` — Used for debugging and diagnostic information (not intended for use in production code)
- `Log.verbose` - The lowest severity; used for detailed or frequently occurring debugging and diagnostic information (not intended for use in production code)

Each of these `LogChannel`s provide three functions to record log messages:

- `trace()` — This function records a log message with program executing trace information including the filename, line number and name of the calling function.
- `message(String)` — This function records the log message passed to it.
- `value(Any?)` — This function attempts to record a log message containing a string representation of the optional `Any` value passed to it. 

### Logging examples

To send record items in the log, simply select the appropriate channel and call the appropriate function.

Here are a few examples:

#### Logging an arbitrary text message

Let's say your application just finished launching. This is a significant event, but it isn't an error. You also might want to see this information in production app logs. Therefore, you decide the appropriate `LogSeverity` is `.Info` and you select the corresponding `LogChannel`, which is `Log.info`:

```swift
Log.info?.message("The application has finished launching.")
```

#### Logging a trace message

If you're working on some code and you're curious about the order of execution, you can sprinkle some `trace()` calls around.

This function outputs the filename, line number and name of the calling function.

For example, if you put the following code on line 364 of a file called ModularTable.swift in a function with the signature `tableView(_:cellForRowAtIndexPath:)`:

```swift
Log.debug?.trace()
```

The following message would be logged when that line gets executed:

```
ModularTable.swift:364 — tableView(_:cellForRowAtIndexPath:)
```

> **Note:** Because trace information is typically not desired in production code, you would generally only perform tracing at the `.Debug` or `.Verbose` severity levels.

#### Logging an arbitrary value

The `value()` function can be used for outputting information about a specific value. The function takes an argument of type `Any?` and is intended to accept any valid runtime value.

For example, you might want to output the `NSIndexPath` value passed to your `UITableViewDataSource`'s `tableView(_: cellForRowAtIndexPath:)` function:

```swift
Log.verbose?.value(indexPath)
```

This would result in output looking like:

```
<NSIndexPath: 0xc0000000000180d6> {length = 2, path = 3 - 3}
```

> **Note:** Although every attempt is made to create a string representation of the value passed to the function, there is no guarantee that a given log implementation will support values of a given type.

### Designed for optimal performance

Each `LogChannel` maintained by `Log` is exposed as an optional. Depending on how the logging system has been configured at runtime, a given `LogChannel` may be `nil`.

For example, in production code, we recommend setting `.Info` as the minimum `LogSeverity` required for logging. That means messages with a severity of `.Verbose` or `.Debug` would be ignored. To avoid unneeded code execution, in such cases `Log.debug` and `Log.verbose` would be `nil`, allowing efficient short-circuiting in Swift.
