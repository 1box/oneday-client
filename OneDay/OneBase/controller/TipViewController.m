//
//  SmarkTipViewController.m
//  OneDay
//
//  Created by Yu Tianhang on 12-12-24.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "TipViewController.h"
#import "NormalNavigationBarButton.h"
#import "AddonManager.h"
#import "AddonData.h"
#import "UIScrollView+SVPullToRefresh.h"

#define NumberOfMainTips 1
#define NumberOfMoreTips 0


@interface TipViewController () <UIWebViewDelegate> {
    NSInteger _currentPage;
}
@property (nonatomic) IBOutlet UIWebView *tipView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end


@implementation TipViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"TipPage_%@", _currentAddon.dailyDoName];
}

#pragma mark - ViewLifecycles

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadTextFromFileName:NSLocalizedString(@"smark_tip_file_name", nil)];
}

#pragma mark - extended

- (void)preparePullDownAction
{
    if (self.isPresented) {
        [self renderPullToDismiss:self.tipView.scrollView];
    }
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (void)loadTextFromFileName:(NSString *)name
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];
    NSString *rawText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_tipView loadHTMLString:rawText baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_indicator startAnimating];
    _indicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicator stopAnimating];
    _indicator.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_indicator stopAnimating];
    _indicator.hidden = YES;
}

@end
