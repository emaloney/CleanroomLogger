//
//  ApplicationSettingsProvider.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/29/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Entities conforming to this protocol are capable of providing values for
*application settings*. Application settings are global values available to
the application at runtime. Settings values should persist across application 
launches, and should be available locally on the device running the application.
Storage for application settings is typically provided by the operating system
and may be transparently synchronized across multiple devices depending on the
underlying implementation. The `DefaultApplicationSettingsProvider` class 
provides the default implementation of this protocol. Consider using an instance
of the class `ApplicationSettingsReader` for reading values from an
`ApplicationSettingsProvider` instance.
*/
public protocol ApplicationSettingsProvider
{
    /**
    Returns the names of the application settings for which values currently
    exist.
    
    :returns:   The application settings names
    */
    func settingNames()
        -> [String]

    /**
    Returns the value of the setting with the specified name.
    
    :param:     name The setting name

    :returns:   The value of the setting, or `nil` if none exists
    */
    func valueOfSetting(name: String)
        -> NSObject?
}
