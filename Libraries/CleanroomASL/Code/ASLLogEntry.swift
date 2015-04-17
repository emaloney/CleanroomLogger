//
//  ASL.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

/**
Contains the information of an ASL log entry.
*/
public struct ASLLogEntry
{
    let priority: ASLPriorityLevel
    let message: String
    let timestamp: NSDate
}

