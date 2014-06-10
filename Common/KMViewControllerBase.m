//
//  KMViewControllerBase.m
//  OneDay
//
//  Created by Kimimaro on 13-5-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"
#import "UIScrollView+SVPullToRefresh.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self preparePullDownAction];
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

#pragma mark - public

- (BOOL)isNavigationRoot
{
    return !self.navigationController || [self.navigationController.viewControllers objectAtIndex:0] == self;
}

- (BOOL)isPresented
{
    return ([self isNavigationRoot] && self.presentingViewController != nil);
}

#pragma mark - extend

- (void)preparePullDownAction
{
    // should be extended
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

#pragma mark - public

- (void)renderPullToDismiss:(UIScrollView *)scrollView
{
    __weak KMViewControllerBase *weakSelf = self;
//    __weak UIScrollView *weakScroll = scrollView;
    [scrollView addPullToRefreshWithActionHandler:^{
        [weakSelf dismiss:nil];
//        [weakScroll.pullToRefreshView stopAnimating];
    }];
}

@end
