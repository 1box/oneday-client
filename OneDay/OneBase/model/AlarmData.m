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

@dynamic alarmTime;
@dynamic title;
@dynamic text;
@dynamic open;
@dynamic type;
@dynamic repeatType;
@dynamic addon;

+ (NSString *)entityName
{
    return @"AlarmData";
}

+ (NSArray *)primaryKeys
{
    return @[@"alarmTime", @"addon.dailyDoName"];
}

+ (NSDictionary *)keyMapping
{
    return @{
             @"alarmTime" : @"alarm_time",
             @"title" : @"title",
             @"text" : @"text",
             @"open" : @"open",
             @"type" : @"type"
             };
}

+ (id)dataEntityWithInsert:(BOOL)insert
{
    AlarmData *tAlarm = [[self alloc] initWithEntity:[self entityDescription] insertIntoManagedObjectContext:insert ? [[KMModelManager sharedManager] managedObjectContext] : nil];
    tAlarm.open = @YES;
    tAlarm.type = [NSNumber numberWithInteger:AlarmTypeGentle];
    return tAlarm;
}

@end
