//
//  DailyPeriod.m
//  OneDay
//
//  Created by kimimaro on 13-7-30.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyPeriod.h"
#import "TodoData.h"
#import "KMModelManager.h"
#import "SMDetector.h"

#define NoPeriodDaysFlag -1
#define PeriodCircleDays 30         // 月经周期
#define PeriodFirstSecureDays 4     // 安全期（前段）
#define PeriodEasyPregnantDays 14   // 易孕期
#define PeriodOvulationDay  10      // 排卵日
#define PeriodSecondSecureDays 23   // 安全期（后段）
#define PeriodDurationDays 30       // 月经期
#define PeriodDurationDayCount (PeriodDurationDays - PeriodSecondSecureDays)    // 经期长度：7天

#define kDailyPeriodLastPeriodDateUserDefaultKey @"kDailyPeriodLastPeriodDateUserDefaultKey"
static inline void setDailyPeriodLastPeriodDate(NSDate *date, NSInteger currentDay) {
    NSDate *lastDate = [[date dateByAddingDays:((PeriodDurationDays - PeriodSecondSecureDays) - currentDay)] morning];
    [[NSUserDefaults standardUserDefaults] setObject:lastDate
                                              forKey:kDailyPeriodLastPeriodDateUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline NSDate* dailyPeriodLastPeriodDate() {
    NSDate *ret = [[NSUserDefaults standardUserDefaults] objectForKey:kDailyPeriodLastPeriodDateUserDefaultKey];
    return ret;
}

static inline BOOL hasDailyPeriodLastPeriodDate() {
    return dailyPeriodLastPeriodDate() != nil;
}

#define kDailyPeriodHasMakeAWishUserDefaultKey @"kDailyPeriodHasMakeAWishUserDefaultKey"
static inline void setDailyPeriodHasMakeAWish(BOOL hasMake) {
    [[NSUserDefaults standardUserDefaults] setBool:hasMake forKey:kDailyPeriodHasMakeAWishUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline BOOL dailyPeriodHasMakeAWish() {
    // default NO
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDailyPeriodHasMakeAWishUserDefaultKey];
}

typedef NS_ENUM(NSInteger, DailyPeriodDayType) {
    DailyPeriodDayTypeNone,         // 尚未设置
    DailyPeriodDayTypeFirstSecure,  // 安全期（前段）
    DailyPeriodDayTypeEasyPregnant, // 易孕期
    DailyPeriodDayTypeOvulationDay, // 排卵日
    DailyPeriodDayTypeSecondSecure, // 安全期（后段）
    DailyPeriodDayTypeDuration,     // 月经期
    DailyPeriodDayTypeNotCome       // 逾期未至
};

@implementation DailyPeriod

+ (NSString *)entityName
{
    return @"DailyPeriodData";
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    DailyDoBase *dailyDo = [super dataEntityWithInsert:insert];
    return dailyDo;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];
    
    TodoData *tTodo = [self insertNewTodoAtIndex:0];
    NSDate *dailyDoDate = [NSDate dateWithTimeIntervalSince1970:[self.createTime doubleValue]];
    DailyPeriodDayType type = [DailyPeriod periodDayType:dailyDoDate];
    if (type == DailyPeriodDayTypeDuration) {
        NSDate *lastDate = dailyPeriodLastPeriodDate();
        NSInteger periodDays = PeriodDurationDayCount - [dailyDoDate daysBeforeDate:lastDate] - 1;
        
        NSString *daysString = [[SMDetector defaultDetector] stringForValue:@(periodDays) byType:SmarkDetectTypeDays];
        tTodo.content = daysString;
        tTodo.days = daysString;
    }
    else {
        tTodo.content = @"";
    }
    [[KMModelManager sharedManager] saveContext:nil];   
}

#pragma mark - extended

- (BOOL)detectTodos
{
    BOOL ret = [super detectTodos];
    if (ret) {
        NSString *wish = [self wish];
        if (!CheckStringInvalid(wish)) {
            if ([PrayWords containsObject:wish]) {
                setDailyPeriodHasMakeAWish(YES);
            }
            else {
                setDailyPeriodHasMakeAWish(NO);
            }
        }
        
        NSInteger periodDays = [self periodDays];
        if (periodDays != NoPeriodDaysFlag) {
            setDailyPeriodLastPeriodDate([NSDate dateWithTimeIntervalSince1970:[self.createTime doubleValue]], periodDays);
        }
    }
    return ret;
}

#pragma mark - public

+ (BOOL)hasDailyPeriodLastPeriodDate
{
    return hasDailyPeriodLastPeriodDate();
}

#pragma mark - private

+ (DailyPeriodDayType)periodDayType:(NSDate *)date
{
    NSDate *lastDate = dailyPeriodLastPeriodDate();
    DailyPeriodDayType type = DailyPeriodDayTypeNone;
    
    if (lastDate) {
        NSInteger beforeToday = [lastDate daysBeforeDate:date];
        
        if (beforeToday <= 0) {
            beforeToday =  beforeToday%PeriodCircleDays + PeriodCircleDays;
        }
        
        if (beforeToday > 0 && beforeToday <= PeriodFirstSecureDays) {  // 安全期
            type = DailyPeriodDayTypeFirstSecure;
        }
        else if (beforeToday > PeriodFirstSecureDays && beforeToday <= PeriodEasyPregnantDays) {    // 易孕期
            if (beforeToday == PeriodOvulationDay) { // 排卵日
                type = DailyPeriodDayTypeOvulationDay;
            }
            else {
                type = DailyPeriodDayTypeEasyPregnant;
            }
        }
        else if (beforeToday > PeriodEasyPregnantDays && beforeToday <= PeriodSecondSecureDays) {   // 安全期
            type = DailyPeriodDayTypeSecondSecure;
        }
        else if (beforeToday > PeriodSecondSecureDays && beforeToday <= PeriodDurationDays) {   // 月经期
            type = DailyPeriodDayTypeDuration;
        }
        else {
            type = DailyPeriodDayTypeNotCome;
        }
    }
    return type;
}

- (NSString *)wish
{
    __block NSString *ret = nil;
    [[self todosSortedByIndex] enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        if (todo.wish) {
            ret = todo.wish;
            *stop = YES;
        }
    }];
    return ret;
}

// 返回当前是月经第几天
- (NSInteger)periodDays
{
    __block NSInteger periodDays = NoPeriodDaysFlag;    // 未找到，可能非经期，可能用户未输入
    [[self todosSortedByIndex] enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop) {
        if (todo.days) {
            periodDays = [[[SMDetector defaultDetector] valueInString:todo.days byType:SmarkDetectTypeDays] integerValue];
            *stop = YES;
        }
    }];
    return periodDays;
}

