//
//  ThreadLocalValue.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/25/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
Provides a mechanism for accessing thread-local values stored in the
`threadDictionary` associated with the `NSThread` of the caller.

As the class name implies, values set using `ThreadLocalValue` are only visible
to the thread that set those values.
*/
public struct ThreadLocalValue<ValueType: AnyObject>
{
    /// If the receiver was instantiated with a `namespace`, this property
    /// will contain that value.
    public let namespace: String?

    /// The `key` that was originally passed to the receiver's constructor.
    /// If the receiver was constructed with a `namespace`, this value
    /// will not include the namespace; `fullKey` will include the namespace.
    public let key: String

    /// Contains the key that will be used to access the underlying
    /// `threadDictionary`. Unless the receiver was constructed with a
    /// `namespace`, this value will be the same as `key`.
    public let fullKey: String

    private let instantiator: ((ThreadLocalValue) -> ValueType?)?

    /**
    Initializes a new instance referencing the thread-local value associated
    with the specified key.
    
    :param:     key The key used to access the value associated with the 
                receiver in the `threadDictionary`.
    
    :param:     instantiator An optional function that will be called to provide
                a value when the underlying `threadDictionary` does not
                contain a value.
    */
    public init(key: String, instantiator: ((ThreadLocalValue) -> ValueType?)? = nil)
    {
        self.namespace = nil
        self.key = key
        self.fullKey = key
        self.instantiator = instantiator
    }

    /**
    Initializes a new instance referencing the thread-local value associated
    with the specified namespace and key.
    
    :param:     namespace The name of the code module that will own the
                receiver. This is used in constructing the `fullKey`.

    :param:     key The key within the namespace. Used to construct the
                `fullKey` associated with the receiver.
    
    :param:     instantiator An optional function that will be called to provide
                a value when the underlying `threadDictionary` does not
                contain a value.
    */
    public init(namespace: String, key: String, instantiator: ((ThreadLocalValue) -> ValueType?)? = nil)
    {
        self.namespace = namespace
        self.key = key
        self.fullKey = "\(namespace).\(key)"
        self.instantiator = instantiator
    }

    /**
    Retrieves the `threadDictionary` value currently associated with the
    receiver's `fullKey`. If there is currently no value for `fullKey` or
    if the underlying value is not of the type specified by `ValueType`,
    the receiver's `instantiator` (if any) will be used to construct a new
    value that will be associated with `fullKey` in the `threadDictionary`
    which will then be returned.

    :returns:   The thread-local value. Will be `nil` if there is no
                value associated with `fullKey`, if the underlying
                value is not of the type specified by `ValueType`, and
                if the receiver has no `instantiator` or if the
                `instantiator` returned `nil`.
    */
    public func value()
        -> ValueType?
    {
        if let value = cachedValue() {
            return value
        }

        if let instantiator = instantiator {
            if let value = instantiator(self) {
                setValue(value)
                return value
            }
        }
        return nil
    }

    /**
    Retrieves the `threadDictionary` value currently associated with the
    receiver's `fullKey`.
    
    :returns:   The thread-local value. Will be `nil` if there is no
                value associated with `fullKey` or if the underlying
                value is not of the type specified by `ValueType`.
    */
    public func cachedValue()
        -> ValueType?
    {
        return NSThread.currentThread().threadDictionary[fullKey] as? ValueType
    }

    /**
    Sets a new value in the calling thread's `threadDictionary` for the key
    specified by the receiver's `fullKey` property.
    
    :param:     newValue The new thread-local value.
    */
    public func setValue(newValue: ValueType?)
    {
        NSThread.currentThread().threadDictionary[fullKey] = newValue
    }
}

