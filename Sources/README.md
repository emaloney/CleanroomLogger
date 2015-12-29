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


### XcodeColors Support

CleanroomLogger contains built-in support for [XcodeColors](https://github.com/robbiehanson/XcodeColors), a third-party Xcode plug-in that allows using special escape sequences to colorize text output within the Xcode console.

When XcodeColors is installed and configured, CleanroomLogger will colorize text according to the `LogSeverity` of the message.

The default color scheme—which you can override by supplying your own [`ColorTable`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Protocols/ColorTable.html)—emphasizes important information while seeking to make less important messages fade into the background when you're not focused on them:

<img alt="XcodeColors sample output" src="https://raw.githubusercontent.com/emaloney/CleanroomLogger/master/Documentation/Images/XcodeColors-sample.png" width="565" height="98"/>

When XcodeColors is installed, it sets the value of the environment variable `XcodeColors` to the string `YES`. CleanroomLogger checks this environment variable to determine whether XcodeColors escape sequences should be used. When the value is `YES`, CleanroomLogger uses XcodeColors. 

> **Note:** This behavior is implemented by the [`DefaultLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/DefaultLogFormatter.html). If you use a custom log formatter, you can use an [`XcodeColorsColorizer`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/XcodeColorsColorizer.html) instance to manually apply XcodeColors escape sequences to your log output.

#### Enabling XcodeColors for iOS, tvOS & watchOS

When your code runs in a simulator or on an external device, it is actually running in an entirely separate operating system that *does not* inherit the environment variables that XcodeColors modifies when it is enabled.

XcodeColors *only* modifies the environment of the local Mac user running Xcode. Therefore, XcodeColors can only automatically enable support for Mac OS X code itself.

If your code is running on iOS, tvOS or watchOS, you will need to change your Xcode settings to pass the `XcodeColors` variable your code's runtime environment. This can be done by editing any Build Schemes you want to use with XcodeColors.

To edit the current build scheme, press `⌘<` (*command*-*shift*-comma on a US English keyboard). In the editor that appears, select **Run** in the left-hand pane. Then, select the **Arguments** option at the top.

Ensure that the **Environment Variables** section is expanded below, and click the **+** button within that section.

This will allow you to add a new environment variable within the runtime environment. Enter `XcodeColors` for the name and `YES` for the value, as shown in this example:

<img alt="Enabling XcodeColors via an Xcode build scheme" src="https://raw.githubusercontent.com/emaloney/CleanroomLogger/master/Documentation/Images/XcodeColors-build-scheme.png" width="650" height="360"/>

When done, select the **Close** button. 

The next time you run your code, assuming both XcodeColors and CleanroomLogger are installed and configured correctly, you should see colorized log output within your Xcode console.

#### Troubleshooting XcodeColors

If the `XcodeColors` environment variable is set to `YES` but is being run in within a copy of Xcode where XcodeColors is not installed and loaded, CleanroomLogger will (incorrectly) assume that XcodeColors *is* installed and will dutifully output the escape sequences needed to drive message colorization.

Those escape sequences will appear in your output instead of color:

<img alt="Raw XcodeColors escape sequences" src="https://raw.githubusercontent.com/emaloney/CleanroomLogger/master/Documentation/Images/XcodeColors-escape-sequences.png" width="650" height="85"/>

If this happens, it means the XcodeColors plug-in is either not installed, or Xcode is not loading it upon launch.

If you see no color *and* no escape codes, it means CleanroomLogger did not detect an `XcodeColors` variable set to `YES` in its runtime environment.
