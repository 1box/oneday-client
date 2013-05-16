//
//  AddAlarmViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class AddonData;
@class KMTableView;

@interface AddAlarmViewController : KMViewControllerBase

@property (nonatomic) IBOutlet KMTableView *listView;
@property (nonatomic) IBOutlet UIDatePicker *timePicker;
@property (nonatomic) IBOutlet UISwitch *alarmTypeSwitch;

@property (nonatomic) AddonData *addon;

- (IBAction)save:(id)sender;
- (IBAction)switchAlarmType:(id)sender;
@end
