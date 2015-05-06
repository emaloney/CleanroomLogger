![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# CleanroomLogger

CleanroomLogger provides a simple, lightweight Swift logging API designed to be readily understood by anyone familiar with packages such as [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) and [log4j](https://en.wikipedia.org/wiki/Log4j).

CleanroomLogger is part of [the Cleanroom Project](http://github.com/gilt/Cleanroom) from [Gilt Tech](http://tech.gilt.com).

## What it’s for

If you're familiar with [`NSLog()`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/index.html#//apple_ref/c/func/NSLog), then you'll understand the purpose of CleanroomLogger.

As with `NSLog()`, CleanroomLogger messages are (by default) directed to the Apple System Log and to the `stderr` output stream of the running process.

However, CleanroomLogger adds several important features not provided by `NSLog()`:

1. Each log message is associated with a [`LogSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Enums/LogSeverity.html) value that indicates the importance of the message. This enables you to very easily do things like squelch out low-priority messages—such as those logged with `.Debug` and `.Verbose` severity values—in production binaries, thereby lessening the amount of work your App Store build does at runtime.

2. CleanroomLogger provides code execution tracing functionality through the `trace()` function. A simple no-argument function call is all that's needed to log the source filename, line number and function name of the caller. This makes it easy to understand the path your code is taking as it executes.

3. CleanroomLogger is *configurable*; its behavior can be modified by through different configuration options specified when logging is activated. You can configure the logging engine through the parameter values specified when constructing a new [`DefaultLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/DefaultLogConfiguration.html) instance, or you can provide your own implementation of the [`LogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Protocols/LogConfiguration.html) protocol if that doesn't suit your needs.

4. CleanroomLogger is *extensible*. Several extension points are available, allowing you to provide custom implementations for specific functionality within the logging process:
  - A [`LogFilter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Protocols/LogFilter.html) implementation can inspect--and potentially block--any log message before it is recorded.
  - A custom [`LogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Protocols/LogFormatter.html) implementation can be used to generate string representations in a specific format for each `LogEntry` that gets recorded  
  - The [`LogRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Protocols/LogRecorder.html) protocol makes it possible to create custom log message storage implementations. This is where to start if you want to provide a custom solution to write log messages to a database table, a local file, or a remote HTTP endpoint, for example.

5. CleanroomLogger puts the application developer in control. The behavior of logging is set once, early in the application within the `UIApplicationDelegate` implementation; after that, the configuration is immutable for the remainder of the application's life. Any code using CleanroomLogger through [the `Log` API](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html), including embedded frameworks, shared libraries, Cocoapods, etc. will automatically adhere to the policy establushed by the application developer Embedded code that uses CleanroomLogger is inherently *well behaved*, whereas code using plain old `NSLog()` is not; third-party code using `NSLog()` give no control to the application developer.

6. CleanroomLogger is respectful of the calling thread. `NSLog()` does a lot of work on the calling thread, and when used from the main thread, it can lead to lower display frame rates. When CleanroomLogger accepts a log request, it is immediately handed off to an asynchronous background queue for further dispatching, letting the calling thread get back to work as quickly as possible. Each `LogRecorder` also maintains its own asynchronous background queue, which is used to format log messages and write them to the underlying storage facility. This design ensures that if one recorder gets bogged down, it won't prevent the processing of log messages by other recorders.

7. CleanroomLogger uses Swift short-circuiting to avoid executing code when a given `LogChannel` shouldn't be used. Each `LogChannel` maintained by `Log` is exposed as an optional. Depending on how the logging system has been configured at runtime, a given `LogChannel` may be `nil`. For example, in production code, we recommend setting `.Info` as the minimum `LogSeverity` required for logging, meaning that messages with a severity of `.Verbose` or `.Debug` would be ignored. To avoid unneeded code execution, in such cases `Log.debug` and `Log.verbose` would be `nil`, allowing efficient short-circuiting of any code using those channels.

## In a nutshell: Using CleanroomLogger

The main public API for CleanroomLogger is provided by [`Log`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html).

`Log` maintains five static read-only [`LogChannel`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/LogChannel.html) properties that correspond to one of five *severity levels* indicating the importance of messages sent through that channel. When sending a message, you would select a severity appropriate for that message, and use the corresponding channel:

- [`Log.error`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5errorGSqVS_10LogChannel_) — The highest severity; something has gone wrong and a fatal error may be imminent
- [`Log.warning`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7warningGSqVS_10LogChannel_) — Something appears amiss and might bear looking into before a larger problem arises
- [`Log.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html#/s:ZvV15CleanroomLogger3Log4infoGSqVS_10LogChannel_) — Something notable happened, but it isn't anything to worry about
- [`Log.debug`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5debugGSqVS_10LogChannel_) — Used for debugging and diagnostic information (not intended for use in production code)
- [`Log.verbose`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7verboseGSqVS_10LogChannel_) - The lowest severity; used for detailed or frequently occurring debugging and diagnostic information (not intended for use in production code)

Each of these `LogChannel`s provide three functions to record log messages:

- [`trace()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5traceFS0_FT8functionSS8filePathSS8fileLineSi_T_) — This function records a log message with program executing trace information including the filename, line number and name of the calling function.
- [`message(String)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel7messageFS0_FTSS8functionSS8filePathSS8fileLineSi_T_) — This function records the log message passed to it.
- [`value(Any?)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5valueFS0_FTGSqP__8functionSS8filePathSS8fileLineSi_T_) — This function attempts to record a log message containing a string representation of the optional `Any` value passed to it. 

### Enabling logging

By default, logging is disabled, meaning that none of the `Log`'s channels have been populated. As a result, they have `nil` values and any attempts to perform logging will silently fail.

It is the responsibility of the *application developer* to enable logging, which is done by calling the appropriate `Log.enable()` function.

> The reason we specifically say that the application developer is responsible for enabling logging is to give the developer the power to control the use of logging process-wide. As with any code that executes, there's an expense to logging, and the application developer should get to decide how to handle the tradeoff between the utility of collecting logs and the expense of collecting them at a given level of detail.
>
> CleanroomLogger is built to be used from within frameworks, shared libraries, Cocoapods, etc., as well as at the application level. However, any code designed to be embedded in other applications **must** interact with CleanroomLogger via the `Log` API **only**. Also, embedded code **must never** call `Log.enable()`, because by doing so, control is taken away from the application developer.
>
> **The general rule is, if you didn't write the `UIApplicationDelegate` for the app in which the code will execute, don't ever call `Log.enable()`.**

Ideally, logging is enabled at the first possible point in the application's launch cycle. Otherwise, critical log messages may be missed during launch because the logger wasn't yet initialized.

The best place to put the call to `Log.enable()` is at the first line of your app delegate's `init()`.

If you'd rather not do that for some reason, the next best place to put it is in the `application(_:willFinishLaunchingWithOptions:)` function of your app delegate. We're specifically recommending the `will` function, not the typical `did`, because the former is called earlier in the application's launch cycle.

> **Note:** During the running lifetime of an application process, only the *first* call to `Log.enable()` function will have any effect. All subsequent calls are ignored silently.

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
