//
//  UIView+BottomMark.m
//  OneDay
//
//  Created by kimimaro on 13-10-31.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+BottomMark.h"

#define BottomMarkViewTag 10002
#define BottomMarkViewHeightRatio 0.25f
#define BottomMarkPadding 1.5f
#define BottomMarkCornerRadius 1.5f

@implementation UIView (BottomMark)

- (UIView *)renderBottomMarkWithColor:(UIColor *)color
{
    UIView *bottomMark = [self viewWithTag:BottomMarkViewTag];
    if (!bottomMark) {
        bottomMark = [[UIView alloc] init];
        bottomMark.tag = BottomMarkViewTag;
        [self addSubview:bottomMark];
    }
    
    bottomMark.frame = CGRectMake(BottomMarkPadding,
                                  SSHeight(self)*(1 - BottomMarkViewHeightRatio) - BottomMarkPadding,
                                  SSWidth(self) - 2*BottomMarkPadding,
                                  SSHeight(self)*BottomMarkViewHeightRatio);
    bottomMark.layer.cornerRadius = BottomMarkCornerRadius;
    bottomMark.backgroundColor = color;
    [self bringSubviewToFront:bottomMark];
    
    return bottomMark;
}

@end
