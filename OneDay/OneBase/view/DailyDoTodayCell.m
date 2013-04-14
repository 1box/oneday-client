//
//  AddonListCellBase.m
//  OneDay
//
//  Created by Yu Tianhang on 12-10-29.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoTodayCell.h"
#import "DailyDoBase.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoManager.h"
#import "KMDateUtils.h"
#import "DailyDoDateView.h"
#import "DailyDoPresentView.h"

#define LeftPadding 5.f
#define DateViewWidth 255.f
#define PresentViewWidth 255.f
#define DateViewBottomMargin 7.f

@interface DailyDoTodayCell ()
@end

@implementation DailyDoTodayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfold:(BOOL)unfold
{
    CGFloat ret = 0.f;
    ret += [DailyDoDateView heightForDailyDo:dailyDo fixWidth:DateViewWidth];
    if (!unfold) {
        CGFloat presentHeight = [DailyDoPresentView heightOfCellForDailyDo:dailyDo];
        if (presentHeight > 0) {
            ret += presentHeight + DateViewBottomMargin;
        }
    }
    return ret;
}

- (void)refreshUI
{
    _presentView.hidden = self.isUnfolded;
    
    CGRect vFrame = self.bounds;
    vFrame.size.height = [DailyDoTodayCell heightOfCellForDailyDo:_dailyDo unfold:self.isUnfolded];
    
    CGFloat dateViewHeight = [DailyDoDateView heightForDailyDo:_dailyDo fixWidth:DateViewWidth];
    
    CGRect tmpFrame = _checkbox.frame;
    tmpFrame.origin.x = LeftPadding;
    _checkbox.frame = tmpFrame;
    
    CGPoint tmpCenter = _checkbox.center;
    tmpCenter.y = dateViewHeight/2;
    _checkbox.center = tmpCenter;
    
    tmpFrame = CGRectMake(0, 0, DateViewWidth, dateViewHeight);
    tmpFrame.origin.x = CGRectGetMaxX(_checkbox.frame);
    _dateView.frame = tmpFrame;
    [_dateView refreshUI];
   
    if (!self.isUnfolded) {
        CGFloat presentHeight = [DailyDoPresentView heightOfCellForDailyDo:_dailyDo];
        
        tmpFrame.origin.x = CGRectGetMaxX(_checkbox.frame);
        tmpFrame.origin.y = CGRectGetMaxY(_dateView.frame) + DateViewBottomMargin;
        tmpFrame.size.width = PresentViewWidth;
        tmpFrame.size.height = presentHeight;
        _presentView.frame = tmpFrame;
        
        [_presentView refreshUI];
    }
}

#pragma mark - Actions

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    
    if (_dailyDo) {
        _checkbox.selected = [_dailyDo.check boolValue];
        _dateView.dailyDo = _dailyDo;
        _presentView.dailyDo = _dailyDo;
    }
}

@end
