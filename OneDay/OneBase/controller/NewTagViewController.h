//
//  NewTagViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 12-11-3.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMTableView;
@class DailyDoBase;

@interface NewTagViewController : UIViewController
@property (nonatomic) IBOutlet KMTableView *listView;
@property (nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) DailyDoBase *dailyDo;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end
