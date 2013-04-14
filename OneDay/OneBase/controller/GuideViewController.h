//
//  GuideViewController.h
//  OneDay
//
//  Created by Yu Tianhang on 13-3-6.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuideViewController;
@protocol GuideViewControllerDelegate <NSObject>
- (void)guideViewController:(GuideViewController *)controller didDismissedAnimation:(BOOL)animated;
@end

@interface GuideViewController : UIViewController
@property (nonatomic, assign) id<GuideViewControllerDelegate> delegate;
- (IBAction)handleSingleTap:(id)sender;
@end
