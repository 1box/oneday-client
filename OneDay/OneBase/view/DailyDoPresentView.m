//
//  DailyDoPresentView.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-4.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoPresentView.h"
#import "DailyDoManager.h"
#import "DailyDoBase.h"
#import "TagData.h"
#import "TagTokenView.h"

#define TagBlockHeight 44.f
#define SelfWidth 255.f
#define TextViewTextFontSize 14.f
#define BottomPadding 10.f

@interface DailyDoPresentView ()
@property (nonatomic) NSMutableArray *tagTokens;
@end

@implementation DailyDoPresentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - public

+ (CGFloat)heightOfCellForDailyDo:(DailyDoBase *)dailyDo
{
    NSString *todoText = [dailyDo presentedText];
    CGFloat height = heightOfContent(todoText, SelfWidth, TextViewTextFontSize);
    CGFloat ret = height;
    if ([dailyDo.tags count] > 0) {
        ret += TagBlockHeight;
    }
    else if (height > 0) {
        ret += BottomPadding;
    }
    return ret;
}

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    CGFloat tHeight = vFrame.size.height;
    if ([_dailyDo.tags count] > 0) {
        tHeight -= TagBlockHeight;
    }
    else if (tHeight > 0) {
        tHeight -= BottomPadding;
    }
    
    tmpFrame.size.height = tHeight;
    _textView.frame = tmpFrame;
    
    if (_tagTokens == nil) {
        self.tagTokens = [NSMutableArray arrayWithCapacity:[_dailyDo.tags count]];
    }
    else {
        for (TagTokenView *tagToken in _tagTokens) {
            [tagToken removeFromSuperview];
        }
        [_tagTokens removeAllObjects];
    }
    
    if ([_dailyDo.tags count] > 0) {
        
        CGFloat subviewX = 0.f;
        for (TagData *tag in _dailyDo.tags) {
            TagTokenView *tagToken = [[TagTokenView alloc] initWithTag:NSLocalizedString(tag.name, nil)];
            tagToken.frame = CGRectMake(subviewX,
                                        CGRectGetMaxY(_textView.frame) + (TagBlockHeight - tagToken.bounds.size.height)/2,
                                        tagToken.frame.size.width,
                                        tagToken.frame.size.height);
            [self addSubview:tagToken];
            [_tagTokens addObject:tagToken];
            
            subviewX += tagToken.frame.size.width + 5.f;
        }
    }
}

#pragma mark - Actions

- (void)setDailyDo:(DailyDoBase *)dailyDo
{
    _dailyDo = dailyDo;
    if (_dailyDo) {
        _textView.text = [_dailyDo presentedText];
        _textView.font = FONT_DEFAULT(TextViewTextFontSize);
    }
}

@end
