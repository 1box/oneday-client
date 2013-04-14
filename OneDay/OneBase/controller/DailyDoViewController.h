//
//  MainViewController.h
//  Drawus
//
//  Created by Tianhang Yu on 12-3-21.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DailyDoView;
@class AddonData;

@interface DailyDoViewController : UIViewController
@property (nonatomic, retain) IBOutlet DailyDoView *dailyDoView;
@property (nonatomic, retain) AddonData *addon;

- (IBAction)dismiss:(id)sender;
@end
