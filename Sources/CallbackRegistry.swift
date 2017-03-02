//
//  CallbackRegistry.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/21/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Represents a callback function that has been registered for a given operation.
 
 The callback function may be called as long as the associated `CallbackHandle`
 instance has at least one strong reference to it. Once a `CallbackHandle`
 has been deallocated or its `stopCallbacks()` function is called, the 
 associated callback function will no longer be invoked.
 */
public class CallbackHandle
{
    internal var objectID: ObjectIdentifier {
        return _objectID
    }
    private var _objectID: ObjectIdentifier!

    private weak var removableFrom: CallbackRemovable?

    fileprivate init(removableFrom: CallbackRemovable)
    {
        self.removableFrom = removableFrom
        _objectID = ObjectIdentifier(self)
    }

    deinit {
        stopCallbacks()
    }

    /**
     Prevent further invocations of the callback function represented by the
     receiver.
     */
    public func stopCallbacks()
    {
        removableFrom?.removeCallback(handle: self)
        removableFrom = nil
    }
}

private protocol CallbackRemovable: class
{
    func removeCallback(handle: CallbackHandle)
}

internal class CallbackRegistry<CallbackSignature>: CallbackRemovable
{
    private let lock = NSLock()
    private var objectIdsToCallbacks = [ObjectIdentifier: CallbackSignature]()

    func addCallback(_ callback: CallbackSignature)
        -> CallbackHandle
    {
        let handle = CallbackHandle(removableFrom: self)
        lock.lock()
        objectIdsToCallbacks[handle.objectID] = callback
        lock.unlock()
        return handle
    }

    func removeCallback(handle: CallbackHandle)
    {
        let id = handle.objectID
        lock.lock()
        objectIdsToCallbacks.removeValue(forKey: id)
        lock.unlock()
    }

    func callbacks()
        -> [CallbackSignature]
    {
        lock.lock()
        let callbacks = objectIdsToCallbacks.values
        lock.unlock()
        return [CallbackSignature](callbacks)
    }
}
