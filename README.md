![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# CleanroomLogger

CleanroomLogger provides an extensible Swift-based logging API that is simple, lightweight and performant.
		
The API provided by CleanroomLogger is designed to be readily understood by anyone familiar with packages such as [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) and [log4j](https://en.wikipedia.org/wiki/Log4j).

CleanroomLogger is part of [the Cleanroom Project](https://github.com/gilt/Cleanroom) from [Gilt Tech](http://tech.gilt.com).


### Swift compatibility

**Important:** This is the `swift2.3` branch. It is **Swift 2.3 compliant** and therefore **requires Xcode 8.0** to compile.

2 other branches are also available:

 - The [`master`](https://github.com/emaloney/CleanroomLogger) branch uses **Swift 2.2**, requiring Xcode 7.3
 - The [`swift3`](https://github.com/emaloney/CleanroomLogger/tree/swift3) branch uses **Swift 3.0**, requiring Xcode 8.0


#### Current status

Branch|Build status
--------|------------------------
[`master`](https://github.com/emaloney/CleanroomLogger)|[![Build status: master branch](https://travis-ci.org/emaloney/CleanroomLogger.svg?branch=master)](https://travis-ci.org/emaloney/CleanroomLogger)
[`swift2.3`](https://github.com/emaloney/CleanroomLogger/tree/swift2.3)|[![Build status: swift2.3 branch](https://travis-ci.org/emaloney/CleanroomLogger.svg?branch=swift2.3)](https://travis-ci.org/emaloney/CleanroomLogger)
[`swift3`](https://github.com/emaloney/CleanroomLogger/tree/swift3)|[![Build status: swift3 branch](https://travis-ci.org/emaloney/CleanroomLogger.svg?branch=swift3)](https://travis-ci.org/emaloney/CleanroomLogger)


#### Why CleanroomLogger?

If you’re familiar with [`NSLog()`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/index.html#//apple_ref/c/func/NSLog), then you’ll understand the purpose of CleanroomLogger.

As with `NSLog()`, CleanroomLogger messages are (by default) directed to the Apple System Log and to the `stderr` output stream of the running process.

However, CleanroomLogger adds a number of important features not provided by `NSLog()`:

1. **Each log message is associated with a [`LogSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html) value indicating the importance of that message.** This enables you to very easily do things like squelch out low-priority messages—such as those logged with `.Debug` and `.Verbose` severity values—in production binaries, thereby lessening the amount of work your App Store build does at runtime.

2. **CleanroomLogger makes it easy to find the _where_ your code is issuing log messages.** With `NSLog()` and `print()`, it can sometimes be difficult to figure out what code is responsible for generating log messages. When a message is constructed programmatically, for example, it may not be possible to find its source. CleanroomLogger outputs the file and line responsible for each log message, so you can literally *go straight to the source*.

3. **CleanroomLogger provides code execution tracing functionality through the `trace()` function.** A simple no-argument function call is all that’s needed to log the source filename, line number and function name of the caller. This makes it easy to understand the path your code is taking as it executes.

4. **CleanroomLogger is _configurable_**; its behavior can be modified by through different configuration options specified when logging is activated. You can configure the logging engine through the parameter values specified when constructing a new [`DefaultLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/DefaultLogConfiguration.html) instance, or you can provide your own implementation of the [`LogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html) protocol if that doesn’t suit your needs.

5. **CleanroomLogger is _extensible_**. Several extension points are available, allowing you to provide custom implementations for specific functionality within the logging process:
  - A [`LogFilter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFilter.html) implementation can inspect--and potentially block--any log message before it is recorded.
  - A custom [`LogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFormatter.html) implementation can be used to generate string representations in a specific format for each `LogEntry` that gets recorded  
  - The [`LogRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogRecorder.html) protocol makes it possible to create custom log message storage implementations. This is where to start if you want to provide a custom solution to write log messages to a database table, a local file, or a remote HTTP endpoint, for example.

6. **CleanroomLogger puts the application developer in control.** The behavior of logging is set once, early in the application within the `UIApplicationDelegate` implementation; after that, the configuration is immutable for the remainder of the application’s life. Any code using CleanroomLogger through [the `Log` API](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html), including embedded frameworks, shared libraries, Cocoapods, etc. will automatically adhere to the policy established by the application developer. Embedded code that uses CleanroomLogger is inherently *well behaved*, whereas code using plain old `NSLog()` is not; third-party code using `NSLog()` give no control to the application developer.

7. **CleanroomLogger is respectful of the calling thread.** `NSLog()` does a lot of work on the calling thread, and when used from the main thread, it can lead to lower display frame rates. When CleanroomLogger accepts a log request, it is immediately handed off to an asynchronous background queue for further dispatching, letting the calling thread get back to work as quickly as possible. Each `LogRecorder` also maintains its own asynchronous background queue, which is used to format log messages and write them to the underlying storage facility. This design ensures that if one recorder gets bogged down, it won’t prevent the processing of log messages by other recorders.

8. **CleanroomLogger uses Swift short-circuiting to avoid needless code execution.** For example, in production code with `.Info` as the minimum `LogSeverity`, messages with a severity of `.Verbose` or `.Debug` will always be ignored. To avoid unneeded code execution, `Log.debug` and `Log.verbose` in this case would be `nil`, allowing efficient short-circuiting of any code attempting to use these inactive log channels.


### License

CleanroomLogger is distributed under [the MIT license](/blob/master/LICENSE).

CleanroomLogger is provided for your use—free-of-charge—on an as-is basis. We make no guarantees, promises or apologies. *Caveat developer.*


### Adding CleanroomLogger to your project

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

You’ll need to [integrate CleanroomLogger into your project](https://github.com/emaloney/CleanroomLogger/blob/master/INTEGRATION.md) in order to use [the API](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/index.html) it provides. You can choose:

- [Manual integration](https://github.com/emaloney/CleanroomLogger/blob/master/INTEGRATION.md#manual-integration), wherein you embed CleanroomLogger’s Xcode project within your own, **_or_**
- [Using the Carthage dependency manager](https://github.com/emaloney/CleanroomLogger/blob/master/INTEGRATION.md#carthage-integration) to build a framework that you then embed in your application.

Once integrated, just add the following `import` statement to any Swift file where you want to use CleanroomLogger:

```swift
import CleanroomLogger
```

## Using CleanroomLogger

The main public API for CleanroomLogger is provided by [`Log`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html).

`Log` maintains five static read-only [`LogChannel`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html) properties that correspond to one of five *severity levels* indicating the importance of messages sent through that channel. When sending a message, you would select a severity appropriate for that message, and use the corresponding channel:

- [`Log.error`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5errorGSqVS_10LogChannel_) — The highest severity; something has gone wrong and a fatal error may be imminent
- [`Log.warning`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7warningGSqVS_10LogChannel_) — Something appears amiss and might bear looking into before a larger problem arises
- [`Log.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log4infoGSqVS_10LogChannel_) — Something notable happened, but it isn’t anything to worry about
- [`Log.debug`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5debugGSqVS_10LogChannel_) — Used for debugging and diagnostic information (not intended for use in production code)
- [`Log.verbose`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7verboseGSqVS_10LogChannel_) - The lowest severity; used for detailed or frequently occurring debugging and diagnostic information (not intended for use in production code)

Each of these `LogChannel`s provide three functions to record log messages:

- [`trace()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5traceFS0_FT8functionSS8filePathSS8fileLineSi_T_) — This function records a log message with program executing trace information including the filename, line number and name of the calling function.
- [`message(String)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel7messageFS0_FTSS8functionSS8filePathSS8fileLineSi_T_) — This function records the log message passed to it.
- [`value(Any?)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5valueFS0_FTGSqP__8functionSS8filePathSS8fileLineSi_T_) — This function attempts to record a log message containing a string representation of the optional `Any` value passed to it. 

### Enabling logging

By default, logging is disabled, meaning that none of the `Log`’s channels have been populated. As a result, they have `nil` values and any attempts to perform logging will silently fail.

It is the responsibility of the *application developer* to enable logging, which is done by calling the appropriate variant of the `Log.enable()` function.

> The reason we specifically say that the application developer is responsible for enabling logging is to give the developer the power to control the use of logging process-wide. As with any code that executes, there’s an expense to logging, and the application developer should get to decide how to handle the tradeoff between the utility of collecting logs and the expense of collecting them at a given level of detail.
>
> CleanroomLogger is built to be used from within frameworks, shared libraries, etc., as well as at the application level. However, any code designed to be embedded in other applications **must** interact with CleanroomLogger via the [`Log`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html) API **only**.
>
> We believe so strongly that the application developer should be in full control of logging policy application-wide, that we even provide a way to ensure that CleanroomLogger is *never* enabled. That way, if you need to include a third-party library that uses CleanroomLogger, you can decide to turn it off entirely, thereby ensuring that you pay no performance penalty for logging. Just call `Log.neverEnable()`.

Ideally, logging is enabled at the first possible point in the application’s launch cycle. Otherwise, critical log messages may be missed during launch because the logger wasn’t yet initialized.

The best place to put the call to `Log.enable()` is at the first line of your app delegate’s `init()`.

If you’d rather not do that for some reason, the next best place to put it is in the `application(_:willFinishLaunchingWithOptions:)` function of your app delegate. You’ll notice that we’re specifically recommending the `will` function, not the typical `did`, because the former is called earlier in the application’s launch cycle.

> **Note:** During the running lifetime of an application process, only the *first* call to `Log.enable()` function will have any effect. All subsequent calls are ignored silently.

### Logging examples

To record items in the log, simply select the appropriate channel and call the appropriate function.

Here are a few examples:

#### Logging an arbitrary text message

Let’s say your application just finished launching. This is a significant event, but it isn’t an error. You also might want to see this information in production app logs. Therefore, you decide the appropriate [`LogSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html) is [`.Info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html#/s:FO15CleanroomLogger11LogSeverity4InfoFMS0_S0_) and you select the corresponding [`LogChannel`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html), which is [`Log.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log4infoGSqVS_10LogChannel_). Then, to log a message, just call the channel’s [`message()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel7messageFS0_FTSS8functionSS8filePathSS8fileLineSi_T_) function:

```swift
Log.info?.message("The application has finished launching.")
```

#### Logging a trace message

If you’re working on some code and you’re curious about the order of execution, you can sprinkle some [`trace()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5traceFS0_FTSS8filePathSS8fileLineSi_T_) calls around.

This function outputs the filename, line number and name of the calling function.

For example, if you put the following code on line 364 of a file called ModularTable.swift in a function with the signature `tableView(_:cellForRowAtIndexPath:)`:

```swift
Log.debug?.trace()
```

The following message would be logged when that line gets executed:

```
ModularTable.swift:364 — tableView(_:cellForRowAtIndexPath:)
```

> **Note:** Because trace information is typically not desired in production code, you would generally only perform tracing at the [`.Debug`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html#/s:FO15CleanroomLogger11LogSeverity5DebugFMS0_S0_) or [`.Verbose`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html#/s:FO15CleanroomLogger11LogSeverity7VerboseFMS0_S0_) severity levels.

#### Logging an arbitrary value

The [`value()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5valueFS0_FTGSqP__8functionSS8filePathSS8fileLineSi_T_) function can be used for outputting information about a specific value. The function takes an argument of type `Any?` and is intended to accept any valid runtime value.

For example, you might want to output the `NSIndexPath` value passed to your `UITableViewDataSource`’s `tableView(_: cellForRowAtIndexPath:)` function:

```swift
Log.verbose?.value(indexPath)
```

This would result in output looking like:

```
<NSIndexPath: 0xc0000000000180d6> {length = 2, path = 3 - 3}
```

> **Note:** Although every attempt is made to create a string representation of the value passed to the function, there is no guarantee that a given log implementation will support values of a given type.


### CleanroomLogger In Depth

This section delves into the particulars of configuring and customizing CleanroomLogger to suit your needs.

#### Configuring CleanroomLogger

CleanroomLogger is configured when one of the `Log.enable()` function variants is called. Configuration can occur at most once within the lifetime of the running process. And once set, the configuration can’t be changed; it’s immutable. (The rationale for this is [discussed here](https://github.com/emaloney/CleanroomLogger#enabling-logging).)

The [`LogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html) protocol represents the mechanism by which CleanroomLogger can be configured. `LogConfiguration`s allow encapsulating related settings and behavior within a single entity, and CleanroomLogger can be configured with multiple `LogConfiguration` instances to allow combining behaviors.

Each `LogConfiguration` specifies:

- The [`minimumSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration15minimumSeverityOS_11LogSeverity), a [`LogSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html) value that determines which log entries get recorded. Any [`LogEntry`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html) with a [`severity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html#/s:vV15CleanroomLogger8LogEntry8severityOS_11LogSeverity) less than the configuration's `mimimumSeverity` will not be passed along to any [`LogRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogRecorder.html)s specified by that configuration.
- An array of [`LogFilter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogRecorder.html)s. Each `LogFilter` is given a chance to cause a given log entry to be ignored.
- A [`synchronousMode`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration15synchronousModeSb) property, which determines whether synchronous logging should be used when processing log entries for the given configuration. *This feature is intended to be used during debugging and is not recommended for production code.*
- Zero or more contained `LogConfiguration`s. For organizational purposes, each `LogConfiguration` can in turn contain additional `LogConfiguration`s. The hierarchy is not meaningful, however, and is flattened at configuration time.
- An array of [`LogRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogRecorder.html)s that will be used to write log entries to the underlying logging facility. If a configuration has no `LogRecorder`s, it is assumed to be a container of other `LogConfiguration`s only, and is ignored when the configuration hierarchy is flattened.

When CleanroomLogger receives a request to log something, zero or more `LogConfiguration`s are selected to handle the request:

1. The `severity` of the incoming [`LogEntry`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html) is compared against the `minimumSeverity` of each `LogConfiguration`. Any `LogConfiguration` whose `minimumSeverity` is equal to or less than the `severity` of the `LogEntry` is selected for further consideration.
2. The `LogEntry` is then passed sequentially to the [`shouldRecordLogEntry(_:)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFilter.html#/s:FP15CleanroomLogger9LogFilter20shouldRecordLogEntryuRq_S0__Fq_FVS_8LogEntrySb) function of each of the `LogConfiguration`’s `filters`. If any `LogFilter` returns `false`, the associated configuration will *not* be selected to record that log entry.

##### XcodeLogConfiguration

The [`XcodeLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogConfiguration.html) is ideally suited for use during development and in production.

By default, this configuration writes log entries to the running process’s `stdout` stream (which appears within the Xcode console pane) as well as to the Apple System Log (ASL) facility.

The `XcodeLogConfiguration` also attempts to detect whether XcodeColors is installed and enabled. If it is, the `XcodeLogConfiguration` will configure CleanroomLogger to [use XcodeColors for color-coding log entries](#xcodecolors-support) by severity.

The simplest way to enable CleanroomLogger using the `XcodeLogConfiguration` is by calling:

```swift
Log.enable()
```

Thanks to the magic of default parameter values, this is equivalent to the following [`Log.enable()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZFV15CleanroomLogger3Log6enableFMS0_FT15minimumSeverityOS_11LogSeverity9debugModeSb16verboseDebugModeSb14timestampStyleGSqOS_14TimestampStyle_13severityStyleGSqOS_13SeverityStyle_12showCallSiteSb17showCallingThreadSb14suppressColorsSb7filtersGSaPS_9LogFilter___T_) call:

```swift
Log.enable(minimumSeverity: .Info,
                 debugMode: false,
          verboseDebugMode: false,
            timestampStyle: .Default,
             severityStyle: .Xcode,
              showCallSite: true,
         showCallingThread: false,
            suppressColors: false,
                   filters: [])
```

This configures CleanroomLogger using an [`XcodeLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogConfiguration.html) with [default settings](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogConfiguration.html#/s:FC15CleanroomLogger21XcodeLogConfigurationcFMS0_FT15minimumSeverityOS_11LogSeverity9debugModeSb16verboseDebugModeSb8logToASLSb14timestampStyleGSqOS_14TimestampStyle_13severityStyleGSqOS_13SeverityStyle_12showCallSiteSb17showCallingThreadSb12showSeveritySb14suppressColorsSb7filtersGSaPS_9LogFilter___S0_).

> **Note:** If either `debugMode` or `verboseDebugMode` is `true`, the `XcodeLogConfiguration` will be used in `synchronousMode`, which is not recommended for production code.

The call above is also equivalent to:

```swift
Log.enable(configuration: XcodeLogConfiguration())
```

##### RotatingLogFileConfiguration

The [`RotatingLogFileConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/RotatingLogFileConfiguration.html) can be used to maintain a directory of log files that are rotated daily.

> **Warning:** The [`RotatingLogFileRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/RotatingLogFileRecorder.html) created by the `RotatingLogFileConfiguration` assumes full control over the log directory.  Any file not recognized as an active log file will be deleted during the automatic pruning process, which may occur at any time. *This means if you’re not careful about the `directoryPath` you pass, you may lose valuable data!*

At a minimum, the `RotatingLogFileConfiguration` requires you to specify the `minimumSeverity` for logging, the number of days to keep log files, and a directory in which to store those files:

```swift
// logDir is a String holding the filesystem path to the log directory
let rotatingConf = RotatingLogFileConfiguration(minimumSeverity: .Info,
                                                     daysToKeep: 7,
                                                  directoryPath: logDir)

Log.enable(configuration: rotatingConf)
```

The code above would record any log entry with a severity of `.Info` or higher in a file that would be kept for at least 7 days before being pruned. This particular configuration uses the [`ReadableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ReadableLogFormatter.html) to format log entries.

The `RotatingLogFileConfiguration` can also be used to specify `synchronousMode`, a set of `LogFilter`s to apply, and one or more custom `LogFormatter`s.

##### Combining Configurations

CleanroomLogger also supports passing multiple configurations. This allows you to combine the behavior of different configurations.

For example, to add a debug mode `XcodeLogConfiguration` to the `rotatingConf` declared above, you could write:

```swift
Log.enable(configuration: [XcodeLogConfiguration(debugMode: true), rotatingConf])
```

In this example, both the `XcodeLogConfiguration` and the `RotatingLogFileConfiguration` will be consulted as logging occurs. Because the `XcodeLogConfiguration` is declared with `debugMode: true`, it will operate in `synchronousMode` while `rotatingConf` will operate asynchronously.

##### Implementing Your Own Configuration

Although you can provide your own implementation of the `LogConfiguration` protocol, it may be simpler to create a [`BasicLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/BasicLogConfiguration.html) instance and pass the relevant parameters to [the initializer](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/BasicLogConfiguration.html#/s:FC15CleanroomLogger21BasicLogConfigurationcFMS0_FT15minimumSeverityOS_11LogSeverity7filtersGSaPS_9LogFilter__9recordersGSaPS_11LogRecorder__15synchronousModeSb14configurationsGSqGSaPS_16LogConfiguration____S0_).

You can also subclass `BasicLogConfiguration` if you’d like to encapsulate your configuration further.

##### A Complicated Example

Let’s say you want CleanroomLogger to write to `stdout`, the Apple System Log (ASL) facility, and a set of rotating log files, and you want the log entries for each to be formatted differently:

1. An [`XcodeLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogFormatter.html) for `stdout` but not the ASL
2. A [`ReadableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ReadableLogFormatter.html) for the ASL
3. A [`ParsableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ParsableLogFormatter.html) for writing to the rotating log files

To configure CleanroomLogger in this fashion, you could write:

```swift
// create 3 different types of formatters
let xcodeFormat = XcodeLogFormatter()
let aslFormat = ReadableLogFormatter()
let fileFormat = ParsableLogFormatter()

// create a configuration for logging to the Xcode console, but
// disable ASL logging so we can use a different formatter for it
let xcodeConfig = XcodeLogConfiguration(logToASL: false,
									   formatter: xcodeFormat)

// create a configuration containing an ASL log recorder
// using the aslFormat formatter. turn off stderr echoing
// so we don’t see duplicate messages in the Xcode console
let aslRecorder = ASLLogRecorder(formatter: aslFormat,
							  echoToStdErr: false)
let aslConfig = BasicLogConfiguration(recorders: [aslRecorder])

// create a configuration for a rotating log file directory
// that uses the fileFormat formatter -- logDir is a String
// holding the filesystem path to the log directory
let fileCfg = RotatingLogFileConfiguration(minimumSeverity: .Info,
												daysToKeep: 15,
											 directoryPath: logDir,
												formatters: [fileFormat])

// crash if the log directory doesn’t exist yet & can’t be created
try! fileCfg.createLogDirectory()

// enable logging using the 3 different LogRecorders
// that each use their own distinct LogFormatter
Log.enable(configuration: [xcodeConfig, aslConfig, fileCfg])
```


#### Customized Log Formatting

The [`LogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFormatter.html) protocol is consulted when attempting to convert a [`LogEntry`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html) into a string.

CleanroomLogger ships with several high-level `LogFormatter` implementations for specific purposes:

- [`XcodeLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogFormatter.html) — Used by the `XcodeLogConfiguration` by default.
- [`ParsableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ParsableLogFormatter.html) — Ideal for logs intended to be ingested for parsing by other processes.
- [`ReadableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ReadableLogFormatter.html) — Ideal for logs intended to be read by humans.

The `LogFormatter`s above are all subclasses of [`StandardLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/StandardLogFormatter.html), which provides a basic mechanism for customizing the behavior of formatting.

You can also assemble an entirely custom formatter quite easily using the [`FieldBasedLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/FieldBasedLogFormatter.html), which lets you mix and match [`Fields`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/FieldBasedLogFormatter/Field.html) to roll your own formatter.

Let’s say you just wanted the following fields in your log output, each separated by a tab character:

- UNIX timestamp
- Numeric severity level
- Log message

You could build such a formatter with the code:

```swift
let formatter = FieldBasedLogFormatter(fields: [.Timestamp(.UNIX),
                                                .Delimiter(.Tab),
                                                .Severity(.Numeric),
                                                .Delimiter(.Tab),
                                                .Payload])
```



### API documentation

For detailed information on using CleanroomLogger, [API documentation](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/index.html) is available.


#### XcodeColors Support

CleanroomLogger contains built-in support for [XcodeColors](https://github.com/robbiehanson/XcodeColors), a third-party Xcode plug-in that uses special escape sequences to colorize text output within the Xcode console.

When it is in use, XcodeColors sets the value of the environment variable `XcodeColors` to the string `YES`. And when configured with an `XcodeLogConfiguration`, CleanroomLogger will automatically enable log colorization if it detects XcodeColors is present. This will result in log messages being color-coded according to their `LogSeverity` in the Xcode console.

> If you have XcodeColors installed but would *not* like to enable CleanroomLogger support for it, pass `true` for `suppressColors` or `nil` for `colorizer` when instantiating your `XcodeLogConfiguration`.

The built-in color scheme—which you can override by supplying your own [`ColorTable`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/ColorTable.html)—emphasizes important information while seeking to make less important messages fade into the background when you’re not focused on them:

<img alt="XcodeColors sample output" src="https://raw.githubusercontent.com/emaloney/CleanroomLogger/master/Documentation/Images/XcodeColors-sample.png" width="565" height="98"/>

#### Enabling XcodeColors for iOS, tvOS & watchOS

When your code runs in a simulator or on an external device, it is actually running in an entirely separate operating system that *does not* inherit the environment variables that XcodeColors modifies when it is enabled.

XcodeColors *only* modifies the environment of the local Mac user running Xcode. Therefore, XcodeColors can only automatically enable support for Mac OS X code itself.

If your code is running on iOS, tvOS or watchOS, you will need to change your Xcode settings to pass the `XcodeColors` variable your code’s runtime environment. This can be done by editing any Build Schemes you want to use with XcodeColors.

To edit the current build scheme, press `⌘<` (*command*-*shift*-comma on a US English keyboard). In the editor that appears, select **Run** in the left-hand pane. Then, select the **Arguments** option at the top.

Ensure that the **Environment Variables** section is expanded below, and click the **+** button within that section.

This will allow you to add a new environment variable within the runtime environment. Enter `XcodeColors` for the name and `YES` for the value, as shown in this example:

<img alt="Enabling XcodeColors via an Xcode build scheme" src="https://raw.githubusercontent.com/emaloney/CleanroomLogger/master/Documentation/Images/XcodeColors-build-scheme.png" width="650" height="360"/>

When done, select the **Close** button. 

The next time you run your code, assuming both XcodeColors and CleanroomLogger are installed and configured correctly, you should see colorized log output within your Xcode console.

#### Troubleshooting XcodeColors

##### Colors are not showing up!

If the `XcodeColors` environment variable is set to `YES` but is being run in within a copy of Xcode where XcodeColors is not installed and loaded, CleanroomLogger will (incorrectly) assume that XcodeColors *is* installed and will dutifully output the escape sequences needed to drive message colorization.

Those escape sequences will appear in your output instead of color:

<img alt="Raw XcodeColors escape sequences" src="https://raw.githubusercontent.com/emaloney/CleanroomLogger/master/Documentation/Images/XcodeColors-escape-sequences.png" width="650" height="85"/>

If this happens, it means the XcodeColors plug-in is either not installed, or Xcode is not loading it upon launch.

If you see no color *and* no escape codes, it means CleanroomLogger did not detect an `XcodeColors` variable set to `YES` in its runtime environment.

##### It stopped working after I updated Xcode!

If you recently updated Xcode, and a previously-working installation of XcodeColors no longer works, your XcodeColors plug-in likely needs to be updated to work with the latest version of Xcode.

See the [documentation for XcodeColors](https://github.com/robbiehanson/XcodeColors/wiki/XcodeUpdates) for details on how to do this.


## Architectural Overview

CleanroomLogger is designed to do avoid doing formatting or logging work on the calling thread, making use of Grand Central Dispatch (GCD) queues for efficient processing.

In terms of threads of execution, each request to log *anything* can go through three main phases of processing:

1. On the calling thread:
  1. Caller attempts to issue a log request by calling a logging function (eg., `message()`, `trace()` or `value()`) of the appropriate `LogChannel` maintained by `Log`.
    - If there is no `LogChannel` for the given *severity* of the log message (because CleanroomLogger hasn’t yet been `enabled()` or it is not configured to log at that severity), Swift short-circuiting prevents further execution. This makes it possible to leave debug logging calls in place when shipping production code without affecting performance. 
  2. If a `LogChannel` does exist, it creates an immutable `LogEntry` struct to represent the *thing* being logged.
  3. The `LogEntry` is then passed to the `LogReceptacle` associated with the `LogChannel`. 
  4. Based on the severity of the `LogEntry`, the `LogReceptacle` selects one or more `LogConfiguration`s to use for recording the message. Among other things, these configurations determine whether further processing proceeds synchronously or asynchronously when passed to the underlying `LogReceptacle`’s GCD queue. (Synchronous processing is useful during debugging, but is not recommended for general production code.)

2. On the `LogReceptacle` queue:
  1. The `LogEntry` is passed through zero or more `LogFilter`s that are given a chance to prevent further processing of the `LogEntry`. If *any* filter indicates that `LogEntry` should not be recorded, processing stops.
  2. The `LogConfiguration` is used to determine which `LogRecorder`s (if any) will be used to record the `LogEntry`.
  3. For each `LogRecorder` instance specified by the configuration, the `LogEntry` is then dispatched to the GCD queue provided by the `LogRecorder`.

3. On each `LogRecorder` queue:
  1. The `LogEntry` is passed sequentially to each `LogFormatter` provided by the `LogRecorder`, giving the formatters a chance to create the formatted message for the `LogEntry`.
    - If no `LogFormatter` returns a string representation of `LogEntry`, further processing stops and nothing is recorded.
    - If any `LogFormatter` returns a non-`nil` value to represent the formatted message of the `LogEntry`, that string is then passed to the `LogRecorder` for final logging.

### Full Disclosure: A Note about Global State

If you’ve been reading the op-ed pages lately, you know that Global State is the enemy of civilization. You may also have noticed that `Log`’s static variables constitute global state.

Before you pick up your phone and demand that Thought Control activates its network of Twitter shamebots because a heretic has been detected, consider:

- In most cases, `Log` is used as an interface to two resources that are effectively singletons: the Apple System Log daemon of the device where the code will be running, and the `stderr` output stream of the running application. `Log` *maintains* global state because it *represents* global state.

- The state represented by `Log` is effectively immutable. The public interface is read-only, and the values are guaranteed to only ever be set once: at app launch, when `Log.enable()` is called from within the app delegate. The design of this gives full control to the application developer over the logging performed within the application; even third-party libraries using CleanroomLogger will use the logging configuration specified by the app developer.

- `Log` designed to be *convenient* to encourage the judicious use of logging. During debugging, you might want to quickly add some debug tracing to some already-existing code; you can simply add `Log.debug?.trace()` to the appropriate places without refactoring your codebase to pass around `LogChannel`s or `LogReceptacle`s everywhere. Given that every single function in your code is a candidate for logging, it’s impractical to use logging extensively *without* the convenience of `Log`.

- If you have a compelling reason to avoid using `Log`, but you still wish to use the functionality provided by CleanroomLogger, you can always construct and manage your own `LogChannel`s and `LogReceptacle`s directly. The only global state within the CleanroomLogger project is contained in `Log` itself. Note, however, that this should **only** be done by the app developer; **vendors of embedded code should only ever interact with CleanroomLogger through the public API provided by `Log`** to ensure that the app developer is always in control of logging.
 
Although there are many good reasons why global state is to be generally avoided and otherwise looked at skeptically, in this particular case, our use of global state is deliberate, well-isolated and not required to take advantage of the core functionality provided by CleanroomLogger.


## About

The Cleanroom Project began as an experiment to re-imagine Gilt’s iOS codebase in a legacy-free, Swift-based incarnation.

Since then, we’ve expanded the Cleanroom Project to include multi-platform support. Much of our codebase now supports tvOS in addition to iOS, and our lower-level code is usable on Mac OS X and watchOS as well.

Cleanroom Project code serves as the foundation of Gilt on TV, our tvOS app [featured by Apple during the launch of the new Apple TV](http://www.apple.com/apple-events/september-2015/). And as time goes on, we'll be replacing more and more of our existing Objective-C codebase with Cleanroom implementations.

In the meantime, we’ll be tracking the latest releases of Swift & Xcode, and [open-sourcing major portions of our codebase](https://github.com/gilt/Cleanroom#open-source-by-default) along the way.


### Contributing

CleanroomLogger is in active development, and we welcome your contributions.

If you’d like to contribute to this or any other Cleanroom Project repo, please read [the contribution guidelines](https://github.com/gilt/Cleanroom#contributing-to-the-cleanroom-project).


### Acknowledgements

[API documentation for CleanroomLogger](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/index.html) is generated using [Realm](http://realm.io)’s [jazzy](https://github.com/realm/jazzy/) project, maintained by [JP Simard](https://github.com/jpsim) and [Samuel E. Giddins](https://github.com/segiddins).

