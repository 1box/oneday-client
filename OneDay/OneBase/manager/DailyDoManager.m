//
//  DailyDoManager.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "KMDateUtils.h"

@implementation DailyDoManager

static DailyDoManager *_sharedManager;
+ (DailyDoManager *)sharedManager
{
    @synchronized(self) {
        if (_sharedManager == nil) {
            _sharedManager = [[DailyDoManager alloc] init];
        }
    }
    return _sharedManager;
}

- (NSArray *)propertiesForDoName:(NSString *)doName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:doName ofType:@"plist"];
    if (path) {
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
        return [root objectForKey:@"Properties"];
    }
    else {
        return nil;
    }
}

- (NSDictionary *)configurationsForDoName:(NSString *)doName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:doName ofType:@"plist"];
    if (path) {
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
        return [root objectForKey:@"Configurations"];
    }
    else {
        return nil;
    }
}

- (NSDictionary *)propertiesDictForProperties:(NSArray *)properties inDailyDo:(DailyDoBase *)dailyDo
{
    NSDictionary *properties_aps = [dailyDo properties_apsWithStopSuper:[DailyDoBase class]];
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    
    for (NSDictionary *property in properties) {
        NSString *name = [property objectForKey:kPropertyNameKey];
        id value = [properties_aps objectForKey:name];
        if (value) {
            [ret setObject:value forKey:name];
        }
    }
    
    return ret;
}

- (NSString *)sloganForDoName:(NSString *)doName
{
    NSString *tString = [[self configurationsForDoName:doName] objectForKey:kConfigurationSlogan];
    return NSLocalizedString(tString, nil);
}

#pragma mark - DailyDos

- (BOOL)saveDailyDoWithAddon:(AddonData *)addon updateDictionary:(NSDictionary *)aDictionary
{
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    DailyDoBase *data = [DailyDoData insertEntityWithDictionary:aDictionary syncrhonizeWithStore:NO];
    data.addon = addon;
    return [[KMModelManager sharedManager] saveContext:nil];
}

- (void)moveDailyDoUndos:(DailyDoBase *)dailyDo toAnother:(DailyDoBase *)anotherDailyDo
{
    NSArray *todoList = [[dailyDo todosSortedByIndex] copy];
    int index = [anotherDailyDo.todos count] - 1;
    for (TodoData *todo in todoList) {
        if (![todo.check boolValue]) {
            todo.dailyDo = anotherDailyDo;
            todo.index = [NSNumber numberWithInt:index];
            
            index ++;
        }
    }
    
    [dailyDo reorderTodos:NO];
    [anotherDailyDo reorderTodos:NO];
    [[KMModelManager sharedManager] saveContext:nil];
}

- (id)tomorrowDoForAddon:(AddonData *)addon
{
    NSTimeInterval lessThan = [[[[NSDate date] sameTimeTomorrow] midnight] timeIntervalSince1970];
    NSTimeInterval greaterThanOrEqual = [[[[NSDate date] sameTimeTomorrow] morning] timeIntervalSince1970];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                 lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                          lessThanOrEqualQueries:nil
                                                              greaterThanQueries:nil
                                                       greaterThanOrEqualQueries:@{@"createTime" : [NSNumber numberWithDouble:greaterThanOrEqual]}
                                                                 notEqualQueries:nil
                                                               entityDescription:[DailyDoData entityDescription]
                                                                      unFaulting:NO
                                                                          offset:0
                                                                           count:1
                                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                           error:&error];
    
    DailyDoBase *dailyDo = nil;
    if (!error && [dailyDos count] > 0) {
        dailyDo = [dailyDos objectAtIndex:0];
    }
    else {
        dailyDo = [DailyDoData dataEntityWithInsert:YES];
        dailyDo.addon = addon;
        dailyDo.createTime = [NSNumber numberWithDouble:[[[NSDate date] sameTimeTomorrow] timeIntervalSince1970]];
        [[KMModelManager sharedManager] saveContext:nil];
    }
    
    return dailyDo;
}

