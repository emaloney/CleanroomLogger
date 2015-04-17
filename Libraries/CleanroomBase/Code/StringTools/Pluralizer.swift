//
//  Pluralizer.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 2/26/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
A `Pluralizer` instance represents a *term* that can take multiple *forms*
depending on a *quantity*.
*/
public struct Pluralizer
{
    /** Specifies the form of the term to be used when the quantity is one. */
    public let singular: String

    /** Specifies the form of the term to be used when the quantity is greater
    than one. */
    public let plural: String

    /** Specifies the form of the term to be used when the quantity is zero. 
    If `nil`, the value of the `plural` property will be used when the quantity
    is zero. */
    public let none: String?

    /**
    Initializes a `Pluralizer` instance with the forms of the term it will
    represent.

    Within the strings specified for the various forms, the text "`{#}`" will 
    be replaced with the quantity passed to the `termWithQuantity()` function.

    :param:     singular Specifies the singular form of the term, which is used
                when the applied quantity is one.

    :param:     plural Specifies the plural form of the term, which is used when
                the applied quantity is greater than one.

    :param:     none Specifies the form of the term to be used when the
                applied quantity is zero. This parameter is optional; if 
                this value is not specified or is `nil`, the `plural` form
                will be used when the quantity is zero.
    */
    public init(singular: String, plural: String, none: String? = nil)
    {
        self.plural = plural
        self.singular = singular
        self.none = none
    }

    /**
    Initializes a `Pluralizer` that uses the same form for every quantity.
    
    Within the specified string, the text "`{#}`" will be replaced with the
    quantity passed to the `termWithQuantity()` function.

    :param:     allForms Specifies the value to use for all forms.
    */
    public init(allForms: String)
    {
        self.none = allForms
        self.singular = allForms
        self.plural = allForms
    }

    /**
    Given a quantity, this function returns the correct form of the term
    represented by the receiver.

    :param:     quantity The quantity to apply.
    
    :returns:   The pluralized form approrpriate for `quantity`.
    */
    public func termForQuantity(quantity: Int)
        -> String
    {
        var selectedForm: String!
        switch quantity {
        case 0:     selectedForm = (none ?? plural)
        case 1:     selectedForm = singular
        default:    selectedForm = plural
        }

        return selectedForm.stringByReplacingOccurrencesOfString("{#}", withString: "\(quantity)")
    }
}