//
//  AlarmNotificationManager.h
//  MedAlarm
//
//  Created by Kimi on 12-10-15.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAlarmNotificationTypeKey @"kAlarmNotificationTypeKey"
#define kAlarmNotificationCreateDateKey @"kAlarmNotificationCreateDateKey"

#define DefaultAlarmNotificationFireTimeString @"21:00"
#define kAlarmNotificationFireTimeStringUserDefaultKey @"kAlarmNotificationFireTimeStringUserDefaultKey"
static inline NSString* alarmNotificationFireTimeString() {
    NSString *ret = [[NSUserDefaults standardUserDefaults] stringForKey:kAlarmNotificationFireTimeStringUserDefaultKey];
    // default DefaultAlarmNotificationFireTimeString
    if (KMEmptyString(ret)) {
        ret = DefaultAlarmNotificationFireTimeString;
    }
    return ret;
}

static inline void setAlarmNotificationFireTimeString(NSString *fireTime) {
    [[NSUserDefaults standardUserDefaults] setObject:fireTime forKey:kAlarmNotificationFireTimeStringUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kAlarmNotificationFireTimeSwitchUserDefaultKey @"kAlarmNotificationFireTimeSwitchUserDefaultKey"

static inline void setAlarmNotificationSwitch(BOOL on) {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kAlarmNotificationFireTimeSwitchUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL alarmNotificationSwitch() {
    if ([NSUserDefaults firstTimeUseKey:kAlarmNotificationFireTimeSwitchUserDefaultKey]) {
        // default YES
        setAlarmNotificationSwitch(YES);
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAlarmNotificationFireTimeSwitchUserDefaultKey];
}

// alarm setting
#define kShowAppIconBadgeUserDefaultKey @"kShowAppIconBadgeUserDefaultKey"

static inline void setShowAppIconBadge(BOOL show) {
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:kShowAppIconBadgeUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL showAppIconBadge() {
    if ([NSUserDefaults firstTimeUseKey:kShowAppIconBadgeUserDefaultKey]) {
        setShowAppIconBadge(YES);
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShowAppIconBadgeUserDefaultKey];
}

#define kPlayAlarmSoundsUserDefaultKey @"kPlayAlarmSoundsUserDefaultKey"

static inline void setPlayAlarmSounds(BOOL play) {
    [[NSUserDefaults standardUserDefaults] setBool:play forKey:kPlayAlarmSoundsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL playAlarmSounds() {
    if ([NSUserDefaults firstTimeUseKey:kPlayAlarmSoundsUserDefaultKey]) {
        // default YES
        setPlayAlarmSounds(YES);
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPlayAlarmSoundsUserDefaultKey];
}

#define kMakeAlarmVibratorUserDefaultKey @"kAlarmVibratorUserDefaultKey"
static inline BOOL makeAlarmVibrator() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMakeAlarmVibratorUserDefaultKey];
}

static inline void setMakeAlarmVibrator(BOOL make) {
    [[NSUserDefaults standardUserDefaults] setBool:make forKey:kMakeAlarmVibratorUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

typedef NS_ENUM(NSInteger, AlarmNotificationType) {
    AlarmNotificationTypeEveryday = 0,
    AlarmNotificationTypeDailyDo
};

@class AddonData;
@class AlarmData;


@interface AlarmManager : NSObject

+ (AlarmManager *)sharedManager;

- (NSArray *)alarmsForAddon:(AddonData *)addon;
- (AlarmData *)alarmForAddon:(AddonData *)addon;
- (BOOL)insertAlarm:(AlarmData *)alarm;    // return YES for success

- (void)rebuildAlarmNotifications;
- (void)handleAlarmLocalNotification:(UILocalNotification *)notification;
@end
