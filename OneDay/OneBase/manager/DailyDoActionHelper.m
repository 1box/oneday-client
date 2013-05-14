//
//  DailyDoActionHelper.m
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyDoActionHelper.h"
#import "KMAlertView.h"
#import "MTStatusBarOverlay.h"
#import "DailyDoManager.h"
#import "KMModelManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"

#define kMoveToTomorrowUserInfoTodayDoKey @"kMoveToTomorrowUserInfoTodayDoKey"
#define kMoveToTomorrowUserInfoTomorrowDoKey @"kMoveToTomorrowUserInfoTomorrowDoKey"

#define kQuickAddUserInfoDailyDoKey @"kQuickAddUserInfoDailyDoKey"


@interface DailyDoActionHelper () <UIAlertViewDelegate, KMAlertViewDelegate>
@property (nonatomic) NSDictionary *moveToTomorrowUserInfo;
@end


@implementation DailyDoActionHelper

static DailyDoActionHelper *_sharedHelper = nil;
+ (DailyDoActionHelper *)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHelper = [[DailyDoActionHelper alloc] init];
    });
    return _sharedHelper;
}

+ (id)alloc
{
    NSAssert(_sharedHelper == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - Actions

- (void)move:(DailyDoBase *)todayDo toTomorrow:(DailyDoBase *)tomorrowDo
{
    if ([todayDo.check boolValue] || [todayDo.todos count] == 0) {
        [[MTStatusBarOverlay sharedOverlay] postErrorMessage:NSLocalizedString(@"NoUndoToTomorrowMessage", nil) duration:2.f];
    }
    else {
        NSMutableString *undoString = [NSMutableString string];
        for (int i=0; i < [todayDo.todos count]; i++) {
            if (i != [todayDo.todos count] - 1) {
                [undoString appendString:@" "];
            }
            
            TodoData *todo = [[todayDo todosSortedByIndex] objectAtIndex:i];
            if (![todo.check boolValue]) {
                [undoString appendFormat:@"%d. %@", i + 1, todo.content];
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"MoveToTomorrowMessage", nil), undoString]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"MoveToTomorrow", nil), nil];
        
        self.moveToTomorrowUserInfo = @{kMoveToTomorrowUserInfoTodayDoKey : todayDo,
                                        kMoveToTomorrowUserInfoTomorrowDoKey : tomorrowDo};
        
        [alert show];
    }
    
}

- (void)quickAddTodo:(DailyDoBase *)dailyDo
{
    KMAlertView *quickAlert = [[KMAlertView alloc] initWithTitle:NSLocalizedString(dailyDo.addon.dailyDoName, nil)
                                                        messages:@[NSLocalizedString(@"_quickEntryMessage", nil)]
                                                        delegate:self];
    quickAlert.userInfo = @{kQuickAddUserInfoDailyDoKey : dailyDo};
    [quickAlert show];
}

- (void)showAllUndos:(AddonData *)addon
{
    if (_delegate && [_delegate respondsToSelector:@selector(dailyDoActionHelper:doActionForType:)]) {
        [_delegate dailyDoActionHelper:self doActionForType:DailyDoActionTypeShowAllUndos];
    }
}

- (void)showCashMonthSummary
{
    if (_delegate && [_delegate respondsToSelector:@selector(dailyDoActionHelper:doActionForType:)]) {
        [_delegate dailyDoActionHelper:self doActionForType:DailyDoActionTypeCashMonthSummary];
    }
}

- (void)showCashYearSummary
{
    if (_delegate && [_delegate respondsToSelector:@selector(dailyDoActionHelper:doActionForType:)]) {
        [_delegate dailyDoActionHelper:self doActionForType:DailyDoActionTypeCashYearSummary];
    }
}

- (void)showWorkoutAlarms
{
    if (_delegate && [_delegate respondsToSelector:@selector(dailyDoActionHelper:doActionForType:)]) {
        [_delegate dailyDoActionHelper:self doActionForType:DailyDoActionTypeWorkoutNotification];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSDictionary *userInfo = _moveToTomorrowUserInfo;
        DailyDoBase *todayDo = [userInfo objectForKey:kMoveToTomorrowUserInfoTodayDoKey];
        DailyDoBase *tomorrowDo = [userInfo objectForKey:kMoveToTomorrowUserInfoTomorrowDoKey];
        
        [[DailyDoManager sharedManager] moveDailyDoUndos:todayDo toAnother:tomorrowDo];
        
        if (_delegate && [_delegate respondsToSelector:@selector(dailyDoActionHelper:doActionForType:)]) {
            [_delegate dailyDoActionHelper:self doActionForType:DailyDoActionTypeMoveToTomorrow];
        }
    }
}

#pragma mark - KMAlertViewDelegate

- (void)kmAlertView:(KMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *tContent = alertView.textView.text;
        if (!KMEmptyString(tContent)) {
            
            NSDictionary *userInfo = alertView.userInfo;
            DailyDoBase *dailyDo = [userInfo objectForKey:kQuickAddUserInfoDailyDoKey];
            
            NSArray *properties = [[DailyDoManager sharedManager] propertiesForDoName:dailyDo.addon.dailyDoName];
            NSDictionary *configurations = [[DailyDoManager sharedManager] configurationsForDoName:dailyDo.addon.dailyDoName];
            
            NSString *quickAddPropertyName = [configurations objectForKey:kConfigurationQuickAddPropertyName];
            NSDictionary *quickAddProperty = nil;
            for (NSDictionary *property in properties) {
                if ([[property objectForKey:kPropertyNameKey] isEqualToString:quickAddPropertyName]) {
                    quickAddProperty = property;
                }
            }
            
            if ([[quickAddProperty objectForKey:kPropertyTypeKey] isEqualToString:PropertyTypeTodos]) {
                
                TodoData *todo = [dailyDo insertNewTodoAtIndex:[dailyDo.todos count]];
                todo.content = tContent;
                [[KMModelManager sharedManager] saveContext:nil];
                [dailyDo detectTodos];
            }
            else if ([[quickAddProperty objectForKey:kPropertyTypeKey] isEqualToString:ProperyTypeString]) {
                
                [dailyDo setValue:tContent forKey:quickAddPropertyName];
                [[KMModelManager sharedManager] saveContext:nil];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(dailyDoActionHelper:doActionForType:)]) {
                [_delegate dailyDoActionHelper:self doActionForType:DailyDoActionTypeQuickAdd];
            }
        }
    }
}

@end
