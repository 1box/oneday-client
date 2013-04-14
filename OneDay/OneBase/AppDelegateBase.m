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

@interface AppDelegateBase ()
@property (nonatomic) UINavigationController *nav;
@end

@implementation AppDelegateBase

+ (void)initialize
{
//#warning debug code
//    [iRate sharedInstance].ratedThisVersion = NO;
//    [iRate sharedInstance].daysUntilPrompt = 0;
//    [iRate sharedInstance].usesUntilPrompt = 0;
    
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].ratingsURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/yi-tian-ai-ji-hua-ai-ji-lu/id573096972?ls=1&mt=8"];
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
@end
