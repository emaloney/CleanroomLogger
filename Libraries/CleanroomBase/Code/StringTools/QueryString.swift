//
//  QueryString.swift
//  Cleanroom
//
//  Created by Evan Maloney on 12/22/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
The `QueryString` protocol is adopted by entities capable of providing 
information about the contents of a query string. The default implementation
of this protocol is `QueryStringImpl`.
*/
public protocol QueryString
{
    /**
    Returns the query string itself.
    */
    var queryString: String { get }

    /**
    Returns the number of values in existence for the given query string
    parameter.
    
    :param:     name The name of the query string parameter whose count of
                values is sought
    
    :returns:   The number of values in the query string with the name `name`
    */
    func countValuesForName(name: String)
        -> Int

    /**
    Returns the first value for the query string parameter with the given name.

    :param:     name The name of the query string parameter whose first value 
                is sought

    :returns:   The first value in the query string with the name `name`, or 
                `nil` if there were no values with the specified name
    */
    func firstValueForName(name: String)
        -> String?

    /**
    Returns all values associated with the given query string parameter name.
    
    :param:     name The name of the query string parameter whose values are
                sought
    
    :returns:   All values in the query string with the name `name`, or `nil`
                if there were no values with the specified name
    */
    func allValuesForName(name: String)
        -> [String]?
}

/**
A default implementation of the `QueryString` protocol that relies on the
`NSURLComponents` class for parsing the underlying query string.
*/
public struct QueryStringImpl: QueryString
{
    /**
    Returns the query string itself.
    */
    public let queryString: String

    private let firstValues: [String: String]
    private let allValues: [String: [String]]

    /**
    Attempts to initialize a new `QueryStringImpl` instance using the specified
    URL.
    
    :param:     url The URL whose query string will be parsed
    
    :returns:   `nil` if initialization fails
    */
    public init?(url: NSURL)
    {
        if let urlString = url.absoluteString {
            self.init(urlString: urlString)
        }
        else {
            return nil
        }
    }

    /**
    Attempts to initialize a new `QueryStringImpl` instance using the specified
    URL.

    :param:     urlString A string containing a URL whose query string will be
                parsed.

    :returns:   `nil` if initialization fails, such as if `urlString` contains
                no query string.
    */
    public init?(urlString: String)
    {
        if let comps = NSURLComponents(string: urlString) {
            if let queryString = comps.query {
                self.queryString = queryString
            } else {
                return nil
            }
            if let items = comps.queryItems {
                if items.count > 0 {
                    var firstValues = [String: String]()
                    var allValues = [String: [String]]()
                    for item in items {
                        if let queryItem = item as? NSURLQueryItem {
                            let name = queryItem.name
                            let value = (queryItem.value != nil ? queryItem.value! : "")
                            if firstValues[name] == nil {
                                firstValues[name] = value
                            }
                            if allValues[name] == nil {
                                allValues[name] = [value]
                            } else {
                                allValues[name]! += [value]
                            }
                        }
                    }
                    self.firstValues = firstValues
                    self.allValues = allValues
                    return
                }
            }
        }
        return nil
    }

    /**
    Returns the first value for the query string parameter with the given name.

    :param:     name The name of the query string parameter whose first value
                is sought

    :returns:   The first value in the query string with the name `name`, or
                `nil` if there were no values with the specified name
    */
    public func firstValueForName(name: String)
        -> String?
    {
        return firstValues[name]
    }

    /**
    Returns all values associated with the given query string parameter name.

    :param:     name The name of the query string parameter whose values are 
                sought

    :returns:   All values in the query string with the name `name`, or `nil`
                if there were no values with the specified name
    */
    public func allValuesForName(name: String)
        -> [String]?
    {
        return allValues[name]
    }

    /**
    Returns the number of values in existence for the given query string
    parameter.

    :param:     name The name of the query string parameter whose count of 
                values is sought

    :returns:   The number of values in the query string with the name `name`
    */
    public func countValuesForName(name: String)
        -> Int
    {
        var count = 0
        if let values = allValuesForName(name) {
            count = values.count
        }
        return count
    }
}