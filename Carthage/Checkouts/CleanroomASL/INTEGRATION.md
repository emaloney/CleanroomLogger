![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# CleanroomASL Integration Notes

This document describes how to integrate CleanroomASL into your application.

*Integration* is the act of embedding the `CleanroomASL.framework` binary into your project, thereby exposing the API it provides to your code.

CleanroomASL is built as a *Swift framework*, and as such, it has the following base platform requirements:

Platform|Minimum OS version
--------|------------------------
Apple TV|tvOS 9.0
Apple Watch|watchOS 2.0
iPhone/iPad|iOS 8.0
Mac|OS X 10.10

CleanroomASL is **Swift 2.2 compliant** and therefore **requires Xcode 7.3 or higher** to compile.

### Contents

- **[Options for integration](#options-for-integration)**
- **[Instructions for integration using Carthage](#carthage-integration)**
- **[Instructions for manual integration](#manual-integration)**

### Prerequisites

Some familiarity with the Terminal application, the bash command line, and the `git` command is assumed.

The steps below have been tested with **git 2.6.4 (Apple Git-63)**, although they should be compatible with a wide range of recent git versions.


### Of Frameworks and Simulators

When developing for a platform with a simulator, there are some kinks in the process:

- Simulators use a different processor architecture than real devices. As a result, **frameworks compiled only for device won’t work in the simulator, and vice-versa**. Sure, you *could* use `lipo` to stitch together a universal binary and use that instead, but...

- **Apple will not accept App Store binaries containing simulator code.** That means if you go the universal binary route, you now need a custom build step to make the universal binary, and another step to un-make the universal binary when you’re building for submission. Okay, well, why not just build *two* frameworks: one specifically for the simulator and the other for devices?

- **Xcode won’t be happy if you import two separate frameworks with the same symbols.** Xcode won’t notice that there really is no conflict because the frameworks are compiled for different processor architectures. All Xcode will care about is that you’re importing two separate frameworks that both claim to have the same module name.

For these reasons, we do not release Cleanroom projects as framework binaries. Instead, we provide the source, the Xcode project file, and options for integrating so that you can use it from within your code and submit an app that Apple will accept. (Or, at the very least, if Apple *doesn’t* accept your app, we don’t want it to be the fault of *this* project!)

### Options for integration

There are two supported options for integration:

- **[Carthage integration](#carthage-integration)** — Explains how to use the [Carthage](https://github.com/Carthage/Carthage) dependency manager for adding CleanroomASL to your project.

- **[Manual integration](#manual-integration)** — Demonstrates the steps for adding CleanroomASL by embedding `CleanroomASL.xcodeproj` within your own Xcode project. (**Note:** Manual integration is a bit more involved than using Carthage).

Whether you choose one over the other largely depends on your preferences and—in the case of Carthage—whether you’re already using that solution for other dependencies.

## Carthage Integration

Carthage is a third-party package dependency manager for iOS and Mac OS X. Carthage works by building frameworks for each of a project’s dependencies.

### Verifying Carthage availability

Before attempting any of the steps below, you should verify that Carthage is available on your system. To do that, open Terminal and execute the command:

```bash
carthage version
```

If Carthage is available, the version you have installed will be shown.

> As of this writing, the current version of Carthage is 0.15.2.

If Carthage is not present, you will see an error that looks like:

```
-bash: carthage: command not found
```

Installing Carthage is beyond the scope of this document. If you do not have Carthage installed but would like to use it, [you can find installation instructions on the project page](https://github.com/Carthage/Carthage#installing-carthage).

### How Carthage builds frameworks

When building a framework for a platform with a simulator, Carthage creates a *universal binary*, allowing `CleanroomASL.framework` to work in the simulator as well as on actual devices.

However, because Apple will not accept App Store submissions containing universal binary code, Carthage requires the addition of a build step that strips all unused architectures out of the universal binaries. That way, when building for the simulator, device code is removed; conversely, when creating a device build, simulator code is removed. This keeps Apple happy, while also making it easy to switch back and forth between running on the device and in the simulator.

### An Overview of the Process

Carthage integration is a little simpler than manual integration:

1. Update the `Cartfile` with an entry for CleanroomASL
2. Download and build CleanroomASL
3. Add `CleanroomASL.framework` to your application target
4. Create a build phase to strip the extra processor architectures from the Carthage framework (not necessary for Mac OS X builds)

### Getting Started

We’ll start in the Terminal, by `cd`ing into to your project’s root directory. The commands you’ll need to issue below can all be done from this location.

### 1. Update the Cartfile

In your project’s root directory, edit the file named `Cartfile`—creating it if necessary—to add the following line:

```
github "emaloney/CleanroomASL"
```

### 2. Download & Build using Carthage

The command `carthage update` causes Carthage to download and build CleanroomASL.

By default, `carthage update` builds all platform targets in a project. Normally, this is _not_ what you want; you’ll usually use CleanroomASL on just one platform at a time.

To speed up the build process—and to avoid trying to build for a platform that might not be supported by the version of Xcode you have—it is _strongly recommended_ that you pass the `--platform` argument to `carthage update`:

To build for|Run the command
--------|------------------------
Apple TV|`carthage update --platform tvos`
Apple Watch|`carthage update --platform watchos`
iPhone/iPad|`carthage update --platform ios`
Mac|`carthage update --platform mac`

#### Where Carthage stores files

Carthage puts its files within a top-level directory called `Carthage` at the root of your project’s directory structure (i.e., the `Carthage` directory is a sibling of the `Cartfile`). Within this directory are two more directories: `Build`, which contains any frameworks built by Carthage; and `Checkouts`, which contains fully populated directory structures for each repository specified in the `Cartfile`.

> **Note:** By default, Carthage builds a framework for each platform supported by the project. You can limit the build to a specific platform by specifying a value for the `--platform` argument when invoking the `carthage` command.

Once Carthage is done building CleanroomASL, you can use the `open` command to locate the framework binaries in Finder:

```bash
open Carthage/Build/iOS
```

The command above opens the directory containing the iOS framework binary; to locate the Mac OS X binary, execute:

```bash
open Carthage/Build/Mac
```

If all went well, the Carthage build directories should contain the file `CleanroomASL.framework`. If that file isn’t present, something went wrong with the build.

### 3. Add the necessary framework to your app target

In Xcode, select the *General* tab in the build settings for your application target. Scroll to the bottom of the screen to reveal the section entitled *Embedded Binaries* (the second-to-last section).

Go back to Finder, select the file `CleanroomASL.framework`, and then drag it into the list area directly below *Embedded Binaries*.

If successful, you should see `CleanroomASL.framework` listed under both the *Embedded Binaries* and *Linked Frameworks and Libraries* sections.

### 4. Create a build phase to strip the Carthage framework

> **Note:** You do *not* need to perform this step when building for Mac OS X. This step is only necessary when building for targets that can be run in a simulator.

In Xcode, select the *Build Phases* tab in the build settings for your application target.

At the top-left corner of the list of build phases, you will see a “`+`” icon. Click that icon and add a “New Run Script Phase”.

Then, in the script editor area just below the *Shell* line, add the following text:

```
"$PROJECT_DIR"/Carthage/Checkouts/CleanroomASL/BuildControl/bin/stripCarthageFrameworks.sh
```

This script will ensure that any frameworks built by Carthage are stripped of unnecessary processor architectures. Without this step, Apple would reject your app submission because the framework would be included as universal binaries, which [isn’t allowed in App Store submissions](http://www.openradar.me/radar?id=6409498411401216).

Once you’ve done this, try building your application. If you don’t see any errors, **_you’re all done integrating CleanroomASL!_**

But before you start coding, skip to the [Adding the Swift import](#adding-the-swift-import) section to see how you can import CleanroomASL for use in your Swift code.

## Manual Integration

Manual integration involves embedding `CleanroomASL.xcodeproj` directly in your Xcode project.

This will ensure that CleanroomASL is built with the exact same settings you’re using for your app. You won’t have to fiddle with different settings for different architectures — when you’re running in the simulator, it will work; when you then switch to building for device, it’ll work, too.

You’ll also be able to step into CleanroomASL code directly in the debugger without worrying about `.dSYM` resolution, which is very helpful.

### An Overview of the Process

Manual integration is a bit involved; there are five high-level tasks that you’ll need to perform:

1. Download the CleanroomASL source into your project structure
2. Embed `CleanroomASL.xcodeproj` in your Xcode project
3. Build `CleanroomASL.framework`
4. Add `CleanroomASL.framework` to your application target
5. Fix the way Xcode references the framework you added in Step 4

#### Getting Started

Launch Terminal on your Mac, and `cd` to the directory that contains your application.

For our integration examples, we’re going to be showing the top-level `CleanroomASL` directory inside a `Libraries` directory at the root level of of your application’s source.

> You do not *need* to use this structure, although we’d recommend it, if only to make the following examples work for you without translation.

If you do not already have a `Libraries` directory, create one:

```bash
mkdir Libraries
```

Next, `cd` into `Libraries` and follow the instructions below.

### 1. Download the CleanroomASL source

If you’re already using git for version control, we recommend adding CleanroomASL to your project as a submodule. This will allow you to “lock” your codebase to specific versions of CleanroomASL, making it easier to incorporate new versions on whatever schedule works best for you.

If you’re using some other form of version control of if you’re not using version control at all—*shame on you!*—then you’ll want to *clone* the CleanroomASL repository. We suggest putting the CleanroomASL clone somewhere within your application’s directory structure, so that it is included in whatever version control regimen you’re using.

#### Downloading CleanroomASL as a submodule

> **Important:** Skip this section if you plan to download CleanroomASL using `git clone`.

From within the `Libraries` directory, issue the following commands to download CleanroomASL:

```bash
git submodule add https://github.com/emaloney/CleanroomASL
git submodule update --init --recursive
```

Next, you’re ready to [embed the `CleanroomASL.xcodeproj` project file in your Xcode project](#2-embed-cleanroomasl-in-your-project).

#### Downloading CleanroomASL as a cloned repo

> **Important:** Skip this section if you already performed the tasks outlined in “Downloading CleanroomASL as a submodule” above.

From within the `Libraries` directory, issue the following command to clone the CleanroomASL repository:

```bash
git clone https://github.com/emaloney/CleanroomASL
```

### 2. Embed CleanroomASL in your project

In the Terminal, the command `open CleanroomASL` to open the folder containing the CleanroomASL source in the Finder. This will reveal the `CleanroomASL.xcodeproj` Xcode project and all files needed to build `CleanroomASL.framework`.

Then, open your application in Xcode, and drag `CleanroomASL.xcodeproj` into the Xcode project browser. This will embed CleanroomASL in your project and allow you to add the targets built by CleanroomASL to your project.

### 3. Build CleanroomASL

Before we can add `CleanroomASL.framework` to your app, we have to build it, so Xcode has more information about the framework.

**Important:** The next step will only work when the framework is built for a **device-based run destination**. That means that you must either select the “My Mac” or “iOS Device” run destination before building, or you must select an actual external device (an option that’s only available when such a device is connected to your development machine).

Once a device-based run destination has been selected, select the appropriate build scheme for the target platform: “CleanroomASL-iOS”, “CleanroomASL-OSX”, “CleanroomASL-tvOS” or “CleanroomASL-watchOS”.

Then, select *Build* (⌘B) from the *Product* menu.

Once the build is complete, open `CleanroomASL.xcodeproj` in the project navigator and find the “Products” group. Open that, and right-click on `CleanroomASL.framework`. Select *Show in Finder*. This will open the folder containing the framework binary you just built.

You may see several files in this folder; the one we’re concerned with is:

- `CleanroomASL.framework`


If that file isn’t present, something went wrong with the build.

### 4. Add the necessary framework to your app target

In Xcode, select the *General* tab in the build settings for your application target. Scroll to the bottom of the screen to reveal the section entitled *Embedded Binaries* (the second-to-last section).

Go back to Finder, select the file `CleanroomASL.framework`, and then drag it into the list area directly below *Embedded Binaries*.

If successful, you should see `CleanroomASL.framework` listed under both the *Embedded Binaries* and *Linked Frameworks and Libraries* sections.

### 5. Fix how Xcode references the framework

Unfortunately, Xcode will reference the framework you just added in a way that will eventually cause you pain, particularly if multiple developers are sharing the same project file (in which case the pain will be felt almost immediately).

So, to make things sane again, you’ll need to make sure Xcode references `CleanroomASL.framework` using a “Relative to Build Products” location.

To do this:

1. Locate `CleanroomASL.framework` in the Xcode project browser
2. Select the framework
3. Ensure the Xcode project window’s *Utilities* pane is open
4. Show the *File Inspector* in the *Utilities* pane
5. Under the *Identity and Type* section, find the dropdown for the *Location* setting
6. If the *Location* dropdown does not show “Relative to Build Products” as the setting, select “Relative to Build Products”

Once you’ve done this for each framework, **_you’re all done integrating CleanroomASL!_**

## Adding the Swift import

Once CleanroomASL has been successfully integrated, all you will need to do is add the following `import` statement to any Swift source file where you want to use CleanroomASL:

```swift
import CleanroomASL
```

Want to learn more about CleanroomASL? Check out [the README](https://github.com/emaloney/CleanroomASL/blob/master/README.md).

**_Happy coding!_**
