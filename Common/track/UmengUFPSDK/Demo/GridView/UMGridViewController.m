//
//  UMIconListViewController.m
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMGridViewController.h"
#import "UMUFPImageView.h"
#import <QuartzCore/QuartzCore.h>

#import "UMUFPGridCell.h"
#import "GridViewCellDemo.h"

@interface UMGridViewController ()

@end

@implementation UMGridViewController

static int NUMBER_OF_COLUMNS = 3;
static int NUMBER_OF_APPS_PERPAGE = 15;

- (NSString*)resolutionString
{
    NSString * resolution;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
		resolution = [NSString stringWithFormat:@"%d x %d",(int)([[UIScreen mainScreen] bounds].size.height*[UIScreen mainScreen].scale),(int)([[UIScreen mainScreen] bounds].size.width*[UIScreen mainScreen].scale)];
	}else
    {
		resolution = [NSString stringWithFormat:@"%d x %d",(int)[[UIScreen mainScreen] bounds].size.height,(int)[[UIScreen mainScreen] bounds].size.width];
	}
    
    return resolution;
}

- (void)updateNumberOfColumns:(UIInterfaceOrientation)orientation
{
    NSString *resolution = [self resolutionString];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if ([resolution isEqualToString:@"1136 x 640"])
        {
            NUMBER_OF_COLUMNS = 6;
        }
        else
        {
            NUMBER_OF_COLUMNS = 5;
        }
    }
    else
    {
        NUMBER_OF_COLUMNS = 3;
    }
    
    if ([resolution isEqualToString:@"1136 x 640"])
    {
        NUMBER_OF_APPS_PERPAGE = 18;
    }
    else
    {
        NUMBER_OF_APPS_PERPAGE = 15;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"_recommendApp", nil);
    self.view.autoresizesSubviews = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.921 alpha:1.0];
    
    UIApplication *application = [UIApplication sharedApplication];
    [self updateNumberOfColumns:application.statusBarOrientation];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    _mGridView = [[UMUFPGridView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height-navigationBarHeight) appkey:@"4f7046375270156912000011" slotId:nil currentViewController:self];
    _mGridView.datasource = self;
    _mGridView.delegate = self;
    _mGridView.dataLoadDelegate = (id<GridViewDataLoadDelegate>)self;
    _mGridView.autoresizesSubviews = YES;
    _mGridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_mGridView requestPromoterDataInBackground];
    
    [self.view addSubview:_mGridView];
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
    
    [self updateNumberOfColumns:interfaceOrientation];
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    _mGridView.frame = CGRectMake(0, frame.size.height, size.width, size.height - frame.size.height);
}

#pragma mark GridViewDataSource

- (NSInteger)numberOfColumsInGridView:(UMUFPGridView *)gridView{
    
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)numberOfAppsPerPage:(UMUFPGridView *)gridView
{
    return NUMBER_OF_APPS_PERPAGE;
}

- (UIView *)gridView:(UMUFPGridView *)gridView cellForRowAtIndexPath:(IndexPath *)indexPath{
    
    GridViewCellDemo *view = [[GridViewCellDemo alloc] initWithIdentifier:nil];
    
    return view;
}

-(void)gridView:(UMUFPGridView *)gridView relayoutCellSubview:(UIView *)view withIndexPath:(IndexPath *)indexPath{
    
    int arrIndex = [gridView arrayIndexForIndexPath:indexPath];
    if (arrIndex < [_mGridView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mGridView.mPromoterDatas objectAtIndex:arrIndex];
        
        GridViewCellDemo *imageViewCell = (GridViewCellDemo *)view;
        imageViewCell.indexPath = indexPath;
        imageViewCell.titleLabel.text = [promoter valueForKey:@"title"];
        
        [imageViewCell.imageView setImageURL:[NSURL URLWithString:[promoter valueForKey:@"icon"]]];
    }
}

#pragma mark GridViewDelegate

- (CGFloat)gridView:(UMUFPGridView *)gridView heightForRowAtIndexPath:(IndexPath *)indexPath
{
    return 80.0f;
}

- (void)gridView:(UMUFPGridView *)gridView didSelectRowAtIndexPath:(IndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)UMUFPGridViewDidLoadDataFinish:(UMUFPGridView *)gridView promotersAmount:(NSInteger)promotersAmount
{
    NSLog(@"%s, %d", __PRETTY_FUNCTION__, promotersAmount);
    
    [gridView reloadData];
}

- (void)UMUFPGridView:(UMUFPGridView *)gridView didLoadDataFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end