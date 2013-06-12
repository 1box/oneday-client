//
//  LoggedDoListCell.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-1.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoLoggedCell.h"
#import "DailyDoBase.h"
#import "KMDateUtils.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoPresentView.h"
#import "KMModelManager.h"
#import "UIView+CornerMark.h"

#define TopPadding 14.f
#define DateLabelRightMargin 7.f
#define CompleteLabelWidth 195.f
#define PresentViewWidth 255.f

@implementation DailyDoLoggedCell

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
    vFrame.size.height = [DailyDoLoggedCell heightOfCellForDailyDo:_loggedDo unfolded:self.unfolded];
    
    [_dateLabel sizeToFit];
    [_completeLabel heightThatFitsWidth:CompleteLabelWidth];
    
    CGRect tmpFrame = _dateLabel.frame;
    tmpFrame.origin.x = 35.f;
    tmpFrame.origin.y = TopPadding;
    _dateLabel.frame = tmpFrame;
    
    tmpFrame = _completeLabel.frame;
    tmpFrame.origin.x = CGRectGetMaxX(_dateLabel.frame) + DateLabelRightMargin;
    tmpFrame.origin.y = TopPadding;
    _completeLabel.frame = tmpFrame;
    
    if (self.isUnfolded) {
        tmpFrame.origin.x = CGRectGetMinX(_dateLabel.frame);
        tmpFrame.origin.y = CGRectGetMaxY(_completeLabel.frame) + TopPadding;
        tmpFrame.size.width = PresentViewWidth;
        tmpFrame.size.height = vFrame.size.height - CGRectGetMaxY(_completeLabel.frame) - TopPadding;
        
        _presentView.frame = tmpFrame;
        
        [_presentView refreshUI];
    }
    
    CornerMarkColorType color = CornerMarkColorTypeOrange;
    if ([[NSDate dateWithTimeIntervalSince1970:[_loggedDo.createTime doubleValue]] isTypicallyWorkday]) {
        color = CornerMarkColorTypeCyan;
    }
    UIImageView *markView = [self renderCornerMark:color scaleType:CornerMarkScaleTypeSmall isFavorite:NO];
    
    CGFloat topMargin = 0.f;
    if (self.locationType == KMTableViewCellLocationTypeAlone || self.locationType == KMTableViewCellLocationTypeTop) {
        topMargin = 1.f;
    }
    setFrameWithOrigin(markView, SSWidth(self) - SSWidth(markView) - 11, topMargin);
}

- (void)setLoggedDo:(DailyDoBase *)loggedDo
{
    _loggedDo = loggedDo;
    if (_loggedDo) {
        _checkbox.enabled = ![_loggedDo.check boolValue] && [_loggedDo.todos count] > 0;
        _dateLabel.text = [MonthToDayWFormatter() stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_loggedDo.createTime doubleValue]]];
        _completeLabel.text = [_loggedDo completionText];
        _presentView.dailyDo = _loggedDo;
    }
}

#pragma mark - Actions

- (IBAction)checkbox:(id)sender
{
    if (![_loggedDo.check boolValue]) {
        for (TodoData *tTodo in _loggedDo.todos) {
            [tTodo setCheck:@YES];
        }
        [[KMModelManager sharedManager] saveContext:nil];
        
        _checkbox.enabled = NO;
        _completeLabel.text = [_loggedDo completionText];
        [self refreshUI];
    }
}

@end
