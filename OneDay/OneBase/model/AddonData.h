//
//  AddonData.h
//  OneDay
//
//  Created by Kimi on 12-10-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSEntityBase.h"

@interface AddonData : SSEntityBase

@property (nonatomic, retain) NSString *dailyDoName;
@property (nonatomic, retain) NSNumber *orderIndex;
@property (nonatomic, retain) NSNumber *display;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *cartoon;
@property (nonatomic, retain) NSNumber *numberOfCartoons;
@property (nonatomic, retain) NSNumber *detectType;
@property (nonatomic, retain) NSNumber *showChecked;
@property (nonatomic, retain) NSString *tipImage;

@property (nonatomic, retain) NSSet *dailyDos;

+ (void)loadDefaultDataFromDefaultPlist;
@end
