//
//  AlarmData.m
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmData.h"
#import "AddonData.h"
#import "KMModelManager.h"

@implementation AlarmData

@dynamic itemID;
@dynamic alarmTime;
@dynamic text;
@dynamic open;
@dynamic type;
@dynamic repeatType;
@dynamic addon;
@dynamic todos;

+ (NSString *)entityName
{
    return @"AlarmData";
}

+ (NSArray *)primaryKeys
{
    return @[@"itemID"];
}

+ (NSDictionary *)keyMapping
{
    return @{
             @"alarmTime" : @"alarm_time",
             @"text" : @"text",
             @"open" : @"open",
             @"type" : @"type"
             };
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    AlarmData *tAlarm = [[self alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext:insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
    tAlarm.itemID = [NSNumber numberWithInteger:newAlarmItemID()];
    tAlarm.open = @YES;
    tAlarm.type = [NSNumber numberWithInteger:AlarmTypeGentle];
    tAlarm.repeatType = [NSNumber numberWithInt:(AlarmRepeatTypeSunday|AlarmRepeatTypeMonday|AlarmRepeatTypeTuesday|AlarmRepeatTypeWednesday|AlarmRepeatTypeThursday|AlarmRepeatTypeFriday|AlarmRepeatTypeSaturday)];
    tAlarm.text = NSLocalizedString(@"AlarmDataDefaultText", nil);
    return tAlarm;
}

#pragma mark - public

- (NSString *)alarmTypeText
{
    NSString *ret = @"";
    AlarmType alarmType = [self.type integerValue];
    switch (alarmType) {
        case AlarmTypeGentle:
            ret = @"轻柔";
            break;
            case AlarmTypeNag:
            ret = @"唠叨";
            break;
            
        default:
            break;
    }
    return ret;
}

- (NSString *)repeatText
{
    AlarmRepeatType repeatType = [self.repeatType integerValue];
    
    NSMutableString *repeatText = [NSMutableString stringWithCapacity:50];
    int dayCount = 0;
    
    if (AlarmRepeatTypeSunday == (AlarmRepeatTypeSunday&repeatType)) {
        [repeatText appendString:@"周日"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeMonday == (AlarmRepeatTypeMonday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周一"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeTuesday == (AlarmRepeatTypeTuesday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周二"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeWednesday == (AlarmRepeatTypeWednesday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周三"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeThursday == (AlarmRepeatTypeThursday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周四"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeFriday == (AlarmRepeatTypeFriday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周五"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeSaturday == (AlarmRepeatTypeSaturday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周六"];
        dayCount ++;
    }
    
    if (dayCount == 7) {
        return @"每天";
    }
    else if (dayCount == 0) {
        return @"从不";
    }
    else {
        return [repeatText copy];
    }
}

@end
