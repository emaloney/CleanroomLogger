//
//  RuntimeErrors.swift
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/12/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

import Foundation

/**
To be used from within unimplemented functions. A function might not be
implemented because development is still in progress, or because a subclass
was expected to override the function to provide an implementation. This
function is intended to be called with zero arguments.
*/
@noreturn public func errorNotImplemented(function: String = __FUNCTION__)
{
    fatalError("Function not implemented: \(function)")
}

/**
Swift requires switch statements to be exhaustive, but sometimes certain cases
and/or the default case should never be hit. If those cases are ever matched,
it signals a programming error. This function can be used to handle such cases.
*/
@noreturn public func errorUnhandledCase(function: String = __FUNCTION__)
{
    fatalError("Unhandled case error in function: \(function)")
}
