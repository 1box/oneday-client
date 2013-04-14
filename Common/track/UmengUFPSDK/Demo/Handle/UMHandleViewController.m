//
//  UMHandleViewController.m
//  UFP
//
//  Created by liu yu on 8/1/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMHandleViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UMHandleViewController ()

@end

@implementation UMHandleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"HandleView";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    handleView = [[UMUFPHandleView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-88, 32, 88) appKey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
//    handleView_app.delegate = (id<UMUFPHandleViewDelegate>)self;
    handleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [handleView setHandleViewBackgroundImage:[UIImage imageNamed:@"um_handle_placeholder.png"]];
    [self.view addSubview:handleView];
    [handleView requestPromoterDataInBackground];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UMUFPHandleView delegate methods

//- (void)handleViewWillAppear:(UMUFPHandleView *)handleView {
//    
//    CATransition *animation = [CATransition animation]; 
//    animation.duration = 0.3f; 
//    animation.timingFunction = UIViewAnimationCurveEaseInOut; 
//    animation.fillMode = kCAFillModeBoth; 
//    animation.type = kCATransitionMoveIn; 
//    animation.subtype = kCATransitionFromTop; 
//    [handleView.layer addAnimation:animation forKey:@"animation"];
//}
//
//- (void)didClickHandleView:(UMUFPHandleView *)handleView {
//    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)didClickHandleView:(UMUFPHandleView *)handleView urlToLoad:(NSURL *)url {
//    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}

@end
