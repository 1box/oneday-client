//
//  KMTracker.h
//  OneDay
//
//  Created by Yu Tianhang on 12-12-17.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANTracker.h"
#import "MobClick.h"
#import "UMFeedback.h"

static inline void trackEvent (NSString * event, NSString * label) {
    
    if(event == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        NSError * error = nil;
        NSString * gaString = nil;
        if (label == nil) {
            gaString = [NSString stringWithFormat:@"/ios/%@/%@", [SSCommon appName], event];
            [MobClick event:event];
        }
        else {
            gaString = [NSString stringWithFormat:@"/ios/%@/%@/%@", [SSCommon appName], event, label];
            [MobClick event:event label:label];
        }
        
//        [[GANTracker sharedTracker] trackPageview:gaString withError:&error];
    });
}


@interface KMTracker : NSObject

@property (nonatomic, assign) UIViewController *rootController;

+ (KMTracker *)sharedTracker;
- (void)startTrack;
@end
