//
//  SSCommon.h
//  Gallery
//
//  Created by Dianwei Hu on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifndef DEBUG

#ifndef SSLog
#define SSLog(format,...) \
{ \
}
#endif

#else

#ifndef SSLog
#define SSLog(format,...) \
{ \
NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);	\
}
#endif
#endif

#define FONT_DEFAULT(x)      [UIFont systemFontOfSize:(x)]
#define FONT_BOLD_DEFAULT(x) [UIFont boldSystemFontOfSize:(x)]

//* App Store
//* 91助手—91zhushou
//* 同步——-tongbu
//* 威锋源—weapt
//* 论坛——-bbs
//* UC浏览器——uc
//* 360 -—-qihu
//* 交叉推广 -- jctg
//* 下载 --  download
//* 本地 -- local

#define CHANNEL_NAME @"App Store"

@class AppDelegate;

static inline NSString * ssLocalizedStringWithDefaultValue(NSString * key, NSString * defaultValue, NSString * comment) {
    if ([NSLocalizedString(key, comment) isEqualToString: key]) {
        return defaultValue;
    }
    return NSLocalizedString(key, comment);
}

static inline NSString * getCurrentUmengChannelId() {
    if ([CHANNEL_NAME isEqualToString:@"appStore"]) return nil;    
    return CHANNEL_NAME;
}

static inline NSString * getCurrentChannel() {
    return CHANNEL_NAME;
}

static CGSize s_screenSize;
static inline CGSize screenSize()
{
    if(CGSizeEqualToSize(s_screenSize, CGSizeZero)) 
    {
        s_screenSize = [[UIScreen mainScreen] bounds].size;
    }
    
    return s_screenSize;
}

#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height-(double)568) < DBL_EPSILON )

#ifndef SSMinX
#define SSMinX(view) CGRectGetMinX(view.frame)
#endif

#ifndef SSMinY
#define SSMinY(view) CGRectGetMinY(view.frame)
#endif

#ifndef SSMaxX
#define SSMaxX(view) CGRectGetMaxX(view.frame)
#endif

#ifndef SSMaxY
#define SSMaxY(view) CGRectGetMaxY(view.frame)
#endif

#ifndef SSWidth
#define SSWidth(view) view.frame.size.width
#endif

#ifndef SSHeight
#define SSHeight(view) view.frame.size.height
#endif

static inline void setAutoresizingMaskFlexibleWidthAndHeight(UIView *view){
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

static inline void setFrameWithX(UIView *view, float originX){
    CGRect rect = view.frame;
    rect.origin.x = originX;
    view.frame = rect;
}

static inline void setFrameWithY(UIView *view, float originY){
    CGRect rect = view.frame;
    rect.origin.y = originY;
    view.frame = rect;
}

static inline void setFrameWithOrigin(UIView *view, float originX, float originY){
    CGRect rect = view.frame;
    rect.origin.x = originX;
    rect.origin.y = originY;
    view.frame = rect;
}

static inline void setFrameWithWidth(UIView *view, float width){
    CGRect rect = view.frame;
    rect.size.width = width;
    view.frame = rect;
}

static inline void setFrameWithHeight(UIView *view, float height){
    CGRect rect = view.frame;
    rect.size.height = height;
    view.frame = rect;
}

static inline void setFrameWithSize(UIView *view, float width, float height){
    CGRect rect = view.frame;
    rect.size.width = width;
    rect.size.height = height;
    view.frame = rect;
}

static inline void setCenterWithX(UIView *view, float x){
    view.center = CGPointMake(x, view.center.y);
}

static inline void setCenterWithY(UIView *view, float y){
    view.center = CGPointMake(view.center.x, y);
}

@interface SSCommon : NSObject


+ (UIViewController*)topViewControllerFor:(UIResponder*)responder;
+ (NSString*)deviceType;
+ (NSString*)appDisplayName;
+ (NSString*)platformName;
+ (NSString*)versionName;
+ (NSString*)appName;
+ (NSString*)OSVersion;
+ (NSString*)customURLStringFromString:(NSString*)urlStr;
+ (NSString*)customURLWithUserInfoStringFromString:(NSString*)urlStr;
+ (NSString*)URLStringByAddingParamsForURLString:(NSString*)strURL params:(NSString*)params;
+ (NSString *)getUniqueIdentifier;
+ (NSString*)bundleIdentifier;
+ (NSString*)currentLanguage;
+ (NSString*)MACAddress;
+ (BOOL)isJailBroken;
//+ (NSString*)connectMethodName;
+ (NSString*)carrierName;
+ (NSString*)carrierMCC;
+ (NSString*)carrierMNC;
+ (CGSize)resolution;
+ (BOOL)isAPPFirstLaunch;
+ (void)setAppFirstLaunch;
+ (NSDictionary*)parametersOfURLString:(NSString*)urlString;

//// YYYY-MM-dd HH:mm:ss
//+ (NSString*)dateStringSince:(NSTimeInterval)timeInterval;
//
//// YYYY-MM-dd HH:mm
//+ (NSString*)simpleDateStringSince:(NSTimeInterval)timerInterval;

+ (BOOL)isPadDevice;

// generate random number in [0, range)
+ (int)random:(NSUInteger)range;
// less than 1 day: x hour/minute ago
// larger than 1 day: yyyy-MM-dd
//+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval;
+ (BOOL)is568Screen;
+ (void)playSound:(NSString*)fileName;
@end
