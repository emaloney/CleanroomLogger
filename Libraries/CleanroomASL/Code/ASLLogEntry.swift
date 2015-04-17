//
//  ASLLogEntry.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

/**
Contains the information of an ASL log entry.
*/
public struct ASLLogEntry
{
    public let priority: ASLPriorityLevel
    public let message: String
    public let timestamp: NSDate
}

