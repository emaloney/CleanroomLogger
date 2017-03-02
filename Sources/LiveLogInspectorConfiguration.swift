    //
//  LiveLogInspectorConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/17/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

open class LiveLogInspectorConfiguration: BasicLogConfiguration
{
    private let bufferingRecorder: BufferedLogEntryMessageRecorder

    open var inspectorViewController: LiveLogInspectorViewController {
        let inspector = _inspectorViewController ?? LiveLogInspectorViewController(recorder: bufferingRecorder)
        _inspectorViewController = inspector
        return inspector
    }
    private weak var _inspectorViewController: LiveLogInspectorViewController?

    public init(minimumSeverity: LogSeverity = .verbose, filters: [LogFilter] = [], synchronousMode: Bool = false)
    {
        bufferingRecorder = BufferedLogEntryMessageRecorder(formatters: [PayloadLogFormatter()])

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: [bufferingRecorder], synchronousMode: synchronousMode)
    }

    open func createInspectorView()
        -> LiveLogInspectorView
    {
        return LiveLogInspectorView(recorder: bufferingRecorder)
    }
}

#endif

