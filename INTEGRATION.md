![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# CleanroomLogger Integration Notes

This document describes how to integrate CleanroomLogger into your application.

*Integration* is the act of embedding the `CleanroomLogger.framework` binary (and its required `CleanroomASL.framework` dependency) into your project, thereby exposing the API it provides to your code.

Note that CleanroomLogger is built as a *Swift framework*. This has several implications, not the least of which is that it will only work on iOS 8 or above. It is also only supported for use by other Swift code. Some, all or none of it may work from Objective-C; we haven't tried it, we wouldn't recommend it, and we don't support it.

### Contents

- **[Options for integration](#options-for-integration)**
- **[Instructions for manual integration](#manual-integration)**
- **[Instructions for integration using Carthage](#carthage-integration)**

### Requirements

CleanroomLogger requires a **mimimum Xcode version of 6.3** to be built, and the resulting binary can be used on **iOS 8.1 and higher**.

We'll also be using the `git` command in the Terminal for installing the CleanroomLogger repo in your codebase. These steps have been tested with **git 2.3.2 (Apple Git-55)**, although they should be compatible with a wide range of git versions.

Lastly, some familiarity with the Terminal application and the bash command line is assumed.

### About Frameworks

Official support for third-party iOS frameworks was introduced with Xcode 6 and iOS 8. Prior to that, developers had been using frameworks in an unsupported fashion by placing shared libraries and resources inside a filesystem structure that mimicked that of the frameworks published by Apple.

Given that *real* third-party iOS framework support is still in its infancy, it should be no surprise that there are still kinks in the development process when using them:

- The iOS Simulator uses a different processor architecture than real devices. As a result, **frameworks compiled for device won't work in the simulator, and vice-versa**. Sure, you *could* use `lipo` to stitch together a universal binary and use that instead, but...

- **Apple will not accept App Store binaries containing iOS Simulator code.** That means if you go the universal binary route, now you need a custom build step to make the universal binary, and you need another step to un-make the universal binary when you're building for submission. Okay, well, why not just build *two* frameworks: one for the iOS Simulator and one for devices?

- **Xcode won't be happy if you import two separate frameworks with the same symbols.** Xcode won't notice that there really is no conflict because the frameworks are compiled for different processor architectures. All Xcode will care about is that you're importing two separate frameworks that both claim to have the same module name.

For these reasons, we do not release Cleanroom projects as framework binaries. Instead, we provide the source, the Xcode project file, and options for integrating so that you can use it from within your code and submit an app that Apple will accept. (Or, at the very least, if Apple *doesn't* accept your app, we don't want it to be the fault of *this* project!)

### Options for integration

There are two supported options for integration:

- **Manual integration** — The `CleanroomLogger.xcodeproj` Xcode project file is embedded directly within your project. You then add `CleanroomLogger.framework` and `CleanroomASL.framework` to the *Embedded Binaries* and *Linked Frameworks and Libraries* sections under the *General* tab for your application target.

- **Carthage integration** — [Carthage](https://github.com/Carthage/Carthage) is a dependency package manager designed to build frameworks. Once Carthage is installed, to add CleanroomLogger to your project using Carthage, you would put the line `github "emaloney/CleanroomLogger"` in your `Cartfile` and then issue the command `carthage update`.

Whether you choose one over the other largely depends on your preferences and—in the case of Carthage—whether you're already using that solution for other dependencies.

## Manual Integration

Manual integration involves embedding `CleanroomLogger.xcodeproj` directly in your Xcode project.

This will ensure that CleanroomLogger is built with the exact same settings you’re using for your app. You won’t have to fiddle with different settings for different architectures — when you're running in the simulator, it will work; when you then switch to building for device, it'll work, too.

You’ll also be able to step into CleanroomLogger code directly in the debugger without worrying about `.dSYM` resolution, which is very helpful.

### An Overview of the Process

Manual integration is a bit involved; there are five high-level tasks that you'll need to perform:

1. Download the CleanroomLogger source into your project structure
2. Embed `CleanroomLogger.xcodeproj` in your Xcode project
3. Build `CleanroomLogger.framework`; this will also cause the `CleanroomASL.framework` dependency to be built
4. Add `CleanroomLogger.framework` and `CleanroomASL.framework` to your application target
5. Fix the way Xcode references the frameworks you added in Step 4

#### Getting Started

Launch Terminal on your Mac, and `cd` to the directory that contains your application.

For our integration examples, we're going to be showing the top-level `CleanroomLogger` directory inside a `Libraries` directory at the root level of of your application's source.

> You do not *need* to use this structure, although we'd recommend it, if only to make the following examples work for you without translation.

If you do not already have a `Libraries` directory, create one:

```bash
mkdir Libraries
```

Next, `cd` into `Libraries` and follow the instructions below.

### 1. Download the CleanroomLogger source

If you're already using git for version control, we recommend adding CleanroomLogger to your project as a submodule. This will allow you to "lock" your codebase to specific versions of CleanroomLogger, making it easier to incorporate new versions on whatever schedule works best for you.

If you're using some other form of version control of if you're not using version control at all—*shame on you!*—then you'll want to *clone* the CleanroomLogger repository. We suggest putting the CleanroomLogger clone somewhere within your application's directory structure, so that it is included in whatever version control regimen you're using.

#### Downloading CleanroomLogger as a submodule

> **Important:** Skip this section if you plan to download CleanroomLogger using `git clone`.

From within the `Libraries` directory, issue the following commands to download CleanroomLogger:

```bash
git submodule add https://github.com/emaloney/CleanroomLogger.git
git submodule update --init --recursive
```

Next, you're ready to [embed the `CleanroomLogger.xcodeproj` project file in your Xcode project](#2-embed-cleanroomasl-in-your-project).

#### Downloading CleanroomLogger as a cloned repo

> **Important:** Skip this section if you already performed the tasks outlined in "Downloading CleanroomLogger as a submodule" above.

From within the `Libraries` directory, issue the following command to clone the CleanroomLogger repository:

```bash
git clone --recursive https://github.com/emaloney/CleanroomLogger.git
```

### 2. Embed CleanroomLogger in your project

In the Terminal, the command `open CleanroomLogger` to open the folder containing the CleanroomLogger source in the Finder. This will reveal the `CleanroomLogger.xcodeproj` Xcode project and all files needed to build `CleanroomLogger.framework` and its `CleanroomASL.framework` dependency.

Then, open your application in Xcode, and drag `CleanroomLogger.xcodeproj` into the Xcode project browser. This will embed CleanroomLogger in your project and allow you to add the targets built by CleanroomLogger to your project.

### 3. Build CleanroomLogger

Before we can add `CleanroomLogger.framework` to your app, we have to build it, so Xcode has more information about the framework.

**Important:** The next step will only work when the framework is built for a **device-based run destination**. That means that you must either select the generic "iOS Device" run destination before building, or you must select an actual device (an option that's only available when a device is connected).

Once a device-based run destination has been selected, select the "CleanroomLogger" build scheme. Then, select *Build* (⌘B) from the *Product* menu.

Once the build is complete, open `CleanroomLogger.xcodeproj` in the project navigator and find the "Products" group. Open that, and right-click on `CleanroomLogger.framework`. Select *Show in Finder*. This will open the folder containing the framework binary you just built.

If all went well, you should see several files in this folder; the ones we're concerned with are:

- `CleanroomLogger.framework`
- `CleanroomASL.framework`

If those files aren't present, something went wrong with the build.

### 4. Add the necessary frameworks to your app target

In Xcode, select the *General* tab in the build settings for your application target. Scroll to the bottom of the screen to reveal the section entitled *Embedded Binaries* (the second-to-last section).

Go back to Finder, and option-click `CleanroomLogger.framework` and `CleanroomASL.framework` to select them both, and then drag them into the list area directly below  *Embedded Binaries*.

If successful, you should see `CleanroomLogger.framework` and `CleanroomASL.framework` listed under both the *Embedded Binaries* and *Linked Frameworks and Libraries* sections.

### 5. Fix how Xcode references the frameworks

Unfortunately, Xcode will reference the frameworks you just added in a way that will eventually cause you pain, particularly if multiple developers are sharing the same project file (in which case the pain will be felt almost immediately).

So, to make things sane again, you'll need to make sure Xcode references `CleanroomLogger.framework` and `CleanroomASL.framework` using a "Relative to Build Products" location.

To do this, repeat the following steps for each framework:

1. Locate the framework in the Xcode project browser
2. Select the framework
3. Ensure the Xcode project window's *Utilities* pane is open
4. Show the *File Inspector* in the *Utilities* pane
5. Under the *Identity and Type* section, find the dropdown for the *Location* setting
6. If the *Location* dropdown does not show "Relative to Build Products" as the setting, select "Relative to Build Products"

Once you've done this for each framework, **_you're all done integrating CleanroomLogger!_**

Skip to the [Adding the Swift import](#adding-the-swift-import) section to see how you can import CleanroomLogger for use in your Swift code.

## Carthage Integration

Carthage is a third-party package dependency manager for iOS and Mac OS X. Carthage works by building frameworks for each of a project's dependencies.

### Verifying Carthage availability

Before attempting any of the steps below, you should verify that Carthage is available on your system. To do that, open Terminal and execute the command:

```bash
carthage version
```

If Carthage is available, the version you have installed will be shown.

> As of this writing, the current version of Carthage is 0.6.4.

If Carthage is not present, you will see an error that looks like:

```
-bash: carthage: command not found
```

Installing Carthage is beyond the scope of this document. If you do not have Carthage installed but would like to use it, [you can find installation instructions on the project page](https://github.com/Carthage/Carthage#installing-carthage).

### How Carthage builds work

For iOS, Carthage builds *universal binary* frameworks, meaning that they will work in the iOS Simulator as well as on actual devices. However, because Apple will not accept App Store submissions containing universal binary code, Carthage requires the addition of a build step that strips all unused architectures out of the universal binaries. That way, when building for the simulator, device code is removed; conversely, when creating a device build, simulator code is removed. This keeps Apple happy, while also making it easy to switch back and forth between running on the device and in the simulator.

### An Overview of the Process

Carthage integration is a little simpler than manual integration:

1. Update the `Cartfile` with an entry for CleanroomLogger
2. Download and build CleanroomLogger
3. Add `CleanroomLogger.framework` and `CleanroomASL.framework`  to your application target
4. Create a build phase to strip the extra processor architectures from the Carthage frameworks

### Getting Started

We'll start in the Terminal, by `cd`ing into to your project's root directory. The commands you'll need to issue below can all be done from this location.

### 1. Update the Cartfile

In your project's root directory, edit the file named `Cartfile`—creating it if necessary—to add the following line:

```
github "emaloney/CleanroomLogger"
```

### 2. Download & Build using Carthage

In Terminal, issue the command:

```bash
carthage update
```

This will cause Carthage to download and build CleanroomLogger.

#### Where Carthage puts its files

Carthage puts its files within a top-level directory called `Carthage` at the root of your project's directory structure (i.e., the `Carthage` directory is a sibling of the `Cartfile`). Within this directory are two more directories: `Build`, which contains the frameworks built by Carthage; and `Checkouts`, which contains fully populated directory structures for each repository specified in the `Cartfile`.

> We recommend adding `Carthage/` to your `.gitignore` file, since the files in the `Carthage` directory are the equivalent of build artifacts.

Once Carthage is done building CleanroomLogger and its dependencies, you can execute the following Terminal command to see the frameworks built by Carthage:

```bash
open Carthage/Build/iOS
```

This will cause the directory containing `CleanroomLogger.framework` and its required `CleanroomASL.framework` dependency to open in Finder.

If those files aren't present, something went wrong with the build.

### 3. Add the necessary frameworks to your app target

In Xcode, select the *General* tab in the build settings for your application target. Scroll to the bottom of the screen to reveal the section entitled *Embedded Binaries* (the second-to-last section).

Go back to Finder, and option-click `CleanroomLogger.framework` and `CleanroomASL.framework` to select them both, and then drag them into the list area directly below  *Embedded Binaries*.

If successful, you should see `CleanroomLogger.framework` and `CleanroomASL.framework` listed under both the *Embedded Binaries* and *Linked Frameworks and Libraries* sections.

### 4. Create a build phase to strip the Carthage frameworks

In Xcode, select the *Build Phases* tab in the build settings for your application target.

At the top-left corner of the list of build phases, you will see a "`+`" icon. Click that icon and add a "New Run Script Phase".

Then, in the script editor area just below the *Shell* line, add the following text:

```
$PROJECT_DIR/Carthage/Checkouts/CleanroomLogger/BuildControl/bin/stripCarthageFrameworks.sh
```

This script will ensure that the frameworks built by Carthage are stripped of unnecessary processor architectures. Without this step, Apple would reject your app submission because the Carthage frameworks would be included as universal binaries, which [isn't allowed in App Store submissions](http://www.openradar.me/radar?id=6409498411401216).

Once you've done this, try building your application. If you don't see any errors, **_you're all done integrating CleanroomLogger!_**

## Adding the Swift import

Once CleanroomLogger has been successfully integrated, all you will need to do is add the following `import` statement to any Swift source file where you want to use CleanroomLogger:

```swift
import CleanroomLogger
```

Want to read more about CleanroomLogger? Check out [the README](https://github.com/emaloney/CleanroomLogger/blob/master/README.md).

**_Happy coding!_**
