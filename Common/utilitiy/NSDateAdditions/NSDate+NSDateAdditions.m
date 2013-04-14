//
//  NSDate+NSDateAdditions.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "NSDate+NSDateAdditions.h"
#import "KMDateUtils.h"

@implementation NSDate (NSDateAdditions)

static unsigned _unitFlags = (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit);

+ (NSDate *)currentTimeTomorrow
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.day += 1;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

+ (NSDate *)currentTimeAfterDay:(NSInteger)days
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.day += days;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (BOOL)isToday
{
    NSDate *today = beginningOfToday();
    NSDate *tomorrow = beginningOfTomorrow();
    
    NSDate *ealier = [self earlierDate:tomorrow];
    NSDate *later = [self laterDate:today];
    
    return later == self && ealier == self;
}

- (BOOL)isTomorrow
{
    NSDate *tomorrow = beginningOfTomorrow();
    NSDate *beginningtheDayAftertomorrow = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginningtheDayAftertomorrow interval:NULL forDate:[NSDate currentTimeAfterDay:2]];
    
    if (ok) {
        NSDate *ealier = [self earlierDate:beginningtheDayAftertomorrow];
        NSDate *later = [self laterDate:tomorrow];
        return later == self && ealier == self;
    }
    else {
        return NO;
    }
}

- (NSDate *)morning
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)midnight
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:self];
    components.day = components.day;
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (BOOL)isSameDayWithDate:(NSDate *)date
{
    NSDate *ealier = [date earlierDate:[self midnight]];
    NSDate *later = [date laterDate:[self morning]];
    return (ealier == date && later == date);
}

- (NSDate *)sameTimeToday
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:self];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.year = todayComponents.year;
    components.month = todayComponents.month;
    components.day = todayComponents.day;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)sameTimeTomorrow
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:_unitFlags fromDate:self];
    NSDateComponents *tComponents = [[NSCalendar currentCalendar] components:_unitFlags fromDate:[NSDate date]];
    components.year = tComponents.year;
    components.month = tComponents.month;
    components.day = tComponents.day + 1;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}
@end
