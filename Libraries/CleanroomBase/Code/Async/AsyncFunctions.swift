//
//  AsyncFunctions.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Asynchronously executes the passed-in function on a concurrent GCD queue.

:param:     fn The function to execute asynchronously.
*/
public func async(fn: () -> Void)
{
    dispatch_async(AsyncQueue.instance.queue) {
        fn()
    }
}

/**
After a specified delay, asynchronously executes the passed-in function on a
concurrent GCD queue.

:param:     delay The number of seconds to wait before executing `fn`
            asynchronously. This is not real-time scheduling, so the function is
            guaranteed to execute after *at least* this amount of time, not 
            after *exactly* this amount of time.

:param:     fn The function to execute asynchronously.
*/
public func async(#delay: NSTimeInterval, fn: () -> Void)
{
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSTimeInterval(NSEC_PER_SEC)))
    dispatch_after(time, AsyncQueue.instance.queue)  {
        fn()
    }
}

/**
Asynchronously executes the passed-in function on a concurrent GCD queue,
treating it as a barrier. Functions submitted to the queue prior to the barrier
are guaranteed to execute before the barrier, while functions submitted after
the barrier are guaranteed to execute after the passed-in function has
executed.

:param:     fn The function to execute asynchronously.
*/
public func asyncBarrier(fn: () -> Void)
{
    dispatch_barrier_async(AsyncQueue.instance.queue)  {
        fn()
    }
}

/**
Asynchronously executes the specified function on the main thread.

:param:     fn The function to execute on the main thread.
*/
public func mainThread(fn: () -> Void)
{
    dispatch_async(dispatch_get_main_queue()) {
        fn()
    }
}

/**
Asynchronously executes the specified function on the main thread.

:param:     delay The number of seconds to wait before executing `fn`
            asynchronously. This is not real-time scheduling, so the function is
            guaranteed to execute after *at least* this amount of time, not 
            after *exactly* this amount of time.

:param:     fn The function to execute on the main thread.
*/
public func mainThread(#delay: NSTimeInterval, fn: () -> Void)
{
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSTimeInterval(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue())  {
        fn()
    }
}

private struct AsyncQueue
{
    static let instance = AsyncQueue()

    let queue: dispatch_queue_t

    init()
    {
        queue = dispatch_queue_create("CleanroomBase.AsyncQueue", DISPATCH_QUEUE_CONCURRENT)
    }
}
