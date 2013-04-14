//
//  UMANWebViewDemo.m
//  UMAppNetwork
//
//  Created by liu yu on 1/9/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMWebViewController.h"

@implementation UMWebViewController

@synthesize mWebView = _mWebView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"_recommendApp", nil);
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    
    UMUFPWebView *webView = [[UMUFPWebView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) appKey:@"4f7046375270156912000011" slotId:nil];
    self.mWebView = webView;
    _mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_mWebView setScalesPageToFit:YES];
    _mWebView.delegate = (id<UIWebViewDelegate>)self;

    [self.view addSubview:_mWebView];
    
    _mLoadingWaitView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mLoadingWaitView.backgroundColor = [UIColor lightGrayColor];
    _mLoadingWaitView.autoresizesSubviews = YES;
    _mLoadingWaitView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _mLoadingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-300)/2, 210, 300, 21)];
    _mLoadingStatusLabel.backgroundColor = [UIColor clearColor];
    _mLoadingStatusLabel.textColor = [UIColor whiteColor];
    _mLoadingStatusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    _mLoadingStatusLabel.text = @"正在加载数据，请稍等...";
    _mLoadingStatusLabel.textAlignment = NSTextAlignmentCenter;
    _mLoadingStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_mLoadingWaitView addSubview:_mLoadingStatusLabel];
    
    _mLoadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _mLoadingActivityIndicator.backgroundColor = [UIColor clearColor];
    _mLoadingActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mLoadingActivityIndicator.frame = CGRectMake((self.view.bounds.size.width-30)/2, 170, 30, 30);
    [_mLoadingWaitView addSubview:_mLoadingActivityIndicator];
    
    [_mLoadingActivityIndicator startAnimating];
        
    [self.view insertSubview:_mLoadingWaitView aboveSubview:self.mWebView];
    
    [self.mWebView startLoadRequest];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    _mWebView.frame = CGRectMake(0, frame.size.height, size.width, size.height - frame.size.height);
    
    if ([_mLoadingWaitView superview])
    {
        _mLoadingWaitView.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

- (void)removeLoadingMaskView {
    
    if ([_mLoadingWaitView superview])
    {        
        [_mLoadingWaitView removeFromSuperview];
    }
}

- (void)loadDataFailed {
    
    _mLoadingActivityIndicator.hidden = YES;
    
    if (!_mNoNetworkImageView)
    {
        UIImage *image = [UIImage imageNamed:@"um_no_network.png"];
        CGSize imageSize = image.size;
        _mNoNetworkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_mLoadingWaitView.bounds.size.width - imageSize.width) / 2, 80, imageSize.width, imageSize.height)];
        _mNoNetworkImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _mNoNetworkImageView.image = image;
    }
    
    if (![_mNoNetworkImageView superview])
    {
        [_mLoadingWaitView addSubview:_mNoNetworkImageView];
    }
    
    _mLoadingStatusLabel.text = @"抱歉，网络连接不畅，请稍后再试！";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self removeLoadingMaskView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    [self loadDataFailed];
}

@end
