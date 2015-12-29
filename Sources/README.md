## Using CleanroomLogger

The main public API for CleanroomLogger is provided by [`Log`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html).

`Log` maintains five static read-only [`LogChannel`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html) properties that correspond to one of five *severity levels* indicating the importance of messages sent through that channel. When sending a message, you would select a severity appropriate for that message, and use the corresponding channel:

- [`Log.error`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5errorGSqVS_10LogChannel_) — The highest severity; something has gone wrong and a fatal error may be imminent
- [`Log.warning`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7warningGSqVS_10LogChannel_) — Something appears amiss and might bear looking into before a larger problem arises
- [`Log.info`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log4infoGSqVS_10LogChannel_) — Something notable happened, but it isn't anything to worry about
- [`Log.debug`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log5debugGSqVS_10LogChannel_) — Used for debugging and diagnostic information (not intended for use in production code)
- [`Log.verbose`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/Log.html#/s:ZvV15CleanroomLogger3Log7verboseGSqVS_10LogChannel_) - The lowest severity; used for detailed or frequently occurring debugging and diagnostic information (not intended for use in production code)

Each of these `LogChannel`s provide three functions to record log messages:

- [`trace()`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5traceFS0_FT8functionSS8filePathSS8fileLineSi_T_) — This function records a log message with program executing trace information including the filename, line number and name of the calling function.
- [`message(String)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel7messageFS0_FTSS8functionSS8filePathSS8fileLineSi_T_) — This function records the log message passed to it.
- [`value(Any?)`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/LogChannel.html#/s:FV15CleanroomLogger10LogChannel5valueFS0_FTGSqP__8functionSS8filePathSS8fileLineSi_T_) — This function attempts to record a log message containing a string representation of the optional `Any` value passed to it. 

### Enabling logging

By default, logging is disabled, meaning that none of the `Log`'s channels have been populated. As a result, they have `nil` values and any attempts to perform logging will silently fail.

It is the responsibility of the *application developer* to enable logging, which is done by calling the appropriate `Log.enable()` function.

> The reason we specifically say that the application developer is responsible for enabling logging is to give the developer the power to control the use of logging process-wide. As with any code that executes, there's an expense to logging, and the application developer should get to decide how to handle the tradeoff between the utility of collecting logs and the expense of collecting them at a given level of detail.
>
> CleanroomLogger is built to be used from within frameworks, shared libraries, Cocoapods, etc., as well as at the application level. However, any code designed to be embedded in other applications **must** interact with CleanroomLogger via the `Log` API **only**. Also, embedded code **must never** call `Log.enable()`, because by doing so, control is taken away from the application developer.
>
> *The general rule is, if you didn't write the `UIApplicationDelegate` for the app in which the code will execute, don't ever call `Log.enable()`.*

Ideally, logging is enabled at the first possible point in the application's launch cycle. Otherwise, critical log messages may be missed during launch because the logger wasn't yet initialized.

The best place to put the call to `Log.enable()` is at the first line of your app delegate's `init()`.

If you'd rather not do that for some reason, the next best place to put it is in the `application(_:willFinishLaunchingWithOptions:)` function of your app delegate. You'll notice that we're specifically recommending the `will` function, not the typical `did`, because the former is called earlier in the application's launch cycle.

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
