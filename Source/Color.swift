//
//  Color.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/16/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public struct Color
{
    public typealias Component = UInt8

    public private(set) var r: Component
    public private(set) var g: Component
    public private(set) var b: Component

    public init(r: Component, g: Component, b: Component)
    {
        self.r = r
        self.g = g
        self.b = b
    }
}

extension Color
{
    public var colorDeclaration: String {
        return "\(r),\(g),\(b)"
    }

    public var foregroundColorDeclaration: String {
        return "fg\(colorDeclaration)"
    }

    public var backgroundColorDeclaration: String {
        return "bg\(colorDeclaration)"
    }
}
