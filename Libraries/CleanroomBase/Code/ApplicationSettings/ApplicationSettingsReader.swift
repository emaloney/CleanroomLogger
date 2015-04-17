//
//  ApplicationSettingsReader.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Provides functions for reading values from an `ApplicationSettingsProvider`
instance in a type-safe way.
*/
public class ApplicationSettingsReader: ApplicationSettingsProvider
{
    private let provider: ApplicationSettingsProvider

    /**
    Initializes a new instance to read settings values from the
    specified `ApplicationSettingsProvider`.

    :param:     provider The settings provider
    */
    public init(provider: ApplicationSettingsProvider)
    {
        self.provider = provider
    }

    /**
    Returns the names of the application settings for which values currently
    exist.

    :returns:   The application settings names
    */
    public func settingNames()
        -> [String]
    {
        return provider.settingNames()
    }

    /**
    Returns the value of the setting with the specified name.

    :param:     name The setting name

    :returns:   The value of the setting, or `nil` if none exists.
    */
    public func valueOfSetting(name: String)
        -> NSObject?
    {
        return provider.valueOfSetting(name)
    }

    /**
    Returns the value of the setting with the specified name.

    :param:     name The setting name
    
    :param:     defaultValue A default value to use in case there is no existing
                value for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting.
    */
    public func valueOfSetting(name: String, withDefault defaultValue: NSObject)
        -> NSObject
    {
        if let obj = valueOfSetting(name) {
            return obj
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    boolean value.

    :param:     name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as a
                `Bool`.
    */
    public func boolValueOfSetting(name: String)
        -> Bool?
    {
        if let int = intValueOfSetting(name) {
            return int != 0
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    boolean value.

    :param:     name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as a `Bool`.
    */
    public func boolValueOfSetting(name: String, withDefault defaultValue: Bool)
        -> Bool
    {
        if let val = boolValueOfSetting(name) {
            return val
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    numeric value.

    :param:     name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as an
                `NSNumber`.
    */
    public func numericValueOfSetting(name: String)
        -> NSNumber?
    {
        if let val = valueOfSetting(name) as? NSNumber {
            return val
        }
        else if let val = valueOfSetting(name) as? NSString {
            return NSDecimalNumber(string: val as String)
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    numeric value.

    :param: name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as an `NSNumber`.
    */
    public func numericValueOfSetting(name: String, withDefault defaultValue: NSNumber)
        -> NSNumber
    {
        if let val = numericValueOfSetting(name) {
            return val
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as an 
    integer value.

    :param: name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as an
                `Int`.
    */
    public func intValueOfSetting(name: String)
        -> Int?
    {
        if let val = numericValueOfSetting(name) {
            return val.integerValue
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as an 
    integer value.

    :param: name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as an `Int`.
    */
    public func intValueOfSetting(name: String, withDefault defaultValue: Int)
        -> Int
    {
        if let val = intValueOfSetting(name) {
            return val
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    floating-point value.

    :param:     name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as a
                `Double`.
    */
    public func doubleValueOfSetting(name: String)
        -> Double?
    {
        if let val = numericValueOfSetting(name) {
            return val.doubleValue
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    floating-point value.

    :param:     name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as a `Double`.
    */
    public func doubleValueOfSetting(name: String, withDefault defaultValue: Double)
        -> Double
    {
        if let val = doubleValueOfSetting(name) {
            return val
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    string value.

    :param:     name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as a
                `String`.
    */
    public func stringValueOfSetting(name: String)
        -> String?
    {
        if let val = valueOfSetting(name) {
            if let str = val as? String {
                return str
            }
            return val.description
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    string value.

    :param: name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as a `String`.
    */
    public func stringValueOfSetting(name: String, withDefault defaultValue: String)
        -> String
    {
        if let val = stringValueOfSetting(name) {
            return val
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as an 
    array.

    :param:     name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as an
                `NSArray`.
    */
    public func arrayValueOfSetting(name: String)
        -> NSArray?
    {
        if let val = valueOfSetting(name) as? NSArray {
            return val
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as an 
    array.

    :param: name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as an `NSArray`.
    */
    public func arrayValueOfSetting(name: String, withDefault defaultValue: NSArray)
        -> NSArray
    {
        if let val = arrayValueOfSetting(name) {
            return val
        }
        return defaultValue
    }

    /**
    Returns the value of the setting with the specified name, interpreted as a 
    dictionary.

    :param:     name The setting name

    :returns:   The value of the setting. Will be `nil` if there is no value for
                the setting, or if the value couldn't be interpreted as an
                `NSDictionary`.
    */
    public func dictionaryValueOfSetting(name: String)
        -> NSDictionary?
    {
        if let val = valueOfSetting(name) as? NSDictionary {
            return val
        }
        return nil
    }

    /**
    Returns the value of the setting with the specified name, interpreted as 
    a dictionary.

    :param:     name The setting name

    :param:     defaultValue A default value to use in case there is no existing
                value of the correct type for the given setting.

    :returns:   The value of the setting, or `defaultValue` if there is 
                currently no value for the specified setting that can be
                interpreted as an `NSDictionary`.
    */
    public func dictionaryValueOfSetting(name: String, withDefault defaultValue: NSDictionary)
        -> NSDictionary
    {
        if let val = dictionaryValueOfSetting(name) {
            return val
        }
        return defaultValue
    }
}
