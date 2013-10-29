//
//  CalendarViewController.m
//  OneDay
//
//  Created by kimimaro on 13-10-29.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "CalendarViewController.h"
#import "MNCalendarView.h"
#import "DailyDoBase.h"
#import "AddonData.h"

@interface CalendarViewController () <MNCalendarViewDelegate>
@end

@implementation CalendarViewController

- (NSString *)pageNameForTrack
{
    if ([_dailyDos count] > 0) {
        DailyDoBase *dailyDo = [_dailyDos objectAtIndex:0];
        return [NSString stringWithFormat:@"TimelinePage_%@", dailyDo.addon.dailyDoName];
    }
    else {
        return [super pageNameForTrack];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.calendarView.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.calendarView.selectedDate = [NSDate date];
}

@end
