//
//  DailyDoTomorrowCell.m
//  OneDay
//
//  Created by Yu Tianhang on 13-2-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DailyDoTomorrowCell.h"
#import "DailyDoBase.h"
#import "KMDateUtils.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoPresentView.h"

#define TopPadding 14.f
#define DateLabelRightMargin 7.f
#define CompleteLabelWidth 195.f
#define PresentViewWidth 255.f

@implementation DailyDoTomorrowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo unfolded:(BOOL)unfolded
{
    CGFloat completeHeight = heightOfContent(dailyDo.completionText, CompleteLabelWidth, 13.f);
    CGFloat ret = TopPadding*2 + completeHeight;
    if (unfolded) {
        ret += [DailyDoPresentView heightOfCellForDailyDo:dailyDo];
    }
    return ret;
}

- (void)refreshUI
{
    _presentView.hidden = !self.isUnfolded;
    
    CGRect vFrame = self.bounds;
    vFrame.size.height = [DailyDoTomorrowCell heightOfCellForDailyDo:_tomorrowDo unfolded:self.unfolded];
    
    [_dateLabel sizeToFit];
    [_tomorrowDoLabel heightThatFitsWidth:CompleteLabelWidth];
    
    CGRect tmpFrame = _dateLabel.frame;
    tmpFrame.origin.x = 35.f;
    tmpFrame.origin.y = TopPadding;
    _dateLabel.frame = tmpFrame;
    
    tmpFrame = _tomorrowDoLabel.frame;
    tmpFrame.origin.x = CGRectGetMaxX(_dateLabel.frame) + DateLabelRightMargin;
    tmpFrame.origin.y = TopPadding;
    _tomorrowDoLabel.frame = tmpFrame;
    
    if (self.isUnfolded) {
        tmpFrame.origin.x = CGRectGetMinX(_dateLabel.frame);
        tmpFrame.origin.y = CGRectGetMaxY(_tomorrowDoLabel.frame) + TopPadding;
        tmpFrame.size.width = PresentViewWidth;
        tmpFrame.size.height = [DailyDoPresentView heightOfCellForDailyDo:_tomorrowDo];//vFrame.size.height - CGRectGetMaxY(_tomorrowDoLabel.frame) - TopPadding;
        _presentView.frame = tmpFrame;
        
        [_presentView refreshUI];
    }
}

- (void)setTomorrowDo:(DailyDoBase *)tomorrowDo
{
    _tomorrowDo = tomorrowDo;
    if (_tomorrowDo) {
        _dateLabel.text = [MonthToDayFormatter() stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_tomorrowDo.createTime doubleValue]]];
        _tomorrowDoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"_tomorrowDoText", nil), [_tomorrowDo.todos count]];
        _presentView.dailyDo = _tomorrowDo;
    }
}
@end
