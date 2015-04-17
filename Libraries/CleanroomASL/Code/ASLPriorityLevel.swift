//
//  ASLPriorityLevel.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

/**
Defines the various ASL log priority levels.
*/
public enum ASLPriorityLevel: Int
{
    case Emergency  = 0     // ASL_LEVEL_EMERG
    case Alert      = 1     // ASL_LEVEL_ALERT
    case Critical   = 2     // ASL_LEVEL_CRIT
    case Error      = 3     // ASL_LEVEL_ERR
    case Warning    = 4     // ASL_LEVEL_WARNING
    case Notice     = 5     // ASL_LEVEL_NOTICE
    case Info       = 6     // ASL_LEVEL_INFO
    case Debug      = 7     // ASL_LEVEL_DEBUG

    var priorityString: String {
        get {
            switch self {
            case Emergency: return "Emergency"  // ASL_STRING_EMERG
            case Alert:     return "Alert"      // ASL_STRING_ALERT
            case Critical:  return "Critical"   // ASL_STRING_CRIT
            case Error:     return "Error"      // ASL_STRING_ERR
            case Warning:   return "Warning"    // ASL_STRING_WARNING
            case Notice:    return "Notice"     // ASL_STRING_NOTICE
            case Info:      return "Info"       // ASL_STRING_INFO
            case Debug:     return "Debug"      // ASL_STRING_DEBUG
            }
        }
    }
}
