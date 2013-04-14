//
//  DailyDoBase.h
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "SSEntityBase.h"

#define kMakeDailyDoItemIDUserDefaultKey @"kMakeDailyDoItemIDUserDefaultKey"
static inline NSUInteger newDailyDoItemID() {
    NSUInteger makeID = [[NSUserDefaults standardUserDefaults] integerForKey:kMakeDailyDoItemIDUserDefaultKey] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:makeID forKey:kMakeDailyDoItemIDUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return makeID;
}

@class AddonData;
@class TodoData;

@interface DailyDoBase : SSEntityBase

@property (nonatomic, retain) NSNumber *itemID;
@property (nonatomic, retain) NSNumber *createTime; // eg. 978307200.0

@property (nonatomic, retain) AddonData *addon;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *todos;

@property (nonatomic, readonly) NSNumber *check;

- (NSArray *)todosSortedByIndex;
- (NSArray *)todosSortedByStartTime;

- (TodoData *)insertNewTodoAtIndex:(NSInteger)index;

/*!
 @return The second TodoData which been inserted.
 */
- (TodoData *)separateTodoAtIndex:(NSUInteger)index fromContentCharacterIndex:(NSUInteger)characterIndex;

- (BOOL)removeTodos:(NSArray *)todos;
- (BOOL)removeBlankTodos;

- (NSString *)todosTextWithLineNumber:(BOOL)withLineNumber;
- (NSUInteger)todoTextLengthFromIndex:(NSUInteger)start beforeIndex:(NSUInteger)end autoNumber:(BOOL)autoNumber;

- (BOOL)reorderTodos:(BOOL)save;
- (BOOL)detectTodos;

- (void)makeSnapshot;
- (BOOL)recoveryToSnapshot; // return NO if no snapshot or recovery failed

#pragma mark - protected
- (NSString *)presentedText;
- (NSString *)todayText;
- (NSString *)completionText;
@end
