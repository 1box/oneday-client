//
//  CalendarViewController.h
//  OneDay
//
//  Created by kimimaro on 13-10-29.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@class MNCalendarView;

@interface CalendarViewController : KMViewControllerBase
@property (nonatomic, strong) IBOutlet MNCalendarView *calendarView;
@property (nonatomic) NSArray *dailyDos;
@end
