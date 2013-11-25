//
//  DailyCalendarView.h
//  OneDay
//
//  Created by kimimaro on 13-10-31.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "MNCalendarView.h"

//#warning debug code
#define DailyCalendarBeforeDays 60
#define DailyCalendarAfterDays 365


@interface DailyCalendarView : MNCalendarView
- (void)scrollToSelectedDate;
@end
