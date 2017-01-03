//
//  OSLogMimicFormatter.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 1/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

internal final class OSLogMimicFormatter: FieldBasedLogFormatter
{
    public init()
    {
        super.init(fields: [.timestamp(.custom("yyyy-MM-dd HH:mm:ss.SSSSSS")),
                            .literal(" "),
                            .processName,
                            .literal("["),
                            .processID,
                            .literal(":"),
                            .callingThread(.integer),
                            .literal("] [CleanroomLogger] ")])
    }
}
