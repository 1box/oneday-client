//
//  DailyDoManager.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DailyDoActionHelper.h"
#import "TodoData.h"

// -- properties
#define kPropertyNameKey @"name"
#define kProperyIconKey @"icon"
#define kPropertyTypeKey @"type"
#define kPropertyDisplayNameKey @"displayName"

#define PropertyTypeArray @"array"
#define ProperyTypeString @"string"
#define PropertyTypeDate @"date"
#define PropertyTypeTags @"tags"
#define PropertyTypeTodos @"todos"


// -- configurations
#define kConfigurationDefaultUnfoldKey @"DefaultUnfold"
#define kConfigurationShowTimelineKey @"ShowTimeline"
#define kConfigurationSlogan @"Slogan"
#define kConfigurationTimelineTitle @"TimelineTitle"
#define kConfigurationPlaceHolder @"PlaceHolder"
#define kConfigurationShowQuickEntry @"ShowQuickEntry"
#define kConfigurationActionType @"ActionType"
#define kConfigurationQuickAddPropertyName @"QuickAddPropertyName"
#define kConfigurationInputHelperWords @"InputHelperWords"
#define kConfigurationTodoTypeKey @"TodoType"

// timeline type
typedef NS_ENUM(NSInteger, ConfigurationTimelineType) {
    ConfigurationTimelineTypeTimeline = 0,
    ConfigurationTimelineTypeCalendar
};
#define kConfigurationTimelineType @"TimelineType"

// tip banner
typedef NS_ENUM(NSInteger, ConfigurationTipBannerType) {
    ConfigurationTipBannerTypeShowTimeline = 0
};

#define kConfigurationTipBannerDict @"TipBanner"
#define kConfigurationTipBannerDictTypeKey @"TipBannerType"
#define kConfigurationTipBannerDictContentTextKey @"ContentText"
#define kConfigurationTipBannerDictConfirmButtonTitleKey @"ConfirmButtonTitle"

#define kHasShowTipBannerDictUserDefaultKey @"kHasShowTipBannerDictUserDefaultKey"
static inline NSInteger showTipBannerTimes(NSString *dailyDoName) {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kHasShowTipBannerDictUserDefaultKey];
    
    NSInteger ret = 0;
    if (dict) {
        ret = [[dict objectForKey:dailyDoName] integerValue];
    }
    return ret;
}

static inline void addHasShowTipBannerTimes(NSString *dailyDoName) {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kHasShowTipBannerDictUserDefaultKey];
    NSInteger times = 0;
    if (dict) {
        times = [[dict objectForKey:dailyDoName] integerValue];
    }
    times ++;
    
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutDict setObject:@(times) forKey:dailyDoName];
    
    [[NSUserDefaults standardUserDefaults] setObject:mutDict forKey:kHasShowTipBannerDictUserDefaultKey];
}


#define DailyDoManagerLoggedDosLoadFinishedNotification @"DailyDoManagerLoggedDosLoadFinishedNotification"
#define kDailyDoManagerLoggedDosLoadConditionKey @"kDailyDoManagerLoggedDosLoadConditionKey"
#define kDailyDoManagerLoggedLoadResultKey @"kDailyDoManagerLoggedLoadResultKey"

#define kDailyDoManagerLoadConditionMaxCreateTimeKey @"kDailyDoManagerLoadConditionMaxCreateTimeKey"
#define kDailyDoManagerLoadConditionCountKey @"kDailyDoManagerLoadConditionCountKey"
#define kDailyDoManagerLoadConditionIsLoadMoreKey @"kDailyDoManagerLoadConditionIsLoadMoreKey"

#define kDailyDoManagerLoadConditionAddonKey @"kDailyDoManagerLoadConditionAddonKey"
#define kDailyDoManagerLoadResultDataListKey @"kDailyDoManagerLoadResultDataListKey"
#define kDailyDoManagerLoadResultErrorKey @"kDailyDoManagerLoadResultErrorKey"


@interface MonthlyDo : NSObject
@property (nonatomic) NSDate *currentMonth;
@property (nonatomic) NSArray *dailyDos;
@property (nonatomic) CGFloat summary;
@end


@interface YearlyDo : NSObject
@property (nonatomic) NSDate *currentYear;
@property (nonatomic) NSArray *dailyDos;
@property (nonatomic) CGFloat summary;
@end


@class AddonData;
@class DailyDoBase;
@class TodoData;

@interface DailyDoManager : NSObject

+ (DailyDoManager *)sharedManager;

// -- properties
- (NSArray *)propertiesForDoName:(NSString *)doName;
- (NSDictionary *)propertiesDictForProperties:(NSArray *)properties inDailyDo:(DailyDoBase *)dailyDo;

// -- configurations
- (NSDictionary *)configurationsForDoName:(NSString *)doName;
- (NSString *)sloganForDoName:(NSString *)doName;
- (NSArray *)inputHelperWordsForDoName:(NSString *)doName;
- (BOOL)isTodoType:(ODTodoType)todoType forDoName:(NSString *)doName;

// tip banner
- (BOOL)hasTipBannerForDoName:(NSString *)doName;
- (ConfigurationTipBannerType)tipBannerTypeForDoName:(NSString *)doName;
- (NSString *)tipBannerContentTextForDoName:(NSString *)doName;
- (NSString *)tipBannerConfirmButtonTitleForDoName:(NSString *)doName;

// -- dailydos
- (BOOL)saveDailyDoWithAddon:(AddonData *)addon updateDictionary:(NSDictionary *)aDictionary;
- (void)moveDailyDoUndos:(DailyDoBase *)dailyDo toAnother:(DailyDoBase *)anotherDailyDo;

- (id)tomorrowDoForAddon:(AddonData *)addon;
- (id)todayDoForAddon:(AddonData *)addon;
- (NSArray *)loggedDosForAddon:(AddonData *)addon;

- (void)loadLoggedDosForCondition:(NSDictionary *)condition;

- (DailyDoBase *)dailyDoInList:(NSArray *)dailyDos atDate:(NSDate *)date;

// -- monthlyDos&yearlyDos
- (NSArray *)monthlyDosForAddon:(AddonData *)addon year:(NSDate *)year;
- (NSArray *)yearlyDosForAddon:(AddonData *)addon;

@end