- (id)todayDoForAddon:(AddonData *)addon
{
    NSTimeInterval lessThan = [[[NSDate date] midnight] timeIntervalSince1970];
    NSTimeInterval greaterThanOrEqual = [[[NSDate date] morning] timeIntervalSince1970];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                               lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                        lessThanOrEqualQueries:nil
                                                            greaterThanQueries:nil
                                                     greaterThanOrEqualQueries:@{@"createTime" : [NSNumber numberWithDouble:greaterThanOrEqual]}
                                                               notEqualQueries:nil
                                                             entityDescription:[DailyDoData entityDescription]
                                                                    unFaulting:NO
                                                                        offset:0
                                                                         count:1
                                                               sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                         error:&error];
    
    DailyDoBase *dailyDo = nil;
    if (!error && [dailyDos count] > 0) {
        dailyDo = [dailyDos objectAtIndex:0];
    }
    else {
        dailyDo = [DailyDoData dataEntityWithInsert:YES];
        dailyDo.addon = addon;
        [[KMModelManager sharedManager] saveContext:nil];
    }
    
    return dailyDo;
}

- (NSArray *)loggedDosForAddon:(AddonData *)addon
{
    NSTimeInterval lessThan = [[[NSDate date] morning] timeIntervalSince1970];
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                 lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                          lessThanOrEqualQueries:nil
                                                              greaterThanQueries:nil
                                                       greaterThanOrEqualQueries:nil
                                                                 notEqualQueries:nil
                                                               entityDescription:[DailyDoData entityDescription]
                                                                      unFaulting:NO
                                                                          offset:0
                                                                           count:NSIntegerMax
                                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                           error:&error];
    
    if (!error) {
        return dailyDos;
    }
    else {
        return nil;
    }
}

- (void)loadLoggedDosForCondition:(NSDictionary *)condition
{
    int count = [[condition objectForKey:kDailyDoManagerLoadConditionCountKey] intValue];
    BOOL isLoadMore = [[condition objectForKey:kDailyDoManagerLoadConditionIsLoadMoreKey] boolValue];
    AddonData *addon = [condition objectForKey:kDailyDoManagerLoadConditionAddonKey];
    
    NSTimeInterval lessThan = 0.f;
    if (isLoadMore) {
        lessThan = [[condition objectForKey:kDailyDoManagerLoadConditionMinCreateTimeKey] doubleValue];
    }
    else {
        lessThan = [[[NSDate date] morning] timeIntervalSince1970];
    }
    
    Class DailyDoData = NSClassFromString(addon.dailyDoName);
    
    NSError *error = nil;
    NSArray *dailyDos = [[KMModelManager sharedManager] entitiesWithEqualQueries:nil
                                                                 lessThanQueries:@{@"createTime" : [NSNumber numberWithDouble:lessThan]}
                                                          lessThanOrEqualQueries:nil
                                                              greaterThanQueries:nil
                                                       greaterThanOrEqualQueries:nil
                                                                 notEqualQueries:nil
                                                               entityDescription:[DailyDoData entityDescription]
                                                                      unFaulting:NO
                                                                          offset:0
                                                                           count:count
                                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]
                                                                           error:&error];
    
    NSMutableDictionary *mutUserInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *mutResult = [NSMutableDictionary dictionaryWithCapacity:5];
    if (!error) {
        [mutResult setObject:dailyDos forKey:kDailyDoManagerLoadResultDataListKey];
    }
    else {
        [mutResult setObject:error forKey:kDailyDoManagerLoadResultErrorKey];
    }
    
    [mutUserInfo setObject:[mutResult copy] forKey:kDailyDoManagerLoggedLoadResultKey];
    [mutUserInfo setObject:condition forKey:kDailyDoManagerLoggedDosLoadConditionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DailyDoManagerLoggedDosLoadFinishedNotification object:self userInfo:[mutUserInfo copy]];
}

@end