//
//  DictionaryApplicationSettings.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 1/2/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
An `ApplicationSettingsProvider`implementation that takes its
values from an `NSDictionary` instance passed to the constructor.
*/
public class DictionaryApplicationSettingsProvider: ApplicationSettingsProvider
{
    /** The dictionary used to construct the receiver. */
    public let dictionary: NSDictionary

    /**
    Initializes a new instance using the specified dictionary.

    :param: 	dictionary The dictionary containing the values to
				use as settings.
    */
    public init(dictionary: NSDictionary)
    {
        self.dictionary = dictionary
    }

    /**
    Returns the names of the settings known to the receiver.

    :returns:	An array of `String`s containing the settings names.
    */
    public func settingNames()
        -> [String]
    {
        return dictionary.allKeys.map({$0 as! String})
    }

    /**
    Returns the value of the setting with the specified name.

    :param:     name The setting name

    :returns:   The value of the setting, or `nil` if none exists.
    */
    public func valueOfSetting(name: String)
        -> NSObject?
    {
        return dictionary[name] as? NSObject
    }
}

/**
An `ApplicationSettingsStorage` implementation that uses as a backing
store the `NSMutableDictionary` instance passed to the constructor.
*/
public class MutableDictionaryApplicationSettingsStorage: DictionaryApplicationSettingsProvider, ApplicationSettingsStorage
{
    /** The mutable dictionary used to construct the receiver. */
    public let mutableDictionary: NSMutableDictionary

    /**
    Initializes a new instance using new, empty `NSMutableDictionary`
    as a backing store.
    */
    public convenience init()
    {
        self.init(mutableDictionary: NSMutableDictionary())
    }

    /**
    Initializes a new instance using the specified `NSMutableDictionary`
    as a backing store.

    :param:     mutableDictionary The mutable dictionary to use as a backing
                store for settings names and values.
    */
    public init(mutableDictionary: NSMutableDictionary)
    {
        self.mutableDictionary = mutableDictionary
        super.init(dictionary: mutableDictionary)
    }

    /**
    Sets a new value for the specified setting.

    :param:     value The new value for `settingName`

    :param:     settingName The name of the setting that will receive `value`
    */
    public func setValue(value: NSObject, forSetting settingName: String)
    {
        mutableDictionary[settingName] = value
    }

    /**
    Removes the existing value (if any) for the setting with the given name.

    :param:     name The name of the setting whose value will be removed
    */
    public func removeValueForSetting(name: String)
    {
        mutableDictionary.removeObjectForKey(name)
    }
}
