//
//  ApplicationSettingsTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation
import XCTest
import CleanroomBase

class ApplicationSettingsTests: XCTestCase
{
    func setupWriter(writer: ApplicationSettingsWriter)
    {
        // for general testing
        writer.setValue("foo:bar", forSetting: "foobar")
        writer.setBool(true, forSetting: "trueValue")
        writer.setBool(false, forSetting: "falseValue")
        writer.setInt(0, forSetting: "zeroInt")
        writer.setInt(1972, forSetting: "year")
        writer.setDouble(9.8, forSetting: "acceleration")
        writer.setDouble(0, forSetting: "zeroDouble")
        writer.setString("there are many like it but this one is mine", forSetting: "this is my string")
        writer.setArray([], forSetting: "emptyArray")
        writer.setArray([2, 4, 6, 8, 10], forSetting: "evenArray")
        writer.setDictionary([:], forSetting: "emptyDict")
        writer.setDictionary(["1": "one", "2": "two", "3": "three"], forSetting: "threeOrdinals")

        // for testing of simple type conversion
        writer.setString("26.2", forSetting: "marathon")
        writer.setValue("27", forSetting: "twentySeven")
        writer.setString("0", forSetting: "boolFalse")
        writer.setValue("1", forSetting: "boolTrue")
    }

    func verifyMutableDictionaryApplicationSettingsStorage(storage: MutableDictionaryApplicationSettingsStorage)
    {
        // verify that values written "for general testing" exist
        XCTAssertNotNil(storage.dictionary.objectForKey("foobar"))
        XCTAssertNotNil(storage.dictionary.objectForKey("trueValue"))
        XCTAssertNotNil(storage.dictionary.objectForKey("falseValue"))
        XCTAssertNotNil(storage.dictionary.objectForKey("zeroInt"))
        XCTAssertNotNil(storage.dictionary.objectForKey("year"))
        XCTAssertNotNil(storage.dictionary.objectForKey("acceleration"))
        XCTAssertNotNil(storage.dictionary.objectForKey("zeroDouble"))
        XCTAssertNotNil(storage.dictionary.objectForKey("this is my string"))
        XCTAssertNotNil(storage.dictionary.objectForKey("emptyArray"))
        XCTAssertNotNil(storage.dictionary.objectForKey("evenArray"))
        XCTAssertNotNil(storage.dictionary.objectForKey("emptyDict"))
        XCTAssertNotNil(storage.dictionary.objectForKey("threeOrdinals"))
    }

    func testRemoveValue(writer: ApplicationSettingsWriter, usingReader reader: ApplicationSettingsReader)
    {
        // test removing a value
        writer.setBool(true, forSetting: "notRemoved")
        XCTAssertNotNil(reader.valueOfSetting("notRemoved"))
        writer.removeValueForSetting("notRemoved")
        XCTAssertNil(reader.valueOfSetting("notRemoved"))
    }

    func testRemoveValue(writer: ApplicationSettingsWriter)
    {
        // test reading directly from the writer
        testRemoveValue(writer, usingReader: writer)

        // test reading indirectly
        testRemoveValue(writer, usingReader: ApplicationSettingsReader(provider: writer))
    }

