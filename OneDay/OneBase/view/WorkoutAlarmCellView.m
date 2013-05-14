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
        _alarmTypeLabel.text = [self alarmTypeText];
        _repeatLabel.text = [self repeatText];
        _noteLabel.text = _alarm.text;
    }
}

- (NSString *)alarmTypeText
{
    NSString *ret = @"";
    AlarmType alarmType = [_alarm.type integerValue];
    switch (alarmType) {
        case AlarmTypeGentle:
            ret = @"轻柔";
            break;
            case AlarmTypeNag:
            ret = @"唠叨";
            break;
            
        default:
            break;
    }
    return ret;
}

- (NSString *)repeatText
{
    AlarmRepeatType repeatType = [_alarm.repeatType integerValue];
    
    NSMutableString *repeatText = [NSMutableString stringWithCapacity:50];
    int dayCount = 0;
    
    if (AlarmRepeatTypeSunday == (AlarmRepeatTypeSunday&repeatType)) {
        [repeatText appendString:@"周日"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeMonday == (AlarmRepeatTypeMonday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周一"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeTuesday == (AlarmRepeatTypeTuesday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周二"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeWednesday == (AlarmRepeatTypeWednesday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周三"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeThursday == (AlarmRepeatTypeThursday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周四"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeFriday == (AlarmRepeatTypeFriday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周五"];
        dayCount ++;
    }
    
    if (AlarmRepeatTypeSaturday == (AlarmRepeatTypeSaturday&repeatType)) {
        if ([repeatText length] > 0) {
            [repeatText appendString:@" "];
        }
        [repeatText appendString:@"周六"];
        dayCount ++;
    }
    
    if (dayCount == 7) {
        return @"每天";
    }
    else {
        return [repeatText copy];
    }
}

@end
