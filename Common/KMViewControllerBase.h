//
//  KMViewControllerBase.h
//  OneDay
//
//  Created by Kimimaro on 13-5-9.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMViewControllerBase : UIViewController

#pragma mark - protected

+ (NSString *)storyBoardID;

- (NSString *)pageNameForTrack;
- (IBAction)back:(id)sender;
- (IBAction)dismiss:(id)sender;

- (void)preparePullDownAction;

#pragma mark - public

- (BOOL)isNavigationRoot;
- (BOOL)isPresented;
- (void)renderPullToDismiss:(UIScrollView *)scrollView;

@end
