//
//  DailyCalendarView.m
//  OneDay
//
//  Created by kimimaro on 13-10-31.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyCalendarView.h"
#import "CalendarDayCellView.h"

@implementation DailyCalendarView

#pragma mark - extended

- (void)registerUICollectionViewClasses
{
    self.dayCellClass = [CalendarDayCellView class];
    [super registerUICollectionViewClasses];
}

#pragma mark - public

- (void)scrollToSelectedDate:(ScrollFinishedBlock)aBlock
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.collectionView scrollRectToVisible:CGRectMake(0, DailyCalendarBeforeDays * 10.f + 8.f, SSWidth(self), SSHeight(self)) animated:NO];
                     }
                     completion:^(BOOL finished) {
                         aBlock();
                     }];
}

@end