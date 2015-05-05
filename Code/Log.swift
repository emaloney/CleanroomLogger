//
//  Log.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/18/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
`Log` is the primary public API for CleanroomLogger.

If you wish to send a message to the log, you do so by calling the appropriae
function provided by the appropriate `LogChannel` given the importance of your
message.

There are five levels of severity at which log messages can be recorded. Each
level is represented by a read-only static variable maintained by the `Log`:

- `Log.error` — The highest severity; something has gone wrong and a fatal error
may be imminent

- `Log.warning` — Something appears amiss and might bear looking into before a
larger problem arises

- `Log.info` — Something notable happened, but it isn't anything to worry about

- `Log.debug` — Used for debugging and diagnostic information

- `Log.verbose` - The lowest severity; used for detailed or frequently occurring
debugging and diagnostic information

Each `LogChannel` can be used in one of three ways:

- The `trace()` function records a short log message detailing the source
file, source line, and function name of the caller. It is intended to be called
with no arguments, as follows:

```
Log.debug?.trace()
```

- The `message()` function records a message specified by the caller:

```
Log.info?.message("The application has finished launching.")
```

`message()` is intended to be called with a single parameter, the message 
string, as shown above. Unlike `NSLog()`, no `printf`-like functionality
is provided; instead, use Swift string interpolation to construct parameterized
messages.

- Finally, the `value()` function records a string representation of an 
arbitrary `Any` value:

```
Log.verbose?.value(delegate)
```

The `value()` function is intended to be called with a single parameter, of
type `Any?`.

The underlying logging implementation is responsible for converting this value
into a string representation.

Note that some implementations may not be able to convert certain values into
strings; in those cases, log requests may be silently ignored.

### Enabling logging

By default, logging is disabled, meaning that none of the `Log`'s *log channels*
have been populated. As a result, attempts to perform any logging will silently
fail.

It is the responsibility of the *application developer* to enable logging, which
is done by calling the appropriate `Log.enable()` function.

> The reason we specifically say the application developer is responsible
for enabling logging is to give the developer the power to control the use
of logging process-wide. As with any code that executes, there's an expense
to logging, and the application developer should get to make that choice.
>
> CleanroomLogger is designed to be used from within frameworks, shared
libraries, Cocoapods, etc., as well as at the application level. However, code
such as this—any code designed to be embedded in other applications—**must not 
ever** call `Log.enable()`, because by doing so, you will be taking control away
from the application developer.
>
> The general rule is, if you didn't write the `UIApplicationDelegate` for
the app in which the code will execute, don't ever call `Log.enable()`.

Ideally, logging is enabled at the first possible point in the application's
launch cycle. Otherwise, critical log messages may be missed during launch
because the logger wasn't yet initialized.

The best place to put the call to `Log.enable()` is at the first line of your
app delegate's `init()`.

If you'd rather not do that for some reason, the next best place to put it is in
the `application(_: willFinishLaunchingWithOptions:)` function within your app
delegate. Note that we're recommending the `will` function, not the typical 
`did`; this is because the former is called earlier in the launch cycle.

**Note:** During the running lifetime of an application process, only the
*first* call to `Log.enable()` function will have any effect. All subsequent
calls are ignored silently.

### Global State

If you've been reading the op-ed pages lately, you know that Global State is
the enemy of civilization. You may also have noticed that the static variables
of the `Log` struct constitute global state.

Before you pick up your phone to alert Thought Control that a heretic has been
detected and the network of Twitter shamebots should prepare to activate, 
consider:

- In most cases, `Log` is used as an interface to two resources that are 
effectively singletons: the Apple System Log daemon of the device where the
code will be running, and the `stderr` output stream of the running application.
`Log` *maintains* global state because it *represents* global state.

- The state represented by `Log` is effectively immutable. The public interface
is read-only, and the values are guaranteed to only ever be set once: at app
launch, when `Log.enable()` is called from within the app delegate. The design 
of this gives full control to the application developer over the logging 
performed within the application; even third-party libraries using 
CleanroomLogger will use the logging configuration specified by the app
developer.

- `Log` designed to be *convenient* to encourage the judicious use of logging.
During debugging, you might want to quickly add some debug tracing to some
already-existing code; you can simply add `Log.debug?.trace()` to the
appropriate places without refactoring your codebase to pass around
`LogChannel`s or `LogReceptacle`s everywhere. Given that literally
every single function in your code is a candidate for using logging, it's
impractical to use logging extensively *without* the convenience of `Log`.

- If you have a compelling reason to avoid using `Log`, but you still wish
to use the functionality provided by CleanroomLogger, you can always
construct and manage your own `LogChannel`s and `LogReceptacle`s directly.
The only global state within the CleanroomLogger project is contained in `Log`
itself.

Although there are many good reasons why global state is to be generally
avoided and otherwise looked at skeptically, in this particular case, our use
of global state is deliberate, well-isolated and not required to take advantage
of the functionality provided by CleanroomLogger.
*/
public struct Log
{
    /** The `LogChannel` that can be used to perform logging at the `.Error`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Error` or greater. */
    public static var error: LogChannel? { return _error }

    /** The `LogChannel` that can be used to perform logging at the `.Warning`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Warning` or greater. */
    public static var warning: LogChannel? { return _warning }

