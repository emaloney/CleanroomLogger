//
//  CriticalSectionTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 4/6/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import XCTest
import CleanroomBase

private var counter = 0             // a global value to protect with a ReadWriteCoordinator
private var remainingThreads = 0    // used with an NSCondition signal to keep track of our threads

private let ShortWaitTimeout        = NSTimeInterval(1.0)
private let LongWaitTimeout         = NSTimeInterval(100.0)
private let TestThreadIterations    = 1000

class CriticalSectionTests: XCTestCase
{
    class ExpectedSuccessTestThread: NSThread
    {
        let signal: NSCondition
        let lock: CriticalSection
        let lockTimeout: NSTimeInterval?

        init(signal: NSCondition, lock: CriticalSection, lockTimeout: NSTimeInterval? = nil)
        {
            self.signal = signal
            self.lock = lock
            self.lockTimeout = lockTimeout
        }

        override func main()
        {
            let fn = { () -> Void in

                // this also tests re-entrancy
                let gotLock = self.lock.executeWithTimeout(LongWaitTimeout) {
                    XCTAssertTrue(counter == 0)
                    counter++
                    XCTAssertTrue(counter == 1)
                    counter--
                    XCTAssertTrue(counter == 0)
                }
                XCTAssertTrue(gotLock)

            }

            for _ in 0..<TestThreadIterations {
                if let timeout = lockTimeout {
                    lock.executeWithTimeout(timeout, fn)
                }
                else {
                    lock.execute(fn)
                }
                NSThread.sleepForTimeInterval(0.0)
            }

            signal.lock()
            remainingThreads--
            signal.signal()
            signal.unlock()
        }
    }
    
    func testCriticalSectionExclusivity()
    {
        let NumberOfThreads = 100

        let lock = CriticalSection()
        let signal = NSCondition()

        signal.lock()

        remainingThreads = NumberOfThreads
        for _ in 0..<NumberOfThreads {
            ExpectedSuccessTestThread(signal: signal, lock: lock).start()
        }

        while remainingThreads > 0 {
            signal.waitUntilDate(NSDate().dateByAddingTimeInterval(LongWaitTimeout))
        }
        signal.unlock()

        XCTAssert(counter == 0)
        XCTAssert(remainingThreads == 0)
    }

    class ExpectedTimeoutTestThread: NSThread
    {
        let signal: NSCondition
        let lock: CriticalSection

        init(signal: NSCondition, lock: CriticalSection)
        {
            self.signal = signal
            self.lock = lock
        }

        override func main()
        {
            let gotLock = lock.executeWithTimeout(ShortWaitTimeout) {
                XCTAssertTrue(false, "we weren't expecting to be able to grab this lock")
            }

            XCTAssertFalse(gotLock)

            signal.lock()
            remainingThreads--
            signal.signal()
            signal.unlock()
        }
    }
    
    func testCriticalSectionTimeout()
    {
        let NumberOfThreads = 25

        let lock = CriticalSection()
        let signal = NSCondition()

        lock.execute {
            signal.lock()

            remainingThreads = NumberOfThreads
            for _ in 0..<NumberOfThreads {
                ExpectedTimeoutTestThread(signal: signal, lock: lock).start()
            }

            while remainingThreads > 0 {
                signal.waitUntilDate(NSDate().dateByAddingTimeInterval(LongWaitTimeout))
            }
            signal.unlock()
        }

        XCTAssert(counter == 0)
        XCTAssert(remainingThreads == 0)
    }

    class ExpectedExceptionTestThread: NSThread
    {
        let signal: NSCondition
        let lock: CriticalSection
        let lockTimeout: NSTimeInterval?

        init(signal: NSCondition, lock: CriticalSection, lockTimeout: NSTimeInterval? = nil)
        {
            self.signal = signal
            self.lock = lock
            self.lockTimeout = lockTimeout
        }

        override func main()
        {
            let fn = { () -> Void in

                // this also tests re-entrancy
                let gotLock = self.lock.executeWithTimeout(LongWaitTimeout) {
                    XCTAssertTrue(counter == 0)
                    counter++
                    XCTAssertTrue(counter == 1)
                    counter--
                    XCTAssertTrue(counter == 0)

                    ExceptionTrap.throwExceptionWithName("try to break the locks")
                }
                XCTAssertTrue(gotLock)

            }

            let success = ExceptionTrap.try({
                if let timeout = self.lockTimeout {
                    self.lock.executeWithTimeout(timeout, fn)
                }
                else {
                    self.lock.execute(fn)
                }
            },
            catch: { _ in })

            XCTAssertTrue(!success)

            signal.lock()
            remainingThreads--
            signal.signal()
            signal.unlock()
        }
    }

    func testCriticalSectionExceptionTrapping()
    {
        let NumberOfThreads = 1000

        let lock = CriticalSection()
        let signal = NSCondition()

        signal.lock()

        remainingThreads = NumberOfThreads
        for _ in 0..<NumberOfThreads {
            ExpectedExceptionTestThread(signal: signal, lock: lock).start()
        }

        while remainingThreads > 0 {
            signal.waitUntilDate(NSDate().dateByAddingTimeInterval(LongWaitTimeout))
        }
        signal.unlock()

        XCTAssert(counter == 0)
        XCTAssert(remainingThreads == 0)
    }
}
