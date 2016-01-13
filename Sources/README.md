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

It is the responsibility of the *application developer* to enable logging, which is done by calling the appropriate `Log.enable()` function.

> The reason we specifically say that the application developer is responsible for enabling logging is to give the developer the power to control the use of logging process-wide. As with any code that executes, there’s an expense to logging, and the application developer should get to decide how to handle the tradeoff between the utility of collecting logs and the expense of collecting them at a given level of detail.
>
> CleanroomLogger is built to be used from within frameworks, shared libraries, Cocoapods, etc., as well as at the application level. However, any code designed to be embedded in other applications **must** interact with CleanroomLogger via the `Log` API **only**. Also, embedded code **must never** call `Log.enable()`, because by doing so, control is taken away from the application developer.
>
> *The general rule is, if you didn’t write the `UIApplicationDelegate` for the app in which the code will execute, don’t ever call `Log.enable()`.*

Ideally, logging is enabled at the first possible point in the application’s launch cycle. Otherwise, critical log messages may be missed during launch because the logger wasn’t yet initialized.

The best place to put the call to `Log.enable()` is at the first line of your app delegate’s `init()`.

If you’d rather not do that for some reason, the next best place to put it is in the `application(_:willFinishLaunchingWithOptions:)` function of your app delegate. You’ll notice that we’re specifically recommending the `will` function, not the typical `did`, because the former is called earlier in the application’s launch cycle.

> **Note:** During the running lifetime of an application process, only the *first* call to `Log.enable()` function will have any effect. All subsequent calls are ignored silently.

### Logging examples

To record items in the log, simply select the appropriate channel and call the appropriate function.

Here are a few examples:

#### Logging an arbitrary text message

Let’s say your application just finished launching. This is a significant event, but it isn’t an error. You also might want to see this information in production app logs. Therefore, you decide the appropriate `LogSeverity` is `.Info` and you select the corresponding `LogChannel`, which is `Log.info`:

```swift
Log.info?.message("The application has finished launching.")
```

#### Logging a trace message

If you’re working on some code and you’re curious about the order of execution, you can sprinkle some `trace()` calls around.

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

The `LogConfiguration` protocol represents the mechanism by which CleanroomLogger can be configured. `LogConfiguration`s allow encapsulating related settings and behavior within a single entity, and CleanroomLogger can be configured with multiple `LogConfiguration` instances to allow combining behaviors.

Each `LogConfiguration` specifies:

- The `minimumSeverity`, a `LogSeverity` value that determines which log entries get recorded. Log entries with `severity` values less than the `mimimumSeverity` will not be passed along to any `LogRecorder`s associated with the configuration.
- An array of `LogFilter`s. Each `LogFilter` is given a chance to cause a given log entry to be ignored.
- A `synchronousMode` property, which determines whether synchronous logging should be used when processing log entries for the given configuration. *This feature is intended to be used during debugging and is not recommended for production code.*
- Zero or more contained `LogConfiguration`s. For organizational purposes, each `LogConfiguration` can in turn contain additional `LogConfiguration`s. The hierarchy is not meaningful, however, and is flattened at configuration time.
- An array of `LogRecorder`s that will be used to write log entries to the underlying logging facility. If a configuration has no `LogRecorder`s, it is assumed to be a container of other `LogConfiguration`s only, and is ignored when the configuration hierarchy is flattened.

When CleanroomLogger receives a request to log something, zero or more `LogConfiguration`s are selected to handle the request:

1. The `severity` of the incoming `LogEntry` is compared against the `minimumSeverity` of each `LogConfiguration`. Any `LogConfiguration` whose `minimumSeverity` is equal to or less than the `severity` of the `LogEntry` is selected for further consideration.
2. The `LogEntry` is then passed sequentially to the `shouldRecordLogEntry()` function of each of the `LogConfiguration`’s `filters`. If any `LogFilter` returns `false`, the associated configuration will *not* be selected to record that log entry.

##### XcodeLogConfiguration

The `XcodeLogConfiguration` is ideally suited for use during development and in production.

By default, this configuration writes log entries to the running process’s `stdout` stream (which appears within the Xcode console pane) as well as to the Apple System Log (ASL) facility.

