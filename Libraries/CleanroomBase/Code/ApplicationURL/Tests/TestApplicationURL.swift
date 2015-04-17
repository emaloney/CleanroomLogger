//
//  TestApplicationURL.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 1/2/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import XCTest
import CleanroomBase

class TestApplicationURL: XCTestCase
{
    func testApplicationURL()
    {
        //
        // NOTE: This test requires the Info.plist file associated with the unit
        //       tests contain the proper declarations for the URL schemes
        //
        let testBundle = NSBundle(forClass: self.dynamicType)
        let appURL: ApplicationURL = DefaultApplicationURL(bundle: testBundle)

        XCTAssert(appURL.urlTypes.count == 3)
        XCTAssert(appURL.allSchemes.count == 4)

        let webSchemes = appURL.schemesForURLType("web")
        XCTAssert(webSchemes != nil)
        XCTAssert(webSchemes! == ["http", "https"])

        let giltSchemes = appURL.schemesForURLType("gilt")
        XCTAssert(giltSchemes != nil)
        XCTAssert(giltSchemes! == ["gilt"])

        let cleanroomSchemes = appURL.schemesForURLType("gilt-cleanroom")
        XCTAssert(cleanroomSchemes != nil)
        XCTAssert(cleanroomSchemes! == ["cleanroom"])
    }
}
