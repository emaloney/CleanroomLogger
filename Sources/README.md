## Using CleanroomLogger

The main public API for CleanroomLogger is provided by [`Log`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html).

`Log` maintains five static read-only [`LogChannel`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html) properties that correspond to one of five *severity levels* indicating the importance of messages sent through that channel. When sending a message, you would select a severity appropriate for that message, and use the corresponding channel:

- [`Log.error`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5errorGSqVS_10LogChannel_) — The highest severity; something has gone wrong and a fatal error may be imminent
- [`Log.warning`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7warningGSqVS_10LogChannel_) — Something appears amiss and might bear looking into before a larger problem arises
- [`Log.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log4infoGSqVS_10LogChannel_) — Something notable happened, but it isn’t anything to worry about
- [`Log.debug`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5debugGSqVS_10LogChannel_) — Used for debugging and diagnostic information (not intended for use in production code)
- [`Log.verbose`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7verboseGSqVS_10LogChannel_) - The lowest severity; used for detailed or frequently occurring debugging and diagnostic information (not intended for use in production code)

Each of these `LogChannel`s provide three functions to record log messages:

- [`trace()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5traceFTSS8filePathSS8fileLineSi_T_) — This function records a log message with program execution trace information including the source code filename, line number and name of the calling function.
- [`message(String)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel7messageFTSS8functionSS8filePathSS8fileLineSi_T_) — This function records the log message passed to it.
- [`value(Any?)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5valueFTGSqP__8functionSS8filePathSS8fileLineSi_T_) — This function attempts to record a log message containing a string representation of the optional `Any` value passed to it. 

### Enabling logging

By default, logging is disabled, meaning that none of the `Log`’s channels have been populated. As a result, they have `nil` values and any attempts to perform logging will silently fail.

**In order to use CleanroomLogger, _you must explicitly enable logging_**, which is done by calling one of the `Log.enable()` functions.

Ideally, logging is enabled at the first possible point in the application’s launch cycle. Otherwise, critical log messages may be missed during launch because the logger wasn’t yet initialized.

The best place to put the call to `Log.enable()` is at the first line of your app delegate’s `init()`.

If you’d rather not do that for some reason, the next best place to put it is in the `application(_:willFinishLaunchingWithOptions:)` function of your app delegate. You’ll notice that we’re specifically recommending the `will` function, not the typical `did`, because the former is called earlier in the application’s launch cycle.

> **Note:** During the running lifetime of an application process, only the *first* call to `Log.enable()` function will have any effect. All subsequent calls are ignored silently. You can also prevent CleanroomLogger from being enabled altogether by calling `Log.neverEnable()`.

### Logging examples

To record items in the log, simply select the appropriate channel and call the appropriate function.

Here are a few examples:

#### Logging an arbitrary text message

Let’s say your application just finished launching. This is a significant event, but it isn’t an error. You also might want to see this information in production app logs. Therefore, you decide the appropriate `LogSeverity` is [`.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html#/s:FO15CleanroomLogger11LogSeverity4infoFMS0_S0_) and you select the corresponding `LogChannel`, which is [`Log.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log4infoGSqVS_10LogChannel_). Then, to log a message, just call the channel’s [`message()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel7messageFTSS8functionSS8filePathSS8fileLineSi_T_) function:

```swift
Log.info?.message("The application has finished launching.")
```

#### Logging a trace message

If you’re working on some code and you’re curious about the order of execution, you can sprinkle some [`trace()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5traceFTSS8filePathSS8fileLineSi_T_) calls around.

This function outputs the filename, line number and name of the calling function.

For example, if you put the following code on line 364 of a file called ModularTable.swift in a function with the signature `tableView(_:cellForRowAt:)`:

```swift
Log.debug?.trace()
```

Assuming logging is enabled for the `.debug` severity, the following message would be logged when that line gets executed:

```
ModularTable.swift:364 — tableView(_:cellForRowAt:)
```

#### Logging an arbitrary value

