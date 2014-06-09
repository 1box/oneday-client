//
//  UIView+BottomMark.h
//  OneDay
//
//  Created by kimimaro on 13-10-31.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PinkMarkColor [UIColor colorWithHexString:@"ffb2cf"]
#define BlueMarkColor [UIColor colorWithHexString:@"d6ddff"]

@interface UIView (BottomMark)
- (UIView *)renderBottomMarkWithColor:(UIColor *)color;
@end
