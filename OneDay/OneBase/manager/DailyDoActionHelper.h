//
//  DailyDoActionHelper.h
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DailyDoActionType) {
    DailyDoActionTypeMoveToTomorrow = 1UL,
    DailyDoActionTypeQuickAdd = (1UL << 1),
    DailyDoActionTypeShowAllUndos = (1UL << 2)
};


@class DailyDoBase;
@class AddonData;
@class DailyDoActionHelper;


@protocol DailyDoActionHelperDelegate <NSObject>
@optional
- (void)dailyDoActionHelper:(DailyDoActionHelper *)helper doActionForType:(DailyDoActionType)actionType;
@end


@interface DailyDoActionHelper : NSObject

@property (nonatomic, unsafe_unretained) id<DailyDoActionHelperDelegate> delegate;

+ (DailyDoActionHelper *)sharedHelper;

- (void)move:(DailyDoBase *)todayDo toTomorrow:(DailyDoBase *)tomorrowDo;
- (void)quickAddTodo:(DailyDoBase *)dailyDo;
- (void)showAllUndos:(AddonData *)addon;

@end