The [`value()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5valueFTGSqP__8functionSS8filePathSS8fileLineSi_T_) function can be used for outputting information about a specific value. The function takes an argument of type `Any?` and is intended to accept any valid runtime value.

For example, you might want to output the `IndexPath` value passed to your `UITableViewDataSource`’s `tableView(_:cellForRowAt:)` function:

```swift
Log.verbose?.value(indexPath)
```

This would result in output looking like:

```
= IndexPath: [0, 2]
```

The function also handles optionals:

```swift
var str: String?
Log.verbose?.value(str)
```

The output for this would be:

```
= nil
```

### CleanroomLogger In Depth

This section delves into the particulars of configuring and customizing CleanroomLogger to suit your needs.

#### Configuring CleanroomLogger

CleanroomLogger is configured when one of the `Log.enable()` function variants is called. Configuration can occur at most once within the lifetime of the running process. And once set, the configuration can’t be changed; it’s immutable.

The [`LogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html) protocol represents the mechanism by which CleanroomLogger can be configured. `LogConfiguration`s allow encapsulating related settings and behavior within a single entity, and CleanroomLogger can be configured with multiple `LogConfiguration` instances to allow combining behaviors.

Each `LogConfiguration` specifies:

- The [`minimumSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration15minimumSeverityOS_11LogSeverity), a [`LogSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Enums/LogSeverity.html) value that determines which log entries get recorded. Any [`LogEntry`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html) with a [`severity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html#/s:vV15CleanroomLogger8LogEntry8severityOS_11LogSeverity) less than the configuration’s `mimimumSeverity` will not be passed along to any [`LogRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogRecorder.html)s specified by that configuration.
- An array of [`LogFilter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFilter.html)s. Each `LogFilter` is given a chance to cause a given log entry to be ignored.
- A [`synchronousMode`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration15synchronousModeSb) property, which determines whether synchronous logging should be used when processing log entries for the given configuration. *This feature is intended to be used during debugging and is not recommended for production code.*
- Zero or more contained `LogConfiguration`s. For organizational purposes, each `LogConfiguration` can in turn contain additional `LogConfiguration`s. The hierarchy is not meaningful, however, and is flattened at configuration time.
- An array of [`LogRecorder`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogRecorder.html)s that will be used to write log entries to the underlying logging facility. If a configuration has no `LogRecorder`s, it is assumed to be a container of other `LogConfiguration`s only, and is ignored when the configuration hierarchy is flattened.

When CleanroomLogger receives a request to log something, zero or more `LogConfiguration`s are selected to handle the request:

1. The `severity` of the incoming [`LogEntry`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html) is compared against the `minimumSeverity` of each `LogConfiguration`. Any `LogConfiguration` whose `minimumSeverity` is equal to or less than the `severity` of the `LogEntry` is selected for further consideration.
2. The `LogEntry` is then passed sequentially to the [`shouldRecord(entry:)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFilter.html#/s:FP15CleanroomLogger9LogFilter12shouldRecordFT5entryVS_8LogEntry_Sb) function of each of the `LogConfiguration`’s `filters`. If any `LogFilter` returns `false`, the associated configuration will *not* be selected to record that log entry.

##### XcodeLogConfiguration

Ideally suited for live viewing during development, the [`XcodeLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogConfiguration.html) examines the runtime environment to optimize CleanroomLogger for use within Xcode.

`XcodeLogConfiguration` takes into account:

- Whether the new Unified Logging System (also known as “OSLog”) is available; it is only present as of iOS 10.0, macOS 10.12, tvOS 10.0, and watchOS 3.0. By default, logging falls back to `stdout` and `stderr` if Unified Logging is unavailable.

- The value of the `OS_ACTIVITY_MODE` environment variable; when it is set to “`disable`”, attempts to log via OSLog are silently ignored. In such cases, log output is echoed to `stdout` and `stderr` to ensure that messages are visible in Xcode.

- The `severity` of the message. For UNIX-friendly behavior, `.verbose`, `.debug` and `.info` messages are directed to the `stdout` stream of the running process, while `.warning` and `.error` messages are sent to `stderr`. 

When using the Unified Logging System, messages in the Xcode console appear prefixed with an informational header that looks like:

```
2017-01-04 22:56:47.448224 Gilt[5031:89847] [CleanroomLogger]	
2017-01-04 22:56:47.448718 Gilt[5031:89847] [CleanroomLogger]	
2017-01-04 22:56:47.449487 Gilt[5031:89847] [CleanroomLogger]	
2017-01-04 22:56:47.450127 Gilt[5031:89847] [CleanroomLogger]	
2017-01-04 22:56:47.450722 Gilt[5031:89847] [CleanroomLogger]	
```

This header is not added by CleanroomLogger; it is added as a result of using OSLog within Xcode. It shows the timestamp of the log entry, followed by the process name, the process ID, the calling thread ID, and the logging system name.

To ensure consistent output across platforms, the `XcodeLogConfiguration` will mimic this header even when logging to `stdout` and `stderr`. You can disable this behavior by passing `false` as the `mimicOSLogOutput` argument. When disabled, a more concise header is used, showing just the timestamp and the calling thread ID:

```
2017-01-04 23:46:17.225 -05:00 | 00071095
2017-01-04 23:46:17.227 -05:00 | 00071095
2017-01-04 23:46:17.227 -05:00 | 000716CA
2017-01-04 23:46:17.228 -05:00 | 000716CA
2017-01-04 23:46:17.258 -05:00 | 00071095
```

To make it easier to quickly identify important log messages at runtime, the `XcodeLogConfiguration` makes use of the [`XcodeLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogFormatter.html), which embeds a color-coded representation of each message’s severity:

```
◽️ Verbose messages are tagged with a small gray square — easy to ignore
◾️ Debug messages have a black square; easier to spot, but still de-emphasized
🔷 Info messages add a splash of color in the form of a blue diamond
🔶 Warnings are highlighted with a fire-orange diamond
❌ Error messages stand out with a big red X — hard to miss!
```

The simplest way to enable CleanroomLogger using the `XcodeLogConfiguration` is by calling:

```swift
Log.enable()
```

Thanks to the magic of default parameter values, this is equivalent to the following [`Log.enable()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZFV15CleanroomLogger3Log6enableFT15minimumSeverityOS_11LogSeverity9debugModeSb16verboseDebugModeSb14stdStreamsModeOCS_23ConsoleLogConfiguration19StandardStreamsMode16mimicOSLogOutputSb12showCallSiteSb7filtersGSaPS_9LogFilter___T_) call:

```swift
Log.enable(minimumSeverity: .info,
                 debugMode: false,
          verboseDebugMode: false,
            stdStreamsMode: .useAsFallback,
          mimicOSLogOutput: true,
              showCallSite: true,
                   filters: [])
```

This configures CleanroomLogger using an `XcodeLogConfiguration` with [default settings](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogConfiguration.html#/s:FC15CleanroomLogger21XcodeLogConfigurationcFT15minimumSeverityOS_11LogSeverity9debugModeSb16verboseDebugModeSb14stdStreamsModeOCS_23ConsoleLogConfiguration19StandardStreamsMode16mimicOSLogOutputSb12showCallSiteSb7filtersGSaPS_9LogFilter___S0_).

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
let rotatingConf = RotatingLogFileConfiguration(minimumSeverity: .info,
                                                     daysToKeep: 7,
                                                  directoryPath: logDir)

Log.enable(configuration: rotatingConf)
```

The code above would record any log entry with a severity of `.info` or higher in a file that would be kept for at least 7 days before being pruned. This particular configuration uses the [`ReadableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ReadableLogFormatter.html) to format log entries.

The `RotatingLogFileConfiguration` can also be used to specify `synchronousMode`, a set of `LogFilter`s to apply, and one or more custom `LogFormatter`s.

##### Multiple Configurations

CleanroomLogger also supports multiple configurations, allowing different logging behaviors to be in use simultaneously.

Whenever a message is logged, every [`LogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html) is consulted separately and given a chance to process the message. By supplying a [`minimumSeverity`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration15minimumSeverityOS_11LogSeverity) and unique set of [`LogFilter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration7filtersGSaPS_9LogFilter__)s, each configuration can specify its own logic for screening out unwanted messages. Surviving messages are then passed to the configuration’s `LogFormatter`s, each in turn, until one returns a non-`nil` string. That string—the formatted log message—is ultimately passed to one or more `LogRecorder`s for writing to some underlying logging facility.

> Note that each configuration is a self-contained, stand-alone entity. None of the settings, behaviors or actions of a given `LogConfiguration` will affect any other.

For an example of how this works, imagine adding a debug mode `XcodeLogConfiguration` to the `rotatingConf` declared above. You could do this by writing:

```swift
Log.enable(configuration: [XcodeLogConfiguration(debugMode: true), rotatingConf])
```

In this example, both the [`XcodeLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogConfiguration.html) and the [`RotatingLogFileConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/RotatingLogFileConfiguration.html) will be consulted as each logging call occurs. Because the `XcodeLogConfiguration` is declared with `debugMode: true`, it will operate in `synchronousMode` while `rotatingConf` will operate asynchronously.

Further, the `XcodeLogConfiguration` will result in messages being logged via the Unified Logging System (if available) and/or the running process’s `stdout` and `stderr` streams. The `RotatingLogFileConfiguration`, on the other hand, results in messages being written to a file.

Finally, each configuration results in a different message format being used.

##### Implementing Your Own Configuration

Although you can provide your own implementation of the `LogConfiguration` protocol, it may be simpler to create a [`BasicLogConfiguration`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/BasicLogConfiguration.html) instance and pass the relevant parameters to [the initializer](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/BasicLogConfiguration.html#/s:FC15CleanroomLogger21BasicLogConfigurationcFT15minimumSeverityOS_11LogSeverity7filtersGSaPS_9LogFilter__9recordersGSaPS_11LogRecorder__15synchronousModeSb14configurationsGSqGSaPS_16LogConfiguration____S0_).

You can also subclass `BasicLogConfiguration` if you’d like to encapsulate your configuration further.

##### A Complicated Example

Let’s say you want configure CleanroomLogger to:

1. Print `.verbose`, `.debug` and `.info` messages to `stdout` while directing `.warning` and `.error` messages to `stderr`
2. Mirror all messages to OSLog, if it is available on the runtime platform
3. Create a rotating log file directory at the path `/tmp/CleanroomLogger` to store `.info`, `.warning` and `.error` messages for up to 15 days

Further, you want the log entries for each to be formatted differently:

1. An [`XcodeLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogFormatter.html) for `stdout` and `stderr`
2. A [`ReadableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ReadableLogFormatter.html) for OSLog
3. A [`ParsableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ParsableLogFormatter.html) for the log files

To configure CleanroomLogger to do all this, you could write:

```swift
var configs = [LogConfiguration]()

// create a recorder for logging to stdout & stderr
// and add a configuration that references it
let stderr = StandardStreamsLogRecorder(formatters: [XcodeLogFormatter()])
configs.append(BasicLogConfiguration(recorders: [stderr]))

// create a recorder for logging via OSLog (if possible)
// and add a configuration that references it
if let osLog = OSLogRecorder(formatters: [ReadableLogFormatter()]) {
	// the OSLogRecorder initializer will fail if running on 
	// a platform that doesn’t support the os_log() function
	configs.append(BasicLogConfiguration(recorders: [osLog]))
}

// create a configuration for a 15-day rotating log directory
let fileCfg = RotatingLogFileConfiguration(minimumSeverity: .info,
												daysToKeep: 15,
											 directoryPath: "/tmp/CleanroomLogger",
												formatters: [ParsableLogFormatter()])

// crash if the log directory doesn’t exist yet & can’t be created
try! fileCfg.createLogDirectory()

configs.append(fileCfg)

// enable logging using the LogRecorders created above
Log.enable(configuration: configs)
```


#### Customized Log Formatting

The [`LogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/LogFormatter.html) protocol is consulted when attempting to convert a [`LogEntry`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogEntry.html) into a string.

CleanroomLogger ships with several high-level `LogFormatter` implementations for specific purposes:

- [`XcodeLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/XcodeLogFormatter.html) — Optimized for live viewing of a log stream in Xcode. Used by the `XcodeLogConfiguration` by default.
- [`ParsableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ParsableLogFormatter.html) — Ideal for logs intended to be ingested for parsing by other processes.
- [`ReadableLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/ReadableLogFormatter.html) — Ideal for logs intended to be read by humans.

The latter two `LogFormatter`s are both subclasses of [`StandardLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/StandardLogFormatter.html), which provides a basic mechanism for customizing the behavior of formatting.

You can also assemble an entirely custom formatter quite easily using the [`FieldBasedLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/FieldBasedLogFormatter.html), which lets you mix and match [`Field`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Classes/FieldBasedLogFormatter/Field.html)s to roll your own formatter.
