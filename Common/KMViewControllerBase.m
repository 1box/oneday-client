//
//  KMViewControllerBase.m
//  OneDay
//
//  Created by Kimimaro on 13-5-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

@interface KMViewControllerBase ()

@end

@implementation KMViewControllerBase

+ (NSString *)storyBoardID
{
    return @"";
}

- (NSString *)pageNameForTrack
{
    // should be extended
    return @"KMViewControllerBase";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [MobClick beginLogPageView:[self pageNameForTrack]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageNameForTrack]];
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
