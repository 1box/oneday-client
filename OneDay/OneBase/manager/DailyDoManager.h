//
//  DailyDoManager.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPropertyNameKey @"name"
#define kProperyIconKey @"icon"
#define kPropertyTypeKey @"type"
#define kPropertyDisplayNameKey @"displayName"

#define PropertyTypeArray @"array"
#define ProperyTypeString @"string"
#define PropertyTypeDate @"date"
#define PropertyTypeTags @"tags"
#define PropertyTypeTodos @"todos"

#define kConfigurationDefaultUnfoldKey @"DefaultUnfold"
#define kConfigurationShowTimelineKey @"ShowTimeline"
#define kConfigurationSlogan @"Slogan"
#define kConfigurationTimelineTitle @"TimelineTitle"
#define kConfigurationPlaceHolder @"PlaceHolder"
#define kConfigurationShowQuickEntry @"ShowQuickEntry"
#define kConfigurationShowMoveToTomorrow @"ShowMoveToTomorrow"

@class AddonData;
@class DailyDoBase;
@class TodoData;

@interface DailyDoManager : NSObject
+ (DailyDoManager *)sharedManager;

// properties
- (NSArray *)propertiesForDoName:(NSString *)doName;
- (NSDictionary *)configurationsForDoName:(NSString *)doName;
- (NSDictionary *)propertiesDictForProperties:(NSArray *)properties inDailyDo:(DailyDoBase *)dailyDo;
- (NSString *)sloganForDoName:(NSString *)doName;

// dailydos
- (BOOL)saveDailyDoWithAddon:(AddonData *)addon updateDictionary:(NSDictionary *)aDictionary;
- (void)moveDailyDoUndos:(DailyDoBase *)dailyDo toAnother:(DailyDoBase *)anotherDailyDo;

- (id)tomorrowDoForAddon:(AddonData *)addon;
- (id)todayDoForAddon:(AddonData *)addon;
- (NSArray *)loggedDosForAddon:(AddonData *)addon;
@end
