//
//  StringTrimExtensionTests.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 4/1/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import XCTest
import CleanroomBase

class StringTrimExtensionTests: XCTestCase
{
    func testTrimFunction()
    {
        XCTAssert("   foo  ==  bar   ".trim() == "foo  ==  bar")
        XCTAssert("foo  ==  bar".trim() == "foo  ==  bar")
        XCTAssert("\n\n\n \t  lines \n    \t \t \n ".trim() == "lines")
    }
}
