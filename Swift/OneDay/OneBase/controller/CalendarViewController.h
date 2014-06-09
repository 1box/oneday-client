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
// -- picker view
@property (nonatomic) IBOutlet UIView *pickerContainer;
@property (nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) IBOutlet UIButton *pickConfirmButton;
@property (nonatomic) IBOutlet UIButton *pickCancelButton;
@property (nonatomic) AddonData *addon;
@property (nonatomic) NSArray *dailyDos;
@property (nonatomic) BOOL showPickerWhenAppear;    // default NO
@end