- (NSString *)dailyPeriodTextWithPrefix:(BOOL)hasPrefix
{
    DailyPeriodDayType type = [DailyPeriod periodDayType:[NSDate dateWithTimeIntervalSince1970:[self.createTime doubleValue]]];
    
    NSString *prefix = @"";
    if (hasPrefix) {
        switch (type) {
            case DailyPeriodDayTypeFirstSecure:
                prefix = NSLocalizedString(@"PeriodFirstSecureDaysText", nil);
                break;
            case DailyPeriodDayTypeOvulationDay:
                prefix = NSLocalizedString(@"PeriodOvulationDayText", nil);
                break;
            case DailyPeriodDayTypeEasyPregnant:
                prefix = NSLocalizedString(@"PeriodEasyPregnantDaysText", nil);
                break;
            case DailyPeriodDayTypeSecondSecure:
                prefix = NSLocalizedString(@"PeriodSecondSecureDaysText", nil);
                break;
            case DailyPeriodDayTypeDuration:
                prefix = NSLocalizedString(@"PeriodDurationDaysText", nil);
                break;
            default:
                break;
        }
    }
    
    NSString *suffix = NSLocalizedString(@"PeriodNoText", nil);
    NSDate *lastDate = dailyPeriodLastPeriodDate();
    NSInteger beforeToday = [lastDate daysBeforeDate:[NSDate date]];
    switch (type) {
        case DailyPeriodDayTypeFirstSecure:
        case DailyPeriodDayTypeOvulationDay:
        case DailyPeriodDayTypeEasyPregnant:
        case DailyPeriodDayTypeSecondSecure:
        {
            if (dailyPeriodHasMakeAWish() && type == DailyPeriodDayTypeFirstSecure) {    // 还愿
                suffix = NSLocalizedString(@"PeriodAfterTodayText", nil);
            }
            else {  // 显示距下次月经来临时间
                suffix = [NSString stringWithFormat:NSLocalizedString(@"PeriodBeforeTodayText", nil), PeriodCircleDays - PeriodDurationDays - beforeToday];
            }
        }
            break;
        case DailyPeriodDayTypeDuration:
        {
            NSInteger periodDays = [self periodDays];
            if (periodDays == NoPeriodDaysFlag) {
                suffix = NSLocalizedString(@"PeriodNotComeTodayText", nil);
            }
            else {
                suffix = [NSString stringWithFormat:NSLocalizedString(@"PeriodInTodayText", nil), periodDays];
            }
        }
            break;
        case DailyPeriodDayTypeNotCome:
            suffix = NSLocalizedString(@"PeriodNotComeTodayText", nil);
            break;
        default:
            break;
    }
    
    NSString *ret = @"";
    if (CheckStringInvalid(prefix) || !hasPrefix) {
        ret = suffix;
    }
    else {
        ret = [NSString stringWithFormat:@"%@|%@", prefix, suffix];
    }
    return ret;
}

#pragma mark - protected

+ (ECalendarCellMarkType)calendarCellMarkType:(NSDate *)date
{
    DailyPeriodDayType type = [self periodDayType:date];
    
    ECalendarCellMarkType ret = ECalendarCellMarkTypeNone;
    switch (type) {
        case DailyPeriodDayTypeOvulationDay:
            ret = ECalendarCellMarkTypeBlueColorWithEvent;
            break;
        case DailyPeriodDayTypeEasyPregnant:
            ret = ECalendarCellMarkTypeBlueColor;
            break;
        case DailyPeriodDayTypeDuration:
            ret = ECalendarCellMarkTypePinkColor;
            break;
        default:
            break;
    }
    return ret;
}

- (NSString *)presentedText
{
    return [self todosTextWithLineNumber:YES];
}

- (NSString *)todayText
{
    return [self dailyPeriodTextWithPrefix:NO];
}

- (NSString *)completionText
{
    return [self dailyPeriodTextWithPrefix:YES];
}

@end
