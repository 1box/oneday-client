//
//  DailyPeriod.m
//  OneDay
//
//  Created by kimimaro on 13-7-30.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyPeriod.h"
#import "TodoData.h"
#import "SMDetector.h"

#define NoPeriodDaysFlag -1
#define PeriodCircleDays 30         // 月经周期
#define PeriodFirstSecureDays 4     // 安全期（前段）
#define PeriodEasyPregnantDays 14   // 易孕期
#define PeriodOvulationDay  10       // 排卵日
#define PeriodSecondSecureDays 23    // 安全期（后段）
#define PeriodDurationDays 30        // 月经期

#define kDailyPeriodLastPeriodDateUserDefaultKey @"kDailyPeriodLastPeriodDateUserDefaultKey"
static inline void setDailyPeriodLastPeriodDate(NSDate *date, NSInteger currentDay)
{
    [[NSUserDefaults standardUserDefaults] setObject:[date dateByAddingDays:PeriodDurationDays - currentDay]
                                              forKey:kDailyPeriodLastPeriodDateUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline NSDate* dailyPeriodLastPeriodDate()
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDailyPeriodLastPeriodDateUserDefaultKey];
}

#define kDailyPeriodHasMakeAWishUserDefaultKey @"kDailyPeriodHasMakeAWishUserDefaultKey"
static inline void setDailyPeriodHasMakeAWish(BOOL hasMake)
{
    [[NSUserDefaults standardUserDefaults] setBool:hasMake forKey:kDailyPeriodHasMakeAWishUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL dailyPeriodHasMakeAWish()
{
    // default NO
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDailyPeriodHasMakeAWishUserDefaultKey];
}


@implementation DailyPeriod

+ (NSString *)entityName
{
    return @"DailyPeriodData";
}

//+ (NSDictionary *)keyMapping
//{
//    NSMutableDictionary *keyMapping = [[[super keyMapping] mutableCopy] autorelease];
//    [keyMapping setObject:@"shortContent" forKey:@"short_content"];
//
//    return keyMapping;
//}

#pragma mark - private

- (NSString *)wish
{
    __block NSString *ret = nil;
    [[self todosSortedByIndex] enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        if (todo.wish) {
            ret = todo.wish;
            stop = YES;
        }
    }];
    return ret;
}

- (NSInteger)periodDays
{
    __block NSInteger periodDays = NoPeriodDaysFlag;
    [[self todosSortedByIndex] enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        if (todo.days) {
            periodDays = [[[SMDetector defaultDetector] valueInString:todo.days byType:SmarkDetectTypeDays] integerValue];
            stop = YES;
        }
    }];
    return periodDays;
}

#pragma mark - protected

- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)todayAndCompleteTextWithPrefix:(BOOL)hasPrefix
{
    NSDate *lastDate = dailyPeriodLastPeriodDate();
    NSInteger periodDays = [self periodDays];
    
    NSString *prefix = @"";
    if (hasPrefix && lastDate) {
        NSInteger beforeToday = [lastDate daysBeforeDate:[NSDate date]];
        if (beforeToday > 0 && beforeToday <= PeriodFirstSecureDays) {  // 安全期
            prefix = NSLocalizedString(@"PeriodFirstSecureDaysText", nil);
        }
        else if (beforeToday > PeriodFirstSecureDays && beforeToday <= PeriodEasyPregnantDays) {    // 易孕期
            if (beforeToday == PeriodOvulationDay) { // 排卵日
                prefix = NSLocalizedString(@"PeriodOvulationDayText", nil);
            }
            else {
                prefix = NSLocalizedString(@"PeriodEasyPregnantDaysText", nil);
            }
        }
        else if (beforeToday > PeriodEasyPregnantDays && beforeToday <= PeriodSecondSecureDays) {   // 安全期
            prefix = NSLocalizedString(@"PeriodSecondSecureDaysText", nil);
        }
        else if (beforeToday > PeriodSecondSecureDays && beforeToday <= PeriodDurationDays) {   // 月经期
            prefix = NSLocalizedString(@"PeriodDurationDaysText", nil);
        }
    }
    
    NSString *suffix = NSLocalizedString(@"PeriodNoText", nil);
    if (periodDays == NoPeriodDaysFlag) {
        if (lastDate) {
            NSInteger beforeToday = [lastDate daysBeforeDate:[NSDate date]];
            if (beforeToday > 0 && beforeToday <= PeriodDurationDays) {
                if (dailyPeriodHasMakeAWish()) {
                    suffix = NSLocalizedString(@"PeriodAfterTodayText", nil);
                }
                else {
                    suffix = [NSString stringWithFormat:NSLocalizedString(@"PeriodBeforeTodayText", nil), PeriodCircleDays - PeriodDurationDays - beforeToday];
                }
            }
            else if (beforeToday > PeriodDurationDays && beforeToday < PeriodCircleDays - PeriodDurationDays) {
                suffix = [NSString stringWithFormat:NSLocalizedString(@"PeriodBeforeTodayText", nil), PeriodCircleDays - PeriodDurationDays - beforeToday];
            }
            else {
                suffix = NSLocalizedString(@"PeriodNotComeTodayText", nil);
            }
        }
    }
    else {
        suffix = [NSString stringWithFormat:NSLocalizedString(@"PeriodInTodayText", nil), periodDays];
        setDailyPeriodLastPeriodDate([NSDate date], periodDays);
    }
    
    NSString *ret = @"";
    if (KMEmptyString(prefix) || !hasPrefix) {
        ret = suffix;
    }
    else {
        ret = [NSString stringWithFormat:@"%@|%@", prefix, suffix];
    }
    return ret;
}

- (NSString *)todayText
{
    return [self todayAndCompleteTextWithPrefix:NO];
}

- (NSString *)completionText
{
    return [self todayAndCompleteTextWithPrefix:YES];
}

@end
