//
//  KMTracker.h
//  OneDay
//
//  Created by Yu Tianhang on 12-12-17.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobClick.h"
#import "UMFeedback.h"

static inline void trackEvent (NSString * event, NSString * label) {
    if(event == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (label == nil) {
            [MobClick event:event];
        }
        else {
            [MobClick event:event label:label];
        }
    });
    
    SSLog(@"Track event:%@, label:%@", event, label);
}


@interface KMTracker : NSObject

@property (nonatomic, assign) UIViewController *rootController;

+ (KMTracker *)sharedTracker;
- (void)startTrack;

@end
