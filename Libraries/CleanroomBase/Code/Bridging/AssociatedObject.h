//
//  AssociatedObject.h
//  Cleanroom Project
//
//  Created by Evan Maloney on 4/8/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(UInt16, AssociatedObjectStoragePolicy)
{
    AssociatedObjectStoragePolicyWeak   = OBJC_ASSOCIATION_ASSIGN,
    AssociatedObjectStoragePolicyStrong = OBJC_ASSOCIATION_RETAIN_NONATOMIC,
    AssociatedObjectStoragePolicyCopy   = OBJC_ASSOCIATION_COPY_NONATOMIC
};

@interface NSObject (CleanroomBaseAssociatedObject)

- (void) setAssociatedObject:(nullable id)object
                      forKey:(nonnull const void*)key
               storagePolicy:(AssociatedObjectStoragePolicy)policy;

- (nullable id) associatedObjectForKey:(nonnull const void*)key;

@end

