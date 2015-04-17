//
//  ASLMessageAttribute.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import CleanroomBase

public enum ASLMessageAttribute: String
{
    case Time                   = "Time"                    // ASL_KEY_TIME
    case TimeNanoSec            = "TimeNanoSec"             // ASL_KEY_TIME_NSEC
    case Host                   = "Host"                    // ASL_KEY_HOST
    case Sender                 = "Sender"                  // ASL_KEY_SENDER
    case Facility               = "Facility"                // ASL_KEY_FACILITY
    case PID                    = "PID"                     // ASL_KEY_PID
    case UID                    = "UID"                     // ASL_KEY_UID
    case GID                    = "GID"                     // ASL_KEY_GID
    case Level                  = "Level"                   // ASL_KEY_LEVEL
    case Message                = "Message"                 // ASL_KEY_MSG
    case ReadUID                = "ReadUID"                 // ASL_KEY_READ_UID
    case ReadGID                = "ReadGID"                 // ASL_KEY_READ_GID
    case ASLExpireTime          = "ASLExpireTime"           // ASL_KEY_EXPIRE_TIME
    case ASLMessageID           = "ASLMessageID"            // ASL_KEY_MSG_ID
    case Session                = "Session"                 // ASL_KEY_SESSION
    case RefPID                 = "RefPID"                  // ASL_KEY_REF_PID
    case RefProc                = "RefProc"                 // ASL_KEY_REF_PROC
    case ASLAuxTitle            = "ASLAuxTitle"             // ASL_KEY_AUX_TITLE
    case ASLAuxUTI              = "ASLAuxUTI"               // ASL_KEY_AUX_UTI
    case ASLAuxURL              = "ASLAuxURL"               // ASL_KEY_AUX_URL
    case ASLAuxData             = "ASLAuxData"              // ASL_KEY_AUX_DATA
    case ASLOption              = "ASLOption"               // ASL_KEY_OPTION
    case ASLModule              = "ASLModule"               // ASL_KEY_MODULE
    case SenderInstance         = "SenderInstance"          // ASL_KEY_SENDER_INSTANCE
    case SenderMachUUID         = "SenderMachUUID"          // ASL_KEY_SENDER_MACH_UUID
    case ASLFinalNotification   = "ASLFinalNotification"    // ASL_KEY_FINAL_NOTIFICATION
    case OSActivityID           = "OSActivityID"            // ASL_KEY_OS_ACTIVITY_ID
}
