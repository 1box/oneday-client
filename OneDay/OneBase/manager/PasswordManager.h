//
//  PasswordManager.h
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DotLockViewController.h"

@class AddonData;

@interface PasswordManager : NSObject

+ (PasswordManager *)sharedManager;

- (void)showLaunchLockIfNecessary;
- (void)showAddonLock:(AddonData *)addon finishBlock:(LockViewDismissBlock)finishedBlock;

- (void)resetHasShownAddonDictionary;

+ (BOOL)launchPasswordOpen;
+ (void)setLaunchPasswordOpen:(BOOL)open;

- (void)setDotLockPasswordOpen:(BOOL)open;
- (BOOL)dotLockPasswordOpen;

- (BOOL)hasDotLockPassword;
- (BOOL)checkDotLockPassword:(NSString *)password;
- (void)setDotLockPassword:(NSString *)password;

@end
