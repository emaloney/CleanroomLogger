//
//  PrintableEnum.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

/**
Declares hooks used to construct printable forms of an `enum`'s value. To
simplify implementation of the inherited `Printable` protocol's `description`
property, use the `EnumPrinter`'s `description()` function.
*/
public protocol PrintableEnum: Printable
{
    /**
    Returns a printable form of the `enum`'s name.
    */
    var printableEnumName: String { get }

    /**
    Returns a printable form of the `enum`'s current value, without any
    associated values.
    */
    var printableValueName: String { get }
}

/**
A `PrintableEnum` designed for `enum`s with associated values.
*/
public protocol PrintableAssociatedValueEnum: PrintableEnum
{
    /**
    Returns a printable form of the `enum` value's associated values, or `nil`
    if there are no associated values.
    */
    var printableAssociatedValues: String { get }
}

/**
Extends the `PrintableEnum` protocol by adding conformance to `DebugPrintable`.
To simplify implementation of the inherited `DebugPrintable` protocol's 
`debugDescription` property, use the `EnumPrinter`'s 
`debugDescription()` function.
*/
public protocol DebugPrintableEnum: PrintableEnum, DebugPrintable
{
}

/**
Simplifies the construction of `description` and `debugDescription` properties
for `PrintableEnum` and `DebugPrintableEnum` implementors.
*/
public struct EnumPrinter
{
    /**
    Returns a string suitable for the `description` property of the specified
    `PrintableEnum`.

    :param: printEnum The `PrintableEnum` instance for which the description is desired.

    :returns: The description string
    */
    public static func description(printEnum: PrintableEnum) -> String
    {
        return printEnum.printableValueName
    }

    /**
    Returns a string suitable for the `description` property of the specified
    `PrintableEnum`.

    :param: printEnum The `PrintableEnum` instance for which the description is desired.

    :returns: The description string
    */
    public static func description(printEnum: PrintableAssociatedValueEnum) -> String
    {
        return "\(printEnum.printableValueName)(\(printEnum.printableAssociatedValues))"
    }

    /**
    Returns a string suitable for the `debugDescription` property of the 
    specified `PrintableEnum`.
    
    :param: printEnum The `PrintableEnum` instance for which the debug description is desired.
    
    :returns: The debug description string
    */
    public static func debugDescription(printEnum: PrintableEnum) -> String
    {
        return "\(printEnum.printableEnumName).\(self.description(printEnum))"
    }
}