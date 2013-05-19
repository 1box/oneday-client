//
//  NavigationBarButton.m
//  OneDay
//
//  Created by Kimimaro on 13-4-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "NavigationBarButton.h"

@implementation NavigationBarButton

- (void)awakeFromNib
{
    UIImage *backgroundImage = [UIImage imageNamed:@"light_nav_btn_bg.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
    UIImage *pressBackgroundImage = [UIImage imageNamed:@"light_nav_btn_bg_press.png"];
    pressBackgroundImage = [pressBackgroundImage stretchableImageWithLeftCapWidth:pressBackgroundImage.size.width/2 topCapHeight:pressBackgroundImage.size.height/2];
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [self setBackgroundImage:pressBackgroundImage forState:UIControlStateHighlighted];
}

@end
