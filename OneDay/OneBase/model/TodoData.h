//
//  TodoData.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "SSEntityBase.h"

#define DefaultFirstStartTime @"09:30"
#define DefaultLastStartTime @"18:30"
#define DefaultTodoDuration 30*60
#define DefaultTodoTimeInterval 15*60

#define kMakeToDoItemIDUserDefaultKey @"kMakeToDoItemIDUserDefaultKey"
static inline NSUInteger newToDoItemID() {
    NSUInteger makeID = [[NSUserDefaults standardUserDefaults] integerForKey:kMakeToDoItemIDUserDefaultKey] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:makeID forKey:kMakeToDoItemIDUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return makeID;
}

// Todo类型
typedef NS_ENUM(NSInteger, ODTodoType) {
    ODTodoTypeNone = 0,
    ODTodoTypeDuration = 1UL,           // 1
    ODTodoTypeCalorie = (1UL << 1),     // 2
    ODTodoTypeDistance = (1UL << 2),    // 4
    ODTodoTypeFrequency = (1UL << 3),   // 8
    ODTodoTypeQuantity = (1UL << 4),    // 16
    ODTodoTypeDays = (1UL << 5),        // 32
    ODTodoTypeWish = (1UL << 6),        // 64
    ODTodoTypeMoney = (1UL << 7)        // 128
};


@class DailyDoBase;
@class AlarmData;

@interface TodoData : SSEntityBase

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSString *startTime;  // 24-hour style eg. 19:30
@property (nonatomic, strong) NSString *eventColor;
@property (nonatomic, strong) NSNumber *duration;   // seconds eg. 3600
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSNumber *check;
@property (nonatomic, strong) NSString *content;    // contain time&duration if exsit

// optional
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *caloric;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *frequency;
@property (nonatomic, strong) NSString *quantity;
@property (nonatomic, strong) NSString *days;
@property (nonatomic, strong) NSString *wish;   // for Daily Period

@property (nonatomic, strong) DailyDoBase *dailyDo;
@property (nonatomic, strong) AlarmData *alarm;

+ (NSDateFormatter *)startTimeDateFormmatter;

- (void)updateWithAlarm:(AlarmData *)alarm save:(BOOL)save;

- (NSUInteger)lineNumberStringLength;
- (NSString *)lineNumberString;  // eg. 1. 
- (NSString *)pureContent;  // content without SMSeparator
- (NSString *)timelineContent;
- (NSDate *)dateForStartTime;

@end

