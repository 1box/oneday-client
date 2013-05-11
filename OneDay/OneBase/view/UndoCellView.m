//
//  UndoCellView.m
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "UndoCellView.h"
#import "TodoData.h"
#import "KMModelManager.h"
#import "UILabel+UILabelAdditions.h"

@implementation UndoCellView

+ (CGFloat)heightForTodoData:(TodoData *)todo
{
    return heightOfContent([todo pureContent], 270, 13.f) + 20.f;
}

- (void)setTodo:(TodoData *)todo
{
    _todo = todo;
    if (_todo) {
        _contentLabel.text = [todo pureContent];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_todo) {
        [_contentLabel heightThatFitsWidth:SSWidth(self) - 50];
    }
}

- (IBAction)checkbox:(id)sender
{
    UIButton *checkBox = sender;
    checkBox.enabled = NO;
    
    _todo.check = @YES;
    [[KMModelManager sharedManager] saveContext:nil];
}

@end
