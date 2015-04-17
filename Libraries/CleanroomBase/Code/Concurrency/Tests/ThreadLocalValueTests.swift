//
//  ThreadLocalValueTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/25/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import XCTest
import CleanroomBase

class ThreadLocalValueTests: XCTestCase
{
//    class TestThread: NSThread
//    {
//        let lock: ReadWriteCoordinator
//        let signal: NSCondition
//
//        init(lock: ReadWriteCoordinator, signal: NSCondition)
//        {
//            self.lock = lock
//            self.signal = signal
//        }
//
//        override func main()
//        {
//            lock.enqueueWrite {
//                var curVal = counter
//                curVal++
//                counter = curVal
//            }
//
//            signal.lock()
//            remainingThreads--
//            signal.signal()
//            signal.unlock()
//        }
//    }
//
//    func testThreadLocalValue()
//    {
//        let NumberOfThreads = 100
//
//        let lock = ReadWriteCoordinator()
//        let signal = NSCondition()
//
//        remainingThreads = NumberOfThreads
//        for _ in 0..<NumberOfThreads {
//            TestThread(lock: lock, signal: signal).start()
//        }
//
//        signal.lock()
//        while remainingThreads > 0 {
//            signal.wait()
//
//            var curVal: Int?
//            lock.read {
//                curVal = counter
//            }
//
//            XCTAssert(remainingThreads == NumberOfThreads - counter)
//
//        }
//        signal.unlock()
//        
//        XCTAssert(counter == NumberOfThreads)
//    }

    func testNamespacing()
    {
        let tlv1 = ThreadLocalValue<NSString>(namespace: "namespace", key: "key")
        XCTAssertTrue(tlv1.fullKey.hasPrefix("namespace"))
        XCTAssertTrue(tlv1.fullKey.hasSuffix("key"))

        let tlv2 = ThreadLocalValue<NSString>(namespace: "space2", key: "key")
        XCTAssertTrue(tlv2.fullKey.hasPrefix("space2"))
        XCTAssertTrue(tlv2.fullKey.hasSuffix("key"))

        tlv1.setValue("tlv1 value")
        tlv2.setValue("tlv2 value")

        XCTAssertTrue(tlv1.value() == "tlv1 value")
        XCTAssertTrue(tlv2.value() == "tlv2 value")
    }

    func testValueStorage()
    {
        let tlv1 = ThreadLocalValue<NSString>(key: "key")
        XCTAssertTrue(tlv1.fullKey == "key")

        let tlv2 = ThreadLocalValue<NSString>(key: "key")
        XCTAssertTrue(tlv2.fullKey == "key")

        tlv1.setValue("foo")

        XCTAssertTrue(tlv2.cachedValue() == "foo")
    }

    func testInstantiator()
    {
        let NumberOfThreads = 100

        class TestThread: NSThread
        {
            let resultStorage: NSMutableDictionary
            let signal: NSCondition

            init(threadNumber: Int, resultStorage: NSMutableDictionary, signal: NSCondition)
            {
                self.resultStorage = resultStorage
                self.signal = signal
                super.init()
                self.name = "Test thread \(threadNumber)"
            }

            override func main()
            {
                let tlv = ThreadLocalValue<NSString>(key: "threadName") { _ in
                    return NSThread.currentThread().name
                }

                var result = false
                let threadName = NSThread.currentThread().name
                if let value = tlv.value() as? String {
                    result = value == threadName
                }

                self.signal.lock()
                self.resultStorage[threadName] = NSNumber(bool: result)
                self.signal.signal()
                self.signal.unlock()
            }
        }

        let results = NSMutableDictionary()
        let signal = NSCondition()

        for i in 0..<NumberOfThreads {
            TestThread(threadNumber: i, resultStorage: results, signal: signal).start()
        }

        signal.lock()
        while results.count < NumberOfThreads {
            signal.wait()
        }
        signal.unlock()

        for (key, value) in results {
            if let result = (value as? NSNumber)?.boolValue {
                XCTAssertTrue(result, "Test failed for thread \(key)")
            }
        }
    }

    func testValueRetrievalVariations()
    {
        let tlv = ThreadLocalValue<NSString>(key: "lazy") { _ in
            return "I'm not taciturn, I'm just laconic."
        }

        XCTAssertTrue(NSThread.currentThread().threadDictionary["lazy"] == nil)
        XCTAssertTrue(tlv.cachedValue() == nil)
        XCTAssertTrue(tlv.value() == "I'm not taciturn, I'm just laconic.")
        XCTAssertTrue(tlv.cachedValue() == "I'm not taciturn, I'm just laconic.")
        XCTAssertTrue(NSThread.currentThread().threadDictionary["lazy"] as? String == "I'm not taciturn, I'm just laconic.")
    }
}