    func testReading(reader: ApplicationSettingsReader)
    {
        // make sure values exist
        XCTAssertNotNil(reader.valueOfSetting("foobar"))
        XCTAssertNotNil(reader.boolValueOfSetting("trueValue"))
        XCTAssertNotNil(reader.boolValueOfSetting("falseValue"))
        XCTAssertNotNil(reader.intValueOfSetting("zeroInt"))
        XCTAssertNotNil(reader.intValueOfSetting("year"))
        XCTAssertNotNil(reader.doubleValueOfSetting("acceleration"))
        XCTAssertNotNil(reader.doubleValueOfSetting("zeroDouble"))
        XCTAssertNotNil(reader.stringValueOfSetting("this is my string"))
        XCTAssertNotNil(reader.arrayValueOfSetting("emptyArray"))
        XCTAssertNotNil(reader.arrayValueOfSetting("evenArray"))
        XCTAssertNotNil(reader.dictionaryValueOfSetting("emptyDict"))
        XCTAssertNotNil(reader.dictionaryValueOfSetting("threeOrdinals"))

        // test values
        XCTAssertEqual(reader.valueOfSetting("foobar")!, "foo:bar")
        XCTAssertEqual(reader.boolValueOfSetting("trueValue")!, true)
        XCTAssertEqual(reader.boolValueOfSetting("falseValue")!, false)
        XCTAssertEqual(reader.intValueOfSetting("zeroInt")!, 0)
        XCTAssertEqual(reader.intValueOfSetting("year")!, 1972)
        XCTAssertEqual(reader.doubleValueOfSetting("acceleration")!, 9.8)
        XCTAssertEqual(reader.doubleValueOfSetting("zeroDouble")!, 0.0)
        XCTAssertEqual(reader.stringValueOfSetting("this is my string")!, "there are many like it but this one is mine")
        XCTAssertEqual(reader.arrayValueOfSetting("emptyArray")!, [])
        XCTAssertEqual(reader.arrayValueOfSetting("evenArray")!, [2, 4, 6, 8, 10])
        XCTAssertEqual(reader.dictionaryValueOfSetting("emptyDict")!, [:])
        XCTAssertEqual(reader.dictionaryValueOfSetting("threeOrdinals")!, ["1": "one", "2": "two", "3": "three"])

        // test expected nil returns for nonexistent keys
        XCTAssertNil(reader.valueOfSetting("nonexistent"))
        XCTAssertNil(reader.boolValueOfSetting("nonexistent"))
        XCTAssertNil(reader.intValueOfSetting("nonexistent"))
        XCTAssertNil(reader.doubleValueOfSetting("nonexistent"))
        XCTAssertNil(reader.stringValueOfSetting("nonexistent"))
        XCTAssertNil(reader.arrayValueOfSetting("nonexistent"))
        XCTAssertNil(reader.dictionaryValueOfSetting("nonexistent"))

        // test default values for nonexistent keys
        XCTAssertNotNil(reader.valueOfSetting("nonexistent", withDefault: "foo"))
        XCTAssertEqual(reader.valueOfSetting("nonexistent", withDefault: "foo"), "foo")
        XCTAssertNotNil(reader.boolValueOfSetting("nonexistent", withDefault: true))
        XCTAssertEqual(reader.boolValueOfSetting("nonexistent", withDefault: true), true)
        XCTAssertNotNil(reader.intValueOfSetting("nonexistent", withDefault: 42))
        XCTAssertEqual(reader.intValueOfSetting("nonexistent", withDefault: 42), 42)
        XCTAssertNotNil(reader.doubleValueOfSetting("nonexistent", withDefault: 1027.1972))
        XCTAssertEqual(reader.doubleValueOfSetting("nonexistent", withDefault: 1027.1972), 1027.1972)
        XCTAssertNotNil(reader.stringValueOfSetting("nonexistent", withDefault: "foo/bar"))
        XCTAssertEqual(reader.stringValueOfSetting("nonexistent", withDefault: "foo/bar"), "foo/bar")
        XCTAssertNotNil(reader.arrayValueOfSetting("nonexistent", withDefault: [1, 3, 5, 7, 9]))
        XCTAssertEqual(reader.arrayValueOfSetting("nonexistent", withDefault: [1, 3, 5, 7, 9]), [1, 3, 5, 7, 9])
        XCTAssertNotNil(reader.dictionaryValueOfSetting("nonexistent", withDefault: [1: 2, "free": "four"]))
        XCTAssertEqual(reader.dictionaryValueOfSetting("nonexistent", withDefault: [1: 2, "free": "four"]), [1: 2, "free": "four"])

        // test default values for existing keys
        XCTAssertNotEqual(reader.valueOfSetting("foobar", withDefault: "boo:far"), "boo:far")
        XCTAssertNotEqual(reader.boolValueOfSetting("trueValue", withDefault: false), false)
        XCTAssertNotEqual(reader.boolValueOfSetting("falseValue", withDefault: true), true)
        XCTAssertNotEqual(reader.intValueOfSetting("zeroInt", withDefault: 1), 1)
        XCTAssertNotEqual(reader.intValueOfSetting("year", withDefault: 2014), 2014)
        XCTAssertNotEqual(reader.doubleValueOfSetting("acceleration", withDefault: 10.0), 10.0)
        XCTAssertNotEqual(reader.doubleValueOfSetting("zeroDouble", withDefault: 22.6), 22.6)
        XCTAssertNotEqual(reader.stringValueOfSetting("this is my string", withDefault: "nothing"), "nothing")
        XCTAssertNotEqual(reader.arrayValueOfSetting("emptyArray", withDefault: [1]), [1])
        XCTAssertNotEqual(reader.arrayValueOfSetting("evenArray", withDefault: [2, 4, 6, 8]), [2, 4, 6, 8])
        XCTAssertNotEqual(reader.dictionaryValueOfSetting("emptyDict", withDefault: ["a": "b"]), ["a": "b"])
        XCTAssertNotEqual(reader.dictionaryValueOfSetting("threeOrdinals", withDefault: [4: "four"]), [4: "four"])

        // test simple type conversion
        XCTAssertEqual(reader.doubleValueOfSetting("marathon")!, 26.2)
        XCTAssertEqual(reader.intValueOfSetting("marathon")!, 26)
        XCTAssertEqual(reader.doubleValueOfSetting("twentySeven")!, 27.0)
        XCTAssertEqual(reader.intValueOfSetting("twentySeven")!, 27)
        XCTAssertEqual(reader.boolValueOfSetting("boolFalse")!, false)
        XCTAssertEqual(reader.boolValueOfSetting("boolTrue")!, true)
    }

    func testApplicationSettingsAPI()
    {
        // write some values
        let storage = MutableDictionaryApplicationSettingsStorage()
        let writer = ApplicationSettingsWriter(storage: storage)
        setupWriter(writer)

        // make sure we can see what was written
        verifyMutableDictionaryApplicationSettingsStorage(storage)

        // test reading back values
        let reader = ApplicationSettingsReader(provider: DictionaryApplicationSettingsProvider(dictionary: storage.mutableDictionary))
        testReading(reader)

        // test removing a value
        testRemoveValue(writer)

        // test removing a value (alternate verification)
        writer.setBool(true, forSetting: "notRemoved2")
        XCTAssertNotNil(storage.dictionary.objectForKey("notRemoved2"))
        writer.removeValueForSetting("notRemoved2")
        XCTAssertNil(storage.dictionary.objectForKey("notRemoved2"))
    }

    func testNSUserDefaultsImplementation()
    {
        // write some values
        let writer = DefaultApplicationSettings()
        setupWriter(writer)

        // test reading back values
        let reader = ApplicationSettingsReader(provider: writer)
        testReading(reader)

        // test removing a value
        testRemoveValue(writer)
    }
}
