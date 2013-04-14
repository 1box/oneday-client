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

@class DailyDoBase;

@interface TodoData : SSEntityBase

@property (nonatomic) NSNumber *itemID;
@property (nonatomic) NSNumber *index;
@property (nonatomic) NSString *startTime;  // 24-hour style eg. 19:30
@property (nonatomic) NSString *eventColor;
@property (nonatomic) NSNumber *duration;   // seconds eg. 3600
@property (nonatomic) NSString *location;
@property (nonatomic) NSNumber *check;
@property (nonatomic) NSString *content;    // contain time&duration if exsit

// optional
@property (nonatomic) NSString *money;
@property (nonatomic) NSString *caloric;
@property (nonatomic) NSString *distance;
@property (nonatomic) NSString *frequency;
@property (nonatomic) NSString *quantity;

@property (nonatomic) DailyDoBase *dailyDo;

+ (NSDateFormatter *)startTimeDateFormmatter;

- (NSUInteger)lineNumberStringLength;
- (NSString *)lineNumberString;  // eg. 1. 
- (NSString *)pureContent;  // content without SMSeparator
- (NSString *)timelineContent;
- (NSDate *)dateForStartTime;
@end

