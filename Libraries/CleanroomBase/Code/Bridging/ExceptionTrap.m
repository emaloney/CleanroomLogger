//
//  ExceptionTrap.m
//  Cleanroom Project
//
//  Created by Evan Maloney on 12/23/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import "ExceptionTrap.h"

@implementation ExceptionTrap

+ (BOOL) try:(nonnull ExceptionTrapTryBlock)tryBlock
       catch:(nullable ExceptionTrapCatchBlock)catchBlock
     finally:(nullable ExceptionTrapFinallyBlock)finallyBlock
{
    BOOL succeeded = NO;
    @try {
        tryBlock();
        succeeded = YES;
    }
    @catch (NSException* ex) {
        if (catchBlock) {
            catchBlock(ex);
        }
    }
    @finally {
        if (finallyBlock) {
            finallyBlock();
        }
    }
    return succeeded;
}

+ (BOOL) try:(ExceptionTrapTryBlock)tryBlock
       catch:(ExceptionTrapCatchBlock)catchBlock
{
    return [self try:tryBlock catch:catchBlock finally:nil];
}

+ (BOOL) try:(ExceptionTrapTryBlock)tryBlock
     finally:(ExceptionTrapFinallyBlock)finallyBlock
{
    return [self try:tryBlock
               catch:^(NSException* ex) {NSLog(@"%@ caught %@: %@\n%@", self, [ex class], ex.description, [ex.callStackSymbols componentsJoinedByString:@"\n"]);}
             finally:finallyBlock];
}

+ (BOOL) try:(ExceptionTrapTryBlock)tryBlock
{
    return [self try:tryBlock
               catch:^(NSException* ex) {NSLog(@"%@ caught %@: %@\n%@", self, [ex class], ex.description, [ex.callStackSymbols componentsJoinedByString:@"\n"]);}
             finally:nil];
}

+ (void) throwException:(nonnull NSException*)exception
{
    // yes, strictly speaking, this would accept a nullable
    // `exception` parameter, but we want the API to describe
    // the intent, not just 'what works'
    [exception raise];
}

+ (void) throwExceptionWithName:(nonnull NSString*)exceptionName
{
    [[[NSException alloc] initWithName:exceptionName reason:nil userInfo:nil] raise];
}

+ (void) throwExceptionWithName:(NSString*)exceptionName reason:(NSString*)reason
{
    [[[NSException alloc] initWithName:exceptionName reason:reason userInfo:nil] raise];
}

+ (void) throwExceptionWithName:(NSString*)exceptionName reason:(NSString*)reason userInfo:(NSDictionary*)info
{
    [[[NSException alloc] initWithName:exceptionName reason:reason userInfo:info] raise];
}

@end
