# CleanroomLogger Breaking Changes

Cleanroom Project frameworks adhere to [the semantic versioning system used by Carthage](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement).

This system assigns version numbers with three independent integer values separated by periods:

    major.minor.patch

- When the *major version* is incremented, it reflects large-scale changes to the framework that are likely to introduce public API changes, possibly significant ones.
- An incremented the *minor version* usually signals additional functionality or minor rearchitecting, either of which *may* bring changes to the public API.
- An incremented *patch version* signals bugfixes and/or cleanup, but should **not** signal breaking API changes. (If a breaking change is made to the public API in a patch release, it is unintentional and should be considered a bug.)

## 1.2.0

1. The dependency on CleanroomBase has been removed. As a result, `CleanroomLogger.xcodeproj` will no longer build `CleanroomBase.framework`. If your project references `CleanroomBase.framework` solely as a result of a previous version of CleanroomLogger, you may safely remove it. Otherwise, if your project continues to use CleanroomBase, [you will need to integrate with it directly](https://github.com/emaloney/CleanroomBase/blob/master/INTEGRATION.md).

2. The signature of the `LogRecorder` function `recordFormattedString(_:synchronously:currentQueue:forLogEntry:)` has been refactored to `recordFormattedMessage(_:forLogEntry:currentQueue:synchronousMode:)` to be more consistent with terminology used elsewhere in the API.

## 1.3.0

1. The `LogSeverity.Comparator` enum has been removed. Instead, the `LogSeverity` protocol now conforms to `Comparable`.

2. The representation of thread IDs has been changed from `Int` to `UInt64` to be in line with the C-based `pthread` API from which we're retrieving them.

## 1.4.0

This release uses a pre-release version 2.0 of the Swift language, and therefore requires specific _beta_ versions of Xcode 7 that are no longer supplied by Apple.

As a result, the 1.4.x release line is no longer supported.

## 1.5.0

This release uses Swift 2.0 and requires a release version of Xcode 7.

This release also adds support for tvOS.

## 1.6.0

This release added support for [XcodeColors](https://github.com/emaloney/CleanroomLogger#xcodecolors-support).

When XcodeColors is installed and enabled, the [`DefaultLogFormatter`](https://rawgit.com/emaloney/CleanroomLogger/master/Documentation/API/Structs/DefaultLogFormatter.html) will apply automatic log colorization based on the `LogSeverity` of what's being logged.

Adding colorization functionality required breaking API changes to the `DefaultLogFormatter`.
