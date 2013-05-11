//
//  AlarmNotificationManager.m
//  MedAlarm
//
//  Created by Kimi on 12-10-15.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "AlarmNotificationManager.h"
#import "AddonManager.h"
#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "KMDateUtils.h"
#import "NSDateFormatter+NSDateFormatterAdditions.h"

@interface AlarmNotificationManager () <UIAlertViewDelegate>
@property (nonatomic) UILocalNotification *localNotification;
@end

@implementation AlarmNotificationManager

static AlarmNotificationManager *_sharedManager = nil;
+ (AlarmNotificationManager *)sharedManager
{
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [[AlarmNotificationManager alloc] init];
        }
    }
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - public

- (void)handleAlarmLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    AlarmNotificationType alarmType = [[notification.userInfo objectForKey:kAlarmNotificationTypeKey] integerValue];
    if (alarmType == AlarmNotificationTypeEveryday) {
        self.localNotification = notification;
        NSDate *createDate = [notification.userInfo objectForKey:kAlarmNotificationCreateDateKey];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[YearToDayFormatter() userFriendlyStringFromDate:createDate]
                                                        message:notification.alertBody
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Go and See", nil)
                                              otherButtonTitles:NSLocalizedString(@"Check All", nil), nil];
        [alert show];
    }
}

- (void)rebuildAlarmNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self scheduleDailyAlarmNotification];
}

#pragma mark - private

- (void)scheduleDailyAlarmNotification
{
    if (alarmNotificationSwitch()) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.repeatInterval = 0;
        localNotification.alertAction = NSLocalizedString(@"Go", nil);
        localNotification.soundName = playAlarmSounds() ? UILocalNotificationDefaultSoundName : nil;
        NSDate *fireDate = [HourToMiniteFormatter() todayDateFromString:alarmNotificationFireTimeString()];
        if ([fireDate earlierDate:[NSDate date]] == fireDate) {
            fireDate = [fireDate sameTimeTomorrow];
        }
        localNotification.fireDate = fireDate;
        
        __block int badgeNumber = 0;
        __block NSMutableString *message = [NSMutableString string];
        
        NSArray *addons = [[AddonManager sharedManager] alarmAddons];
        [addons enumerateObjectsUsingBlock:^(AddonData *tAddon, NSUInteger idx, BOOL *stop) {
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:tAddon];
            
            if (![todayDo.check boolValue] && [todayDo.todos count] > 0) {
                
                int todoCount = 0;
                for (TodoData *todo in todayDo.todos) {
                    if (![todo.check boolValue]) {
                        todoCount ++;
                    }
                }
                
                if (badgeNumber != 0) {
                    [message appendFormat:@", "];
                }
                [message appendFormat:NSLocalizedString(@"_dailyAlarmNotificationMessage", nil), todoCount, NSLocalizedString(todayDo.addon.title, nil)];
                badgeNumber += todoCount;
            }
        }];
        
        localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"_dailyAlarmNotificationBody", nil), message];
        localNotification.applicationIconBadgeNumber = showAppIconBadge() ? badgeNumber : 0;
        
        localNotification.userInfo = @{
        kAlarmNotificationTypeKey : [NSNumber numberWithInteger:AlarmNotificationTypeEveryday],
        kAlarmNotificationCreateDateKey : [NSDate date]
        };
        
        if (badgeNumber > 0) {
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        // mark all check
        NSArray *addons = [[AddonManager sharedManager] alarmAddons];
        [addons enumerateObjectsUsingBlock:^(AddonData *tAddon, NSUInteger idx, BOOL *stop) {
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:tAddon];
            if (![todayDo.check boolValue] && [todayDo.todos count] > 0) {
                for (TodoData *todo in todayDo.todos) {
                    if (![todo.check boolValue]) {
                        todo.check = @YES;
                    }
                }
            }
        }];
        [[KMModelManager sharedManager] saveContext:nil];
    }
    [self rebuildAlarmNotifications];
}

@end
