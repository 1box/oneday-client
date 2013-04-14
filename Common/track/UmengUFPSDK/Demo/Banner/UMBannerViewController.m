//
//  UMBannerViewController.m
//  UFP
//
//  Created by liu yu on 5/14/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMBannerViewController.h"

@implementation UMBannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"BannerView";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    banner = [[UMUFPBannerView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-320)/2, self.view.bounds.size.height-50, 320, 50) appKey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
    banner.mTextColor = [UIColor whiteColor];
    banner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//    banner.delegate = (id<UMUFPBannerViewDelegate>)self;
    [self.view addSubview:banner];
    [banner requestPromoterDataInBackground];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UMUFPBannerView delegate methods

//- (void)bannerWillAppear:(UMUFPBannerView *)_banner {
//    
//    _banner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.6f];
//    _banner.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    [UIView commitAnimations];
//    
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
//}

- (void)UMUFPBannerView:(UMUFPBannerView *)_banner didLoadDataFinish:(NSInteger)promotersAmount {
    
    NSLog(@"%s, amount:%d", __PRETTY_FUNCTION__, promotersAmount);    
}

- (void)UMUFPBannerView:(UMUFPBannerView *)_banner didClickedPromoterAtIndex:(NSInteger)index {
    
    NSLog(@"%s, index:%d", __PRETTY_FUNCTION__, index);    
}

- (void)UMUFPBannerView:(UMUFPBannerView *)banner didLoadDataFailWithError:(NSError *)error {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
