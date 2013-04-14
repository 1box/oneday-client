//
//  TagData.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "SSEntityBase.h"

@class DailyDoBase;

@interface TagData : SSEntityBase

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSString *superTag;
@property (nonatomic, retain) NSNumber *createTime;

@property (nonatomic, retain) NSSet *dailyDos;
@end

@interface TagData (CoreDataGeneratedAccessors)

- (void)addDailyDosObject:(DailyDoBase *)value;
- (void)removeDailyDosObject:(DailyDoBase *)value;
- (void)addDailyDos:(NSSet *)values;
- (void)removeDailyDos:(NSSet *)values;
@end
