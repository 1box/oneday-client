//
//  NormalNavigationBar.m
//  OneDay
//
//  Created by Kimimaro on 13-4-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "NormalNavigationBar.h"

@implementation NormalNavigationBar

- (void)awakeFromNib
{
    UIImage *navImage = [UIImage imageNamed:@"light_nav_bg.png"];
    navImage = [navImage stretchableImageWithLeftCapWidth:navImage.size.width/2 topCapHeight:navImage.size.height/2];
    [self setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
}

@end
