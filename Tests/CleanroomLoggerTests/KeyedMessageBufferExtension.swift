//
//  KeyedMessageBufferExtension.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/17/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import CleanroomLogger

extension BufferedLogEntryMessageRecorder
{
    internal func keyedMessageBuffer()
        -> [String: LogEntry]
    {
        var keyedBuffer = [String: LogEntry]()
        for (log, _) in buffer {
            if case .message(let msg) = log.payload {
                keyedBuffer[msg] = log
            }
        }
        return keyedBuffer
    }
}
