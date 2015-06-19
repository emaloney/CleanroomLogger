//
//  ASLAttributeKey.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 3/17/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

/**
The `ASLAttributeKey` enum represents the documented `ASL_KEY_*` constant
values.

These values can be used to set or retrieve attributes on `ASLObject`
instances.
*/
public enum ASLAttributeKey: String
{
    /** Represents the `ASL_KEY_TIME` constant. */
    case Time                   = "Time"

    /** Represents the `ASL_KEY_TIME_NSEC` constant. */
    case TimeNanoSec            = "TimeNanoSec"

    /** Represents the `ASL_KEY_HOST` constant. */
    case Host                   = "Host"

    /** Represents the `ASL_KEY_SENDER` constant. */
    case Sender                 = "Sender"

    /** Represents the `ASL_KEY_FACILITY` constant. */
    case Facility               = "Facility"

    /** Represents the `ASL_KEY_PID` constant. */
    case PID                    = "PID"

    /** Represents the `ASL_KEY_UID` constant. */
    case UID                    = "UID"

    /** Represents the `ASL_KEY_GID` constant. */
    case GID                    = "GID"

    /** Represents the `ASL_KEY_LEVEL` constant. */
    case Level                  = "Level"

    /** Represents the `ASL_KEY_MSG` constant. */
    case Message                = "Message"

    /** Represents the `ASL_KEY_READ_UID` constant. */
    case ReadUID                = "ReadUID"

    /** Represents the `ASL_KEY_READ_GID` constant. */
    case ReadGID                = "ReadGID"

    /** Represents the `ASL_KEY_EXPIRE_TIME` constant. */
    case ASLExpireTime          = "ASLExpireTime"

    /** Represents the `ASL_KEY_MSG_ID` constant. */
    case ASLMessageID           = "ASLMessageID"

    /** Represents the `ASL_KEY_SESSION` constant. */
    case Session                = "Session"

    /** Represents the `ASL_KEY_REF_PID` constant. */
    case RefPID                 = "RefPID"

    /** Represents the `ASL_KEY_REF_PROC` constant. */
    case RefProc                = "RefProc"

    /** Represents the `ASL_KEY_AUX_TITLE` constant. */
    case ASLAuxTitle            = "ASLAuxTitle"

    /** Represents the `ASL_KEY_AUX_UTI` constant. */
    case ASLAuxUTI              = "ASLAuxUTI"

    /** Represents the `ASL_KEY_AUX_URL` constant. */
    case ASLAuxURL              = "ASLAuxURL"

    /** Represents the `ASL_KEY_AUX_DATA` constant. */
    case ASLAuxData             = "ASLAuxData"

    /** Represents the `ASL_KEY_OPTION` constant. */
    case ASLOption              = "ASLOption"

    /** Represents the `ASL_KEY_MODULE` constant. */
    case ASLModule              = "ASLModule"

    /** Represents the `ASL_KEY_SENDER_INSTANCE` constant. */
    case SenderInstance         = "SenderInstance"

    /** Represents the `ASL_KEY_SENDER_MACH_UUID` constant. */
    case SenderMachUUID         = "SenderMachUUID"

    /** Represents the `ASL_KEY_FINAL_NOTIFICATION` constant. */
    case ASLFinalNotification   = "ASLFinalNotification"

    /** Represents the `ASL_KEY_OS_ACTIVITY_ID` constant. */
    case OSActivityID           = "OSActivityID"
}
