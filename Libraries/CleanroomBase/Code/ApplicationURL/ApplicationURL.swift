//
//  ApplicationURL.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/22/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
The `ApplicationURL` protocol is adopted by entities that can return 
information about the types of URLs that can be handled by the application.
This information is contained in the `CFBundleURLTypes` structure within
the application's `Info.plist` file. The default implementation for this
protocol is `DefaultApplicationURL`.
*/
public protocol ApplicationURL
{
    /**
    :returns: The URL types supported by the application. Each URL type may
    have zero or more associated URL schemes.
    */
    var urlTypes: [String] { get }

    /**
    :returns: The URL schemes supported by the application.
    */
    var allSchemes: [String] { get }

    /**
    Returns the URL schemes associated with the given URL type.

    :param: type The URL type.

    :returns: An array of URL schemes. Note that because an application can support multiple URL types, this may not be an exhaustive list of URL schemes supported by the application.
    */
    func schemesForURLType(type: String)
        -> [String]?
}

/**
The `DefaultApplicationURL` struct provides a default implementation of the
`ApplicationURL` protocol, using values from the `CFBundleURLTypes` property
in the main bundle's `Info.plist`.
*/
public struct DefaultApplicationURL: ApplicationURL
{
    public let urlTypes: [String]
    public let allSchemes: [String]

    let typesToSchemes: [String: [String]]

    /**
    Initializes a new instance that will use the specified `NSBundle` for
    determining the supported application URLs.
    
    :param:     bundle The `NSBundle` to use for determining the URLs.
    */
    public init(bundle: NSBundle)
    {
        var typesArray: [String] = []
        var typesToSchemesMap: [String: [String]] = [:]
        var allSchemes: [String] = []

        if let urlTypes = bundle.objectForInfoDictionaryKey("CFBundleURLTypes") as? NSArray {
            for type in urlTypes {
                if let typeDict = type as? NSDictionary {
                    let name: String = typeDict["CFBundleURLName"] as! String
                    let schemes: [String] = typeDict["CFBundleURLSchemes"] as! [String]
                    typesArray += [name]
                    typesToSchemesMap[name] = schemes
                    allSchemes += schemes
                }
            }
        }

        self.urlTypes = typesArray
        self.typesToSchemes = typesToSchemesMap
        self.allSchemes = allSchemes
    }

    /**
    Initializes a new instance that will use the main `NSBundle` for 
    determining the supported application URLs.
    */
    public init()
    {
        self.init(bundle: NSBundle.mainBundle())
    }

    /**
    Returns the URL schemes associated with the given URL type.

    :param: type The URL type.

    :returns: An array of URL schemes. Note that because an application can support multiple URL types, this may not be an exhaustive list of URL schemes supported by the application.
    */
    public func schemesForURLType(type: String)
        -> [String]?
    {
        return typesToSchemes[type]
    }
}