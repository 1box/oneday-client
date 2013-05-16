//
//  AlarmData.h
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "SSEntityBase.h"

typedef NS_ENUM(NSInteger, AlarmType) {
    AlarmTypeGentle = 0,
    AlarmTypeNag
};

typedef NS_ENUM(NSInteger, AlarmRepeatType) {
    AlarmRepeatTypeSunday = 1UL,
    AlarmRepeatTypeMonday = (1UL << 1),
    AlarmRepeatTypeTuesday = (1UL << 2),
    AlarmRepeatTypeWednesday = (1UL << 3),
    AlarmRepeatTypeThursday = (1UL << 4),
    AlarmRepeatTypeFriday = (1UL << 5),
    AlarmRepeatTypeSaturday = (1UL << 6)
};

#define kMakeAlarmItemIDUserDefaultKey @"kMakeAlarmItemIDUserDefaultKey"
static inline NSUInteger newAlarmItemID() {
    NSUInteger makeID = [[NSUserDefaults standardUserDefaults] integerForKey:kMakeAlarmItemIDUserDefaultKey] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:makeID forKey:kMakeAlarmItemIDUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return makeID;
}


@class AddonData;

@interface AlarmData : SSEntityBase

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *alarmTime; // 24-hour style eg. 19:30
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *open;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *repeatType;

@property (nonatomic, strong) AddonData *addon;

- (NSString *)alarmTypeText;
- (NSString *)repeatText;
@end