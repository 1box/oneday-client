//
//  CalendarViewController.h
//  OneDay
//
//  Created by kimimaro on 13-10-29.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class DailyCalendarView;
@class AddonData;

@interface CalendarViewController : KMViewControllerBase
@property (nonatomic) IBOutlet DailyCalendarView *calendarView;
@property (nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) AddonData *addon;
@property (nonatomic) NSArray *dailyDos;
@end
