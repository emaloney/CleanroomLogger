//
//  LiveLogInspectorViewController.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/18/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

/**
 The `LiveLogInspectorViewController` provides a live view of the `LogEntry` 
 messages recorded by a `BufferedLogEntryMessageRecorder`.
 
 Typically, you would not construct a `LiveLogInspectorViewController`
 directly; instead, you would add a `LiveLogInspectorConfiguration` to your
 CleanroomLogger configuration and use its `inspectorViewController`
 property to acquire a `LiveLogInspectorViewController` instance.
 */
open class LiveLogInspectorViewController: UIViewController
{
    /** Returns the `LiveLogInspectorView` maintained by the receiver. If the
     view controller has not yet loaded its view, calling this will force the
     view to be loaded. */
    open var inspectorView: LiveLogInspectorView {
        return view as! LiveLogInspectorView
    }

    private let recorder: BufferedLogEntryMessageRecorder

    /**
     Constructs a new `LiveLogInspectorViewController` that will show a live
     display of each `LogEntry` recorded by the passed-in
     `BufferedLogEntryMessageRecorder`.
     
     - parameter recorder: The `BufferedLogEntryMessageRecorder` whose 
     content should be displayed by the view controller.
     */
    public init(recorder: BufferedLogEntryMessageRecorder)
    {
        self.recorder = recorder

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
    }

    /**
     Not supported. Results in a fatal error when called.
     
     - parameter coder: Ignored.
     */
    public required init?(coder: NSCoder) { fatalError() }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    open override func loadView()
    {
        let logView = LiveLogInspectorView(recorder: recorder)
        logView.closeButtonTriggered = { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        view = logView
    }

    open override func viewWillLayoutSubviews()
    {
        inspectorView.statusBarHeight = topLayoutGuide.length

        super.viewWillLayoutSubviews()
    }
}

#endif
