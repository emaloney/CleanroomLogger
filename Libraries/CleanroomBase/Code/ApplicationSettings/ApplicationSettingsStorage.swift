//
//  ApplicationSettingsStorage.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
This protocol extends `ApplicationSettingsProvider` by adding the ability
to store and remove values. The `DefaultApplicationSettingsStorage` class
provides the default implementation of this protocol. Consider using an
instance of the class `ApplicationSettingsWriter` for writing values to
an `ApplicationSettingsStorage` instance.
*/
public protocol ApplicationSettingsStorage: ApplicationSettingsProvider
{
    /**
    Sets a new value for the specified setting.
    
    :param:     value The new value for `settingName`
    
    :param:     settingName The name of the setting that will receive `value`
    */
    func setValue(value: NSObject, forSetting settingName: String)

    /**
    Removes the existing value (if any) for the setting with the given name.
    
    :param:     name The name of the setting whose value will be removed
    */
    func removeValueForSetting(name: String)
}