    /** The `LogChannel` that can be used to perform logging at the `.Info`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Info` or greater. */
    public static var info: LogChannel? { return _info }

    /** The `LogChannel` that can be used to perform logging at the `.Debug`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Debug` or greater. */
    public static var debug: LogChannel? { return _debug }

    /** The `LogChannel` that can be used to perform logging at the `.Verbose`
    log severity level. Will be `nil` if the `Log` has not been enabled with
    a minimum severity of `.Verbose` or greater. */
    public static var verbose: LogChannel? { return _verbose }

    /**
    Enables logging with the specified minimum `LogSeverity` using the
    `DefaultLogConfiguration`.
    
    This variant logs to the Apple System Log and to the `stderr` output
    stream of the application process. In Xcode, log messages will appear in
    the console.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted. Attempts to log messages less severe than
                `minimumSeverity` will be silently ignored.
    
    :param:     synchronousMode Determines whether synchronous mode logging
                will be used. **Use of synchronous mode is not recommended in
                production code**; it is provided for use during debugging, to
                help ensure that messages send prior to hitting a breakpoint
                will appear in the console when the breakpoint is hit.
    */
    public static func enable(minimumSeverity: LogSeverity = .Info, synchronousMode: Bool = false)
    {
        let config = DefaultLogConfiguration(minimumSeverity: minimumSeverity, synchronousMode: synchronousMode)
        enable(config)
    }

    /**
    Enables logging using the specified `LogConfiguration`.

    :param:     configuration The `LogConfiguration` to use for controlling
                the behavior of logging.
    */
    public static func enable(configuration: LogConfiguration)
    {
        enable([configuration], minimumSeverity: configuration.minimumSeverity)
    }

    /**
    Enables logging using the specified list of `LogConfiguration`s.

    :param:     configuration The list of `LogConfiguration`s to use for controlling
                the behavior of logging.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted. Attempts to log messages less severe than
                `minimumSeverity` will be silently ignored.
    */
    public static func enable(configuration: [LogConfiguration], minimumSeverity: LogSeverity = .Info)
    {
        let recept = LogReceptacle(configuration: configuration)
        enable(recept, minimumSeverity: minimumSeverity)
    }

    /**
    Enables logging using the specified `LogReceptacle`.
    
    Individual `LogChannel`s for `error`, `warning`, `info`, `debug`, and 
    `verbose` will be constructed based on the specified `minimumSeverity`.
    Each channel will use `receptacle` as the underlying `LogReceptacle`.

    :param:     receptacle The list of `LogConfiguration`s to use for controlling
                the behavior of logging.

    :param:     minimumSeverity The minimum `LogSeverity` for which log messages
                will be accepted. Attempts to log messages less severe than
                `minimumSeverity` will be silently ignored.
    */
    public static func enable(receptacle: LogReceptacle, minimumSeverity: LogSeverity = .Info)
    {
        enable(
            errorChannel: self.logChannelWithSeverity(.Error, receptacle: receptacle, minimumSeverity: minimumSeverity),
            warningChannel: self.logChannelWithSeverity(.Warning, receptacle: receptacle, minimumSeverity: minimumSeverity),
            infoChannel: self.logChannelWithSeverity(.Info, receptacle: receptacle, minimumSeverity: minimumSeverity),
            debugChannel: self.logChannelWithSeverity(.Debug, receptacle: receptacle, minimumSeverity: minimumSeverity),
            verboseChannel: self.logChannelWithSeverity(.Verbose, receptacle: receptacle, minimumSeverity: minimumSeverity)
        )
    }

    /**
    Enables logging using the specified `LogChannel`s.

    The static `error`, `warning`, `info`, `debug`, and `verbose` properties of
    `Log` will be set using the specified values.
    
    If you know that the configuration of a given `LogChannel` guarantees that
    it will never perform logging, it is best to pass `nil` instead. Otherwise,
    needless overhead will be added to the application.

    :param:     errorChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Error`.

    :param:     warningChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Warning`.

    :param:     infoChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Info`.

    :param:     debugChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Debug`.

    :param:     verboseChannel The `LogChannel` to use for logging messages with
                a `severity` of `.Verbose`.
    */
    public static func enable(#errorChannel: LogChannel?, warningChannel: LogChannel?, infoChannel: LogChannel?, debugChannel: LogChannel?, verboseChannel: LogChannel?)
    {
        dispatch_once(&enableOnce) {
            self._error = errorChannel
            self._warning = warningChannel
            self._info = infoChannel
            self._debug = debugChannel
            self._verbose = verboseChannel
        }
    }

    private static var _error: LogChannel?
    private static var _warning: LogChannel?
    private static var _info: LogChannel?
    private static var _debug: LogChannel?
    private static var _verbose: LogChannel?

    private static var enableOnce = dispatch_once_t()

    private static func logChannelWithSeverity(severity: LogSeverity, receptacle: LogReceptacle, minimumSeverity: LogSeverity)
        -> LogChannel?
    {
        if severity.compare(.AsOrMoreSevereThan, against: minimumSeverity) {
            return LogChannel(severity: severity, receptacle: receptacle)
        }
        return nil
    }
}