The `XcodeLogConfiguration` also attempts to detect whether XcodeColors is installed and enabled. If it is, the `XcodeLogConfiguration` will configure CleanroomLogger to [use XcodeColors for color-coding log entries](#xcodecolors-support) by severity.

The simplest way to enable CleanroomLogger using the `XcodeLogConfiguration` is by calling:

```swift
Log.enable()
```

Thanks to the magic of default parameter values, this is equivalent to the following [`Log.enable()`](https://rawgit.com/emaloney/CleanroomLogger/refactoring/Documentation/API/Protocols/LogConfiguration.html#/s:vP15CleanroomLogger16LogConfiguration7filtersGSaPS_9LogFilter__) call:

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

This configures CleanroomLogger using an `XcodeLogConfiguration` with default settings.

> **Note:** If either `debugMode` or `verboseDebugMode` is `true`, the `XcodeLogConfiguration` will be used in `synchronousMode`, which is not recommended for production code.

The call above is also equivalent to:

```swift
Log.enable(configuration: XcodeLogConfiguration())
```

##### RotatingLogFileConfiguration

The `RotatingLogFileConfiguration` can be used to maintain a directory of log files that are rotated daily.

> **Warning:** The `RotatingLogFileRecorder` created by the `RotatingLogFileConfiguration` assumes full control over the log directory.  Any file not recognized as an active log file will be deleted during the automatic pruning process, which may occur at any time. *This means if you’re not careful about the `directoryPath` you pass, you may lose valuable data!*

At a minimum, the `RotatingLogFileConfiguration` requires you to specify the `minimumSeverity` for logging, the number of days to keep log files, and a directory in which to store those files:

```swift
// logDir is a String holding the filesystem path to the log directory
let rotatingConf = RotatingLogFileConfiguration(minimumSeverity: .Info,
                                                     daysToKeep: 7,
                                                  directoryPath: logDir)

Log.enable(configuration: rotatingConf)
```

The code above would record any log entry with a severity of `.Info` or higher in a file that would be kept for at least 7 days before being pruned. This particular configuration uses the `ReadableLogFormatter` to format log entries.

The `RotatingLogFileConfiguration` can also be used to specify `synchronousMode`, a set of `LogFilter`s to apply, and one or more custom `LogFormatter`s.

##### Combining Configurations

CleanroomLogger also supports passing multiple configurations. This allows you to combine the behavior of different configurations.

For example, to add a debug mode `XcodeLogConfiguration` to the `rotatingConf` declared above, you could write:

```swift
Log.enable(configuration: [XcodeLogConfiguration(debugMode: true), rotatingConf])
```

In this example, both the `XcodeLogConfiguration` and the `RotatingLogFileConfiguration` will be consulted as logging occurs. Because the `XcodeLogConfiguration` is declared with `debugMode: true`, it will operate in `synchronousMode` while `rotatingConf` will operate asynchronously.

##### Implementing Your Own Configuration

Although you can provide your own implementation of the `LogConfiguration` protocol, it may be simpler to create a `BasicLogConfiguration` instance and pass the relevant parameters to the initializer.

You can also subclass `BasicLogConfiguration` if you’d like to encapsulate your configuration further.

##### A Complicated Example

Let’s say you want CleanroomLogger to write to `stdout`, the Apple System Log (ASL) facility, and a set of rotating log files, and you want the log entries for each to be formatted differently:

1. An `XcodeLogFormatter` for `stdout` but not the ASL
2. A `ReadableLogFormatter` for the ASL
3. A `ParsableLogFormatter` for writing to the rotating log files

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

The `LogFormatter` protocol is consulted when attempting to convert a `LogEntry` into a string.

CleanroomLogger ships with several high-level `LogFormatter` implementations for specific purposes:

- `XcodeLogFormatter` — Used by the `XcodeLogConfiguration` by default.
- `ParsableLogFormatter` — Ideal for logs intended to be ingested for parsing by other processes.
- `ReadableLogFormatter` — Ideal for logs intended to be read by humans.

The `LogFormatter`s above are all subclasses of `StandardLogFormatter`, which provides a basic mechanism for customizing the behavior of formatting.

You can also assemble an entirely custom formatter quite easily using the `FieldBasedLogFormatter`, which lets you mix and match `Fields` to roll your own formatter.

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
