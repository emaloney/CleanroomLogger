# Async

The Async package of [`CleanroomBase`](https://github.com/emaloney/CleanroomBase) contains utilities for simplifying asynchronous code execution.

## AsyncFunctions

The [`AsyncFunctions.swift`](AsyncFunctions.swift) file contains top-level functions that declare a simplified interface for executing code asynchronously.

Under the hood, these functions all rely on a single, privately-maintained concurrent Grand Central Dispatch (GCD) queue.

### async

The `async` function provides a simple notation for specifying that a block of code should be executed asynchronously.

`async` takes as a parameter a no-argument function returning `Void`, and is typically invoked with a closure:

```swift
async {
	println("This will execute asynchronously")
}
```

The operation specified by the closure—the `println()` call above—will be executed asynchronously.
 
### async with delay

A variation on the `async` function takes a `delay` parameter, an `NSTimeInterval` value specifying the *minimum* number of seconds to wait before asynchronously executing the closure:

```swift
async(delay: 0.35) {
	println("This will execute asynchronously after at least 0.35 seconds")
}
```

Note that this function does not perform real-time scheduling, so the asynchronous operation is **not** guaranteed to execute immediately once `delay` number of seconds has elapsed; instead, it will execute after *at least* `delay` number of seconds has elapsed.

### mainThread

The `mainThread` function enqueues an operation for eventual execution on the main `NSThread` of the application.

This is useful because certain operations are only allowed to be executed on the main thread, such as view hierarchy manipulations. This is why the main thread is sometimes called *the user interface thread*.

The `mainThread` function is typically invoked with a closure as follows:

```swift
mainThread {
	UIApplication.sharedApplication().keyWindow!.rootViewController = self
}
```

The notation above ensures that the `rootViewController` is changed only on the main thread.

### mainThread with delay

As with the `async` function, a variation of the `mainThread` function takes a `delay` parameter:

```swift
mainThread(delay: 0.35) {
	view.hidden = true
	view.alpha = 1.0
}
```

In the example above, the closure will be executed on the main thread after *at least* `0.35` seconds have elapsed.

### asyncBarrier

The `asyncBarrier` function submits a barrier operation for asynchronous execution.

Barriers make it possible to create a synchronization point for operations:

- Operations submitted prior to the submission of the barrier operation are guaranteed to execute *before* the barrier.

- After all operations submitted prior to the barrier have been executed, *then* the barrier operation is executed. 

- While the barrier operation is executing, no other operations in the queue will execute.

- Once the barrier operation finishes executing, normal concurrent behavior resumes; operations submitted after the barrier will then be executed.

Barrier operations are submitted for eventual execution using the notation:

```swift
asyncBarrier {
	println("When this executes, no other operations will be executing")
}
```

**Important:** Because these functions all rely on a single shared GCD queue, use of the `asyncBarrier` function can have application-wide impact. As a result, the function should be used sparingly, and only in situations where an application-wide barrier is truly needed.

If you do not need an application-wide barrier, it may be best to maintain your own queue and use the `dispatch_barrier_async` GCD function instead.
