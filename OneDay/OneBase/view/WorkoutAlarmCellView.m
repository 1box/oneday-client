//
//  WorkoutAlarmCellView.m
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "WorkoutAlarmCellView.h"
#import "AlarmData.h"
#import "KMDateUtils.h"


@interface WorkoutAlarmCellView ()
@property (nonatomic) IBOutlet UILabel *AMPMLabel;
@property (nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) IBOutlet UILabel *alarmTypeLabel;
@property (nonatomic) IBOutlet UILabel *repeatLabel;
@property (nonatomic) IBOutlet UILabel *noteLabel;
@property (nonatomic) IBOutlet UISwitch *openSwitch;
@end


@implementation WorkoutAlarmCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setAlarm:(AlarmData *)alarm
{
    _alarm = alarm;
    if (_alarm) {
        NSString *timeA = [HourToMiniteAFormatter() stringFromDate:[HourToMiniteAFormatter() dateFromString:_alarm.alarmTime]];
        _AMPMLabel.text = [timeA substringFromIndex:5];
        _timeLabel.text = [timeA substringToIndex:4];
        _alarmTypeLabel.text = [_alarm alarmTypeText];
        _repeatLabel.text = [_alarm repeatText];
        _noteLabel.text = _alarm.text;
    }
}


@end
