//
//  ExceptionTrap.h
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/23/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ExceptionTrapTryBlock)();
typedef void (^ExceptionTrapCatchBlock)(NSException* __nonnull ex);
typedef void (^ExceptionTrapFinallyBlock)();

@interface ExceptionTrap : NSObject

+ (BOOL) try:(nonnull ExceptionTrapTryBlock)tryBlock
       catch:(nullable ExceptionTrapCatchBlock)catchBlock
     finally:(nullable ExceptionTrapFinallyBlock)finallyBlock;

+ (BOOL) try:(nonnull ExceptionTrapTryBlock)tryBlock
       catch:(nullable ExceptionTrapCatchBlock)catchBlock;

+ (BOOL) try:(nonnull ExceptionTrapTryBlock)tryBlock
     finally:(nullable ExceptionTrapFinallyBlock)finallyBlock;

+ (BOOL) try:(nonnull ExceptionTrapTryBlock)tryBlock;

+ (void) throwException:(nonnull NSException*)exception;

+ (void) throwExceptionWithName:(nonnull NSString*)exceptionName
                         reason:(nullable NSString*)reason
                       userInfo:(nullable NSDictionary*)info;

+ (void) throwExceptionWithName:(nonnull NSString*)exceptionName
                         reason:(nullable NSString*)reason;

+ (void) throwExceptionWithName:(nonnull NSString*)exceptionName;

@end
