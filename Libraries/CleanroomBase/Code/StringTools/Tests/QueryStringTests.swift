//
//  QueryStringTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/22/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation
import XCTest
import CleanroomBase

class QueryStringTests: XCTestCase
{
    let testURL1 = "gilt://sale/women?launchApp=com.apple.Safari&loginWallSaleID=500&loginWallSaleID=702&loginWallSaleID=871&flagWithNoValue&otherFlag=true"
    var testQS1: QueryString!

    override func setUp()
    {
        super.setUp()

        testQS1 = QueryStringImpl(urlString: testURL1)!
    }

    func testQueryStringProperty(qs: QueryString, urlString: String)
    {
        let comps = NSURLComponents(string: urlString)
        XCTAssertNotNil(comps)
        let queryString = comps!.query
        XCTAssertNotNil(queryString)
        XCTAssertEqual(qs.queryString, queryString!)
    }

    func testQueryStringProperties()
    {
        testQueryStringProperty(testQS1, urlString: testURL1)
    }

    func testQueryStringCountValues()
    {
        XCTAssertEqual(testQS1.countValuesForName("launchApp"), 1)
        XCTAssertEqual(testQS1.countValuesForName("loginWallSaleID"), 3)
        XCTAssertEqual(testQS1.countValuesForName("flagWithNoValue"), 1)
        XCTAssertEqual(testQS1.countValuesForName("otherFlag"), 1)
        XCTAssertEqual(testQS1.countValuesForName("weDontHaveThisValue"), 0)
    }

    func testQueryStringFirstValues()
    {
        let launchApp = testQS1.firstValueForName("launchApp")
        XCTAssertNotNil(launchApp)
        XCTAssertEqual(launchApp!, "com.apple.Safari")

        let loginWallSaleID = testQS1.firstValueForName("loginWallSaleID")
        XCTAssertNotNil(loginWallSaleID)
        XCTAssertEqual(loginWallSaleID!, "500")

        let flagWithNoValue = testQS1.firstValueForName("flagWithNoValue")
        XCTAssertNotNil(flagWithNoValue)
        XCTAssertEqual(flagWithNoValue!, "")

        let otherFlag = testQS1.firstValueForName("otherFlag")
        XCTAssertNotNil(otherFlag)
        XCTAssertEqual(otherFlag!, "true")

        let weDontHaveThisValue = testQS1.firstValueForName("weDontHaveThisValue")
        XCTAssertNil(weDontHaveThisValue)
    }

    func testQueryStringAllValues()
    {
        let launchApp = testQS1.allValuesForName("launchApp")
        XCTAssertNotNil(launchApp)
        XCTAssertEqual(launchApp!, ["com.apple.Safari"])

        let loginWallSaleID = testQS1.allValuesForName("loginWallSaleID")
        XCTAssertNotNil(loginWallSaleID)
        XCTAssertEqual(loginWallSaleID!, ["500", "702", "871"])

        let flagWithNoValue = testQS1.allValuesForName("flagWithNoValue")
        XCTAssertNotNil(flagWithNoValue)
        XCTAssertEqual(flagWithNoValue!, [""])

        let otherFlag = testQS1.allValuesForName("otherFlag")
        XCTAssertNotNil(otherFlag)
        XCTAssertEqual(otherFlag!, ["true"])

        let weDontHaveThisValue = testQS1.allValuesForName("weDontHaveThisValue")
        XCTAssertNil(weDontHaveThisValue)
    }

}
