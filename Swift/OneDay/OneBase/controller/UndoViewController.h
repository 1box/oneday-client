//
//  UndosViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AddonData;

@interface UndoViewController : KMViewControllerBase

@property (nonatomic) AddonData *addon;

// 移动所有未完成项目到今天
- (IBAction)moveUndosToToday:(id)sender;
- (IBAction)checkAll:(id)sender;

@end
