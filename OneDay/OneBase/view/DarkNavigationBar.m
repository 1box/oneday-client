//
//  DarkNavigationBar.m
//  OneDay
//
//  Created by Kimimaro on 13-4-4.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DarkNavigationBar.h"

@implementation DarkNavigationBar

- (void)awakeFromNib
{
    [self setBackgroundImage:[UIImage imageNamed:@"dark_nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
}

@end
