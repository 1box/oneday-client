//
//  WorkoutAlarmViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AddonData;

@interface WorkoutAlarmViewController : KMViewControllerBase
@property (nonatomic) AddonData *addon;
- (IBAction)edit:(id)sender;
@end
