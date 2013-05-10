//
//  SplashHelper.h
//  OneDay
//
//  Created by Kimimaro on 13-5-10.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplashHelper : NSObject
+ (SplashHelper *)sharedHelper;

- (void)prepareSplashAnimationView;
- (void)splashFlipAnimation;
@end
