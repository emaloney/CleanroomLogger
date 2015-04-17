# Bridging

The Bridging package of [`CleanroomBase`](https://github.com/emaloney/CleanroomBase) contains utilities to help bridge the gap between Objective-C and Swift.

## TargetAction

The `TargetAction` class allows you to use a Swift closure wherever a standard Cocoa target (`id`) and action (`SEL`) pair can be used.

The closure can take zero or one arguments, as is typical with the target/action paradigm.

### Example: A UIButton action

You can use a `TargetAction` instance to set up `UIButton` action handler in conjunction with the `addTarget(_:, action:, forControlEvents:)` function declared as part of the `UIControl` superclass of `UIButton`:

```swift
func addActionHandlerForButton(button: UIButton)
{
	let handler = TargetAction() { (argument: AnyObject?) -> Void in
		let button = argument as? UIButton
		println("Button tapped: \(button?.description)")
	}
	
	button.addTarget(handler.target, action: handler.action, forControlEvents: .TouchUpInside)
}
```

The function above sets up a handler that will print out information about `button` when it is tapped.

Note that the closure passed to the `TargetAction` constructor takes an argument. In the case of a `UIControl` target/action, the argument's value will be the control sending the action.

### Example: An NSTimer action

```swift
let clock = TargetAction() {
	println("The time is now \(NSDate())")
}

let timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                                           target: clock.target, 
                                         selector: clock.action,
                                         userInfo: nil,
                                          repeats: true)
```

The example above sets up a timer that will result in the current time being printed to the console every second.