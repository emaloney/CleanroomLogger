# Concurrency

The Concurrency package of [`CleanroomBase`](https://github.com/emaloney/CleanroomBase) contains utilities for simplifying access to resources in a concurrent execution environment.

## CriticalSection

A `CriticalSection` provides a simple way to synchronize the execution of code across multiple threads.

`CriticalSection`s are a form of a *mutex* (or *mutual exclusion*) lock: when one thread is executing code within a given critical section, it is guaranteed that no other thread will be executing within the same instance.

In this way, `CriticalSection`s are similar to `@synchronized` blocks in Objective-C.

### Using a CriticalSection

With a `CriticalSection`, any code inside the `execute` closure (shown below as the "`// code to execute`" comment) is executed only after exclusive access to the critical section has been acquired by the calling thread.

```swift
let cs = CriticalSection()

cs.execute {
	// code to execute
}
```

Because it is possible for a `CriticalSection` to be used in a way where `execute` could block forever—resulting in a thread dealock—a variation is provided that allows a timeout to be specified:

```swift
let cs = CriticalSection()

let success = cs.executeWithTimeout(1.0) {
	// code to execute
}

if !success {
	// handle the fact that `executeWithTimeout()` timed out
}
```

The timeout is an `NSTimeInterval` value specifying the number of seconds to wait for access to the critical section before giving up.

In the example above, the calling thread may block for up to `1.0` seconds waiting for the critical section represented by `cs` to be acquired.

If `cs` can be acquired within that time, "`// code to execute`" will execute and `executeWithTimeout()` will return `true`.

If exclusive access to the critical section `cs` can't be acquired within `1.0` seconds, nothing will be executed and `executeWithTimeout()` will return `false`.

**Note:** It is best to design your implementation to avoid the potential for a deadlock. However, sometimes this is not possible, which is why the `executeWithTimeout()` function is provided.

### Implementation Details

The `CriticalSection` implementation uses an `NSRecursiveLock` internally, which enables `CriticalSection`s to be re-entrant. This means that a thread can't deadlock on a `CriticalSection` it already holds.

In addition, the `CriticalSection` implementation also performs internal exception trapping to ensure that the lock state remains consistent.

## ReadWriteCoordinator

`ReadWriteCoordinator` instances can be used to coordinate access to a mutable resource shared across multiple threads.

You can think of the `ReadWriteCoordinator` as a dual read/write lock having the following properties:

- The *read lock* allows any number of *readers* to execute concurrently.

- The *write lock* allows one and only one *writer* to execute at a time.

- As long as there is at least one reader executing, the write lock cannot be acquired.

- As long as the write lock is held, no readers can execute.

- All reads execute synchronously; that is, they block the calling thread until they complete.

- All writes execute asynchronously.

- Any read submitted before a write is guaranteed to be executed before that write, while any write submitted before a read is guaranteed to be executed before that read. This ensures a consistent view of shared resource's state.

> The term *lock* is used in this document for conceptual clarity. In reality, the implementation uses Grand Central Dispatch and not a traditional lock.

### Usage

For any given shared resource that needs to be protected by a read/write lock, you can create a `ReadWriteCoordinator` instance to manage access to that resource.

```swift
let lock = ReadWriteCoordinator()
```

You would then hold a reference to that `ReadWriteCoordinator` for the lifetime of the shared resource.

### Reading

Whenever you need read-only access to the shared resource, you wrap your access within a call to the `ReadWriteCoordinator`'s `read()` function, which is typically called with a trailing closure:

```swift
lock.read {
	// read some data from the shared resource
}
```

Because reads are executed synchronously, the `ReadWriteCoordinator` can be used within property getters, eg.:

```swift
var globalCount: Int {
	get {
		var count: Int?
		lock.read {
			count = // get a count from the shared resource
		}
		return count!
	}
}
```

### Writing

Whenever you need to modify the state of the shared resource, you do so using the `enqueueWrite()` function of the `ReadWriteCoordinator`.

As with `read()`, this function is typically invoked with a closure:

```swift
lock.enqueueWrite {
	// modify the shared resource
}
```

Unlike `read()`, however, the `enqueueWrite()` function is asynchronous, as its name implies. 

Write operations are submitted to the underlying GCD queue, and `enqueueWrite()` returns immediately.

When a write operation is enqueued, any already-pending read operations will be allowed to finish. Once the write lock can be acquired, the function passed to `enqueueWrite()` will be executed.

Under the hood, writes are submitted as asynchronous barrier operations to the receiver's GCD queue, ensuring that reads are always consistent with the order of writes.

## ThreadLocalValue

`ThreadLocalValue` provides a mechanism for accessing thread-local values stored in the `threadDictionary` of the calling `NSThread`.

This implementation provides three main advantages over using the
`threadDictionary` directly:

- **Type-safety** — `ThreadLocalValue` is implemented as a Swift generic, allowing it to enforce type safety.

- **Namespacing to avoid key clashes** — To prevent clashes between different code modules using thread-local storage, `ThreadLocalValue`s can be instantiated with a `namespace` used to construct the underlying `threadDictionary` key.

- **Use thread-local storage as a lockless cache** — `ThreadLocalValue`s can be constructed with an optional `instantiator` that is used to construct values when the underlying `threadDictionary` doesn't have a value for the given key.

### Namespacing

Namespacing can prevent key clashes when multiple subsystems need to share thread-local storage.

For example, two different subsystems may wish to store an `NSDateFormatter` instance in thread-local storage. If they were each to store their `NSDateFormatter`s using the key "`dateFormatter`", for example, there would be a clash. The first value set for the "`dateFormatter`" key would always be overwritten by the second value set for that key.

Constructing your `ThreadLocalValue` with a `namespace` can prevent that:

```swift
let loggerDateFormatter = ThreadLocalValue<NSDateFormatter>(namespace: "Logger", key: "dateFormatter")

let saleDateFormatter = ThreadLocalValue<NSDateFormatter>(namespace: "SaleViewModel", key: "dateFormatter")
```

When a namespace is used, the `ThreadLocalValue` implementation constructs a value for its `fullKey` property by concatenating the values passed to the `namespace` and `key` parameters in the format "*namespace*.*key*".

In the example above, the `loggerDateFormatter` uses the `fullKey` "`Logger.dateFormatter`" while the `saleDateFormatter` uses "`SaleViewModel.dateFormatter`".

Because only the `fullKey` is used when accessing the underlying `threadDictionary`, these two `ThreadLocalValue` instances can each be used independently without their underlying values conflicting.

> Regardless of whether a `ThreadLocalValue` uses a namespace, the key used to access the `threadDictionary` is always available via the `fullKey` property.

### Thread-local caching

`ThreadLocalValue` instances can also be used to treat thread-local storage as a lockless cache.

Objects that are expensive to create, such as `NSDateFormatter` instances, can be cached in thread-local storage without incurring the locking overhead that would be required by an object cache shared among multiple threads.

This capability is available to `ThreadLocalValue`s created with an `instantiator` function, and it works as follows:

- If the `value()` function is called when the underlying `threadDictionary` doesn't have a value associated with the receiver's `fullKey`, the `instantiator` will be invoked to create a value.

- If the `instantiator` returns a non-`nil` value, this value will be stored in the `threadDictionary` of the calling thread using the key `fullKey` of the `ThreadLocalValue` instance.

- Future calls to the `ThreadLocalValue`'s `value()` or `cachedValue()` functions will return the value created by the `instantiator` until the underlying value is changed.

Using a `ThreadLocalValue` instance to cache an `NSDateFormatter` would look like:

```swift
let df = ThreadLocalValue<NSDateFormatter>(namespace: "Events", key: "dateFormatter") { _ in
	let fmt = NSDateFormatter()
	fmt.locale = NSLocale(localeIdentifier: "en_US")
	fmt.timeZone = NSTimeZone(forSecondsFromGMT: 0)
	fmt.dateFormat = "yyyyMMdd_HHmmss"
	return fmt
}
```

In the example above, `df` is constructed with an `instantiator` closure. If `df.value()` is called when there is no `NSDateFormatter` associated with the key "`Events.dateFormatter`" in the calling thread's `theadDictionary`, the `instantiator` will be invoked to create a new `NSDateFormatter`.

Using thread-local storage as a cheap cache is best suited for cases where the long-term expense of acquiring read locks every time the object is accessed is greater than the expense of creating a new instance multiplied by the number of unique threads that will access the value.
