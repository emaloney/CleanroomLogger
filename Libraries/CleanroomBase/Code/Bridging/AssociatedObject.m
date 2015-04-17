//
//  AssociatedObject.m
//  Cleanroom Project
//
//  Created by Evan Maloney on 4/8/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

#import "AssociatedObject.h"

@implementation NSObject (CleanroomBaseAssociatedObject)

- (void) setAssociatedObject:(nullable id)object
                      forKey:(nonnull const void*)key
               storagePolicy:(AssociatedObjectStoragePolicy)policy
{
    objc_setAssociatedObject(self, key, object, policy);
}

- (nullable id) associatedObjectForKey:(nonnull const void*)key
{
    return objc_getAssociatedObject(self, key);
}

@end
