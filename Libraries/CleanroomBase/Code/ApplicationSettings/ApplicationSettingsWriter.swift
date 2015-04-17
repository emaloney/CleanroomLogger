//
//  ApplicationSettingsWriter.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Provides functions for reading and writing `ApplicationSettingsStorage` values
in a type-safe way.
*/
public class ApplicationSettingsWriter: ApplicationSettingsReader, ApplicationSettingsStorage
{
    private let storage: ApplicationSettingsStorage

    /**
    Initializes a new instance to use the given `ApplicationSettingsStorage`
    for reading and writing settings values.

    :param: storage The settings storage
    */
    public init(storage: ApplicationSettingsStorage)
    {
        self.storage = storage
        super.init(provider: storage)
    }

    /**
    Sets a new value for the specified setting.

    :param: value The new value for `settingName`

    :param: settingName The name of the setting that will receive `value`
    */
    public func setValue(value: NSObject, forSetting settingName: String)
    {
        storage.setValue(value, forSetting: settingName)
    }

    /**
    Removes the existing value (if any) for the setting with the given name.

    :param: name The name of the setting whose value will be removed
    */
    public func removeValueForSetting(name: String)
    {
        storage.removeValueForSetting(name)
    }

    /**
    Changes the value of the given setting to the specified boolean.

    :param: value The new value for the setting

    :param: settingName The name of the setting whose value is to be changed
    */
    public func setBool(value: Bool, forSetting settingName: String)
    {
        setValue(value as NSNumber, forSetting: settingName)
    }

    /**
    Changes the value of the given setting to the specified integer.

    :param: value The new value for the setting

    :param: settingName The name of the setting whose value is to be changed
    */
    public func setInt(value: Int, forSetting settingName: String)
    {
        setValue(value as NSNumber, forSetting: settingName)
    }

    /**
    Changes the value of the given setting to the specified `Double`.

    :param: value The new value for the setting

    :param: settingName The name of the setting whose value is to be changed
    */
    public func setDouble(value: Double, forSetting settingName: String)
    {
        setValue(value as NSNumber, forSetting: settingName)
    }

    /**
    Changes the value of the given setting to the specified string.

    :param: value The new value for the setting

    :param: settingName The name of the setting whose value is to be changed
    */
    public func setString(value: String, forSetting settingName: String)
    {
        setValue(value as NSString, forSetting: settingName)
    }

    /**
    Changes the value of the given setting to the specified array.

    :param: value The new value for the setting

    :param: settingName The name of the setting whose value is to be changed
    */
    public func setArray(value: NSArray, forSetting settingName: String)
    {
        setValue(value as NSArray, forSetting: settingName)
    }

    /**
    Changes the value of the given setting to the specified dictionary.

    :param: value The new value for the setting
    
    :param: settingName The name of the setting whose value is to be changed
    */
    public func setDictionary(value: NSDictionary, forSetting settingName: String)
    {
        setValue(value as NSDictionary, forSetting: settingName)
    }
}
