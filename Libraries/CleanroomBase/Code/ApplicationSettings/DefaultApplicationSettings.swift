//
//  DefaultApplicationSettings.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
The default implementation of the `ApplicationSettingsProvider` protocol.
Uses `NSUserDefaults` under the hood.
*/
public class DefaultApplicationSettingsProvider: ApplicationSettingsProvider
{
    /** The `NSUserDefaults` instance used by the receiver. */
    public let userDefaults: NSUserDefaults

    /**
    Initializes a new instance using `NSUserDefaults.standardUserDefaults()`
    as the backing store.
    */
    init()
    {
        self.userDefaults = NSUserDefaults.standardUserDefaults()
    }

    /**
    Initializes a new instance using the specified `NSUserDefaults` object as
    the backing store.
    
    :param:     userDefaults The `NSUserDefaults` instance
    */
    init(userDefaults: NSUserDefaults)
    {
        self.userDefaults = userDefaults
    }

    /**
    Returns the names of the application settings for which values currently
    exist.

    :returns:   The application settings names
    */
    public func settingNames()
        -> [String]
    {
        return userDefaults.dictionaryRepresentation().keys.array.map({$0.description})
    }

    /**
    Returns the value of the setting with the specified name.
    
    :param:     name The setting name

    :returns:   The value of the setting, or `nil` if none exists
    */
    public func valueOfSetting(name: String)
        -> NSObject?
    {
        if let val = userDefaults.objectForKey(name) as? NSObject {
            return val
        }
        return nil
    }
}

/**
The default implementation of the `ApplicationSettingsStorage` protocol.
Uses `NSUserDefaults` under the hood.
*/
public class DefaultApplicationSettingsStorage: DefaultApplicationSettingsProvider, ApplicationSettingsStorage
{
    /**
    Initializes a new instance using `NSUserDefaults.standardUserDefaults()`
    as the backing store.
    */
    public override init()
    {
        super.init()
    }

    /**
    Initializes a new instance using the specified `NSUserDefaults` object as
    the backing store.

    :param:     userDefaults The `NSUserDefaults` instance
    */
    public override init(userDefaults: NSUserDefaults)
    {
        super.init(userDefaults: userDefaults)
    }

    /**
    Sets a new value for the specified setting.

    :param:     value The new value for `settingName`

    :param:     settingName The name of the setting that will receive `value`
    */
    public func setValue(value: NSObject, forSetting settingName: String)
    {
        userDefaults.setObject(value, forKey: settingName)
    }

    /**
    Removes the existing value (if any) for the setting with the given name.

    :param:     name The name of the setting whose value will be removed
    */
    public func removeValueForSetting(name: String)
    {
        userDefaults.removeObjectForKey(name)
    }
}

/**
An implementation of the `ApplicationSettingsWriter` class that uses
`NSUserDefaults` under the hood.
*/
public class DefaultApplicationSettings: ApplicationSettingsWriter
{
    /**
    Initializes a new instance.
    */
    public init()
    {
        super.init(storage: DefaultApplicationSettingsStorage())
    }
}
