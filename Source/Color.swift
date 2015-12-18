//
//  Color.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 12/16/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Represents a 3-component RGB color where each component is 8 bits.
 Used for specifying log output colors.
*/
public struct Color
{
    /// A type representing a single color component. A value of `0x00`
    /// represents absense of the color, while `0xFF` indicates color at
    /// full brightness.
    public typealias Component = UInt8

    /// The red component of the color
    public private(set) var r: Component

    /// The green component of the color
    public private(set) var g: Component

    /// The blue component of the color
    public private(set) var b: Component

    /**
    Color initializer.

    - parameter r: The red component

    - parameter g: The green component

    - parameter b: The blue component
    */
    public init(r: Component, g: Component, b: Component)
    {
        self.r = r
        self.g = g
        self.b = b
    }
}
