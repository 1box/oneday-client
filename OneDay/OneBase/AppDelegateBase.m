//
//  AppDelegate.m
//  OneDay
//
//  Created by Kimi on 12-10-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AppDelegateBase.h"
#import "NSUserDefaultsAdditions.h"
#import "AddonData.h"
#import "TagManager.h"
#import "KMModelManager.h"
#import "AlarmNotificationManager.h"
#import "CartoonManager.h"
#import "AddonManager.h"
#import "iRate.h"
#import "iVersion.h"
#import "Constants.h"

@interface AppDelegateBase () <iRateDelegate>
@property (nonatomic) UINavigationController *nav;
@end

@implementation AppDelegateBase

+ (void)initialize
{
    NSString *bundleID = [self bundleIDForRate];
    if (!KMEmptyString(bundleID)) {
        [iRate sharedInstance].applicationBundleID = bundleID;
        [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
        
//#warning debug code
//        [iRate sharedInstance].previewMode = YES;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.nav = (UINavigationController *)_window.rootViewController;
    
    [[KMTracker sharedTracker] setRootController:self.window.rootViewController];
    [[KMTracker sharedTracker] startTrack];
    
    [[KMModelManager sharedManager] start];
    if ([NSUserDefaults currentVersionFirstTimeRunByType:firstTimeTypeAppDelegate]
        || [[AddonManager sharedManager] allAddonsCount] == 0) {
        
        [AddonData loadDefaultDataFromDefaultPlist];
        [[TagManager sharedManager] loadDefaultTagsFromPlist];
    }
    
    [iRate sharedInstance].delegate = self;
    [[iVersion sharedInstance] checkForNewVersion];
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar_bg.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [[AlarmNotificationManager sharedManager] handleAlarmLocalNotification:localNotification];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[AlarmNotificationManager sharedManager] handleAlarmLocalNotification:notification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[AlarmNotificationManager sharedManager] rebuildAlarmNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark - extended

+ (NSString *)bundleIDForRate
{
    return @"";
}

#pragma mark - iRateDelegate

- (void)iRateUserDidAttemptToRateApp
{
    trackEvent(@"iRate", @"Confirm");
}

- (void)iRateUserDidDeclineToRateApp
{
    trackEvent(@"iRate", @"Decline");
}

@end
