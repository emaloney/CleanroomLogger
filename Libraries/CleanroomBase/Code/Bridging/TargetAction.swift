//
//  TargetAction.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/31/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
The `TargetAction` class bridges the gap between Swift closures and the common
Cocoa target (`id`)/action (`SEL`) paradigm. Construct a `TargetAction` with
a no-argument or single-argument callback closure. Then, use the `target` and
`action` properties of the `TargetAction` instance as you would normally 
anywhere Cocoa calls for a target/action.
*/
public class TargetAction
{
    /// The object to use as the *target* of a target/action pair.
    public var target: AnyObject { get { return self } }

    /// The `Selector` to use as the *action* of the target/action pair.
    public var action: Selector {
        get {
            if noArgCallback != nil {
                return Selector("noArgAction")
            } else {
                return Selector("singleArgAction:")
            }
        }
    }

    private let noArgCallback: (() -> Void)?
    private let singleArgCallback: ((AnyObject?) -> Void)?

    /**
    Constructs a `TargetAction` with a no-argument callback.
    
    :param:     callback A callback closure that will be executed when the
                target/action pair represented by the newly-constructed
                instance is invoked.
    */
    public init(callback: () -> Void)
    {
        self.noArgCallback = callback
        self.singleArgCallback = nil
    }

    /**
    Constructs a `TargetAction` with a single-argument callback.

    :param:     callback A callback closure that will be executed when the
                target/action pair represented by the newly-constructed instance
                is invoked. The `AnyObject?` argument passed to `callback`
                will be the argument sent to `action` when invoked.
    */
    public init(callback: (AnyObject?) -> Void)
    {
        self.noArgCallback = nil
        self.singleArgCallback = callback
    }

    @objc private func noArgAction()
    {
        noArgCallback!()
    }

    @objc private func singleArgAction(arg: AnyObject?)
    {
        singleArgCallback!(arg)
    }
}
