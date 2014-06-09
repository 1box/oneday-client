//
//  CalendarDayCellView.m
//  OneDay
//
//  Created by kimimaro on 13-10-31.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "CalendarDayCellView.h"
#import "DailyDoManager.h"
#import "AddonData.h"
//#import "DailyDoBase.h"
#import "DailyPeriod.h"
#import "UIView+BottomMark.h"
#import "UIColor+UIColorAddtions.h"

#define BottomMarkViewTag 20093
#define EventMarkViewTag 20094

@implementation CalendarDayCellView

- (void)setDate:(NSDate *)date month:(NSDate *)month calendar:(NSCalendar *)calendar
{
    [super setDate:date month:month calendar:calendar];
    
    // clear pre marks
    UIView *preBottomMark = [self viewWithTag:BottomMarkViewTag];
    if (preBottomMark) {
        [preBottomMark removeFromSuperview];
    }
    UIView *preEventMark = [self viewWithTag:EventMarkViewTag];
    if (preEventMark) {
        [preEventMark removeFromSuperview];
    }
    
    if (self.enabled) {
//    Class DailyDoData = NSClassFromString(_addon.dailyDoName);
        ECalendarCellMarkType type = [DailyPeriod calendarCellMarkType:date];
        
        UIColor *markColor = nil;
        BOOL isEvent = NO;
        switch (type) {
            case ECalendarCellMarkTypeBlueColor:
                markColor = BlueMarkColor;
                break;
            case ECalendarCellMarkTypePinkColor:
                markColor = PinkMarkColor;
                break;
            case ECalendarCellMarkTypeBlueColorWithEvent:
            {
                markColor = BlueMarkColor;
                isEvent = YES;
            }
                break;
            default:
                break;
        }
        
        if (markColor) {
            UIView *bottomMark = [self renderBottomMarkWithColor:markColor];
            bottomMark.tag = BottomMarkViewTag;
            
            if (isEvent) {
                UIImageView *eventMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_event_eggday"]];
                eventMark.tag = EventMarkViewTag;
                CGFloat eventMarkWidth = SSHeight(bottomMark) - 0.4f;
                eventMark.frame = CGRectMake(SSMinX(bottomMark) + 0.1f,
                                             SSMinY(bottomMark) + (SSHeight(bottomMark) - eventMarkWidth)/2,
                                             eventMarkWidth,
                                             eventMarkWidth);
                [self addSubview:eventMark];
            }
        }
    }
}

@end
