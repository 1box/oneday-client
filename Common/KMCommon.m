//
//  SSCommon.m
//  Gallery
//
//  Created by Dianwei Hu on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KMCommon.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "UIDevice-Hardware.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation KMCommon

+ (UIViewController*)topViewControllerFor:(UIResponder*)responder
{
	UIResponder *topResponder = responder;
	while(topResponder && ![topResponder isKindOfClass:[UIViewController class]]) {
		topResponder = [topResponder nextResponder];
	}
    
    if(!topResponder) {
        topResponder = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
	
	return (UIViewController*)topResponder;
}

+ (NSString*)deviceType
{
    return [[UIDevice currentDevice] model];
}

+ (NSString*)appDisplayName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!appName) 
    {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    
    return appName;
}

+ (NSString*)platformName
{
    NSString *result = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";
    return result;
}

+ (NSString*)versionName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString*)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"];
}

+ (NSString*)OSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*)bundleIdentifier
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString*)customURLWithUserInfoStringFromString:(NSString*)urlStr
{
    NSRange range = [urlStr rangeOfString:@"?"];
    NSString *sep = (range.location == NSNotFound) ? @"?" : @"&";
    NSMutableString *string = [NSMutableString stringWithString:urlStr];
    
    if([string rangeOfString:@"uuid"].location == NSNotFound) {
        [string appendFormat:@"%@uuid=%@", sep, [self getUniqueIdentifier]];
    }
   
    return string;
}

+ (NSString*)customURLStringFromString:(NSString*)urlStr
{
    NSRange range = [urlStr rangeOfString:@"?"];
    NSString *sep = (range.location == NSNotFound) ? @"?" : @"&";
    NSMutableString *string = [NSMutableString stringWithString:urlStr];
    
//    if([string rangeOfString:@"platform"].location == NSNotFound)
//    {
//        [string appendFormat:@"%@platform=%@", sep, [SSCommon platformName]];
//        sep = @"&";
//    }
    
    if([string rangeOfString:@"device_platform"].location == NSNotFound)
    {
        [string appendFormat:@"%@device_platform=%@", sep, [KMCommon platformName]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"channel"].location == NSNotFound)
    {
        [string appendFormat:@"%@channel=%@", sep, getCurrentChannel()];
        sep = @"&";
    }
    
    if([string rangeOfString:@"app_name"].location == NSNotFound)
    {
        [string appendFormat:@"%@app_name=%@", sep, [KMCommon appName]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"device_type"].location == NSNotFound)
    {
        [string appendFormat:@"%@device_type=%@", sep, [[UIDevice currentDevice] platformString]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"os_version"].location == NSNotFound)
    {
        [string appendFormat:@"%@os_version=%@", sep, [KMCommon OSVersion]];
        sep = @"&";
    }
    
    if([string rangeOfString:@"version_code"].location == NSNotFound)
    {
        [string appendFormat:@"%@version_code=%@", sep, [KMCommon versionName]];
    }

    
    return [KMCommon customURLWithUserInfoStringFromString:string];
}

+ (NSString*)URLStringByAddingParamsForURLString:(NSString*)strURL params:(NSString*)params 
{
	NSString *sep = @"&";
	NSRange range = [strURL rangeOfString:@"?"];
	if (range.location==NSNotFound) {
		sep = @"?";
	}
	NSString *newURL = [NSString stringWithFormat:@"%@%@%@", strURL, sep, params];
	return newURL;
}

+ (NSString *)MACAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;              
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    // Befor going any further...
    if (errorFlag != NULL) {
        free(msgBuffer);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    NSString *macAddressString = @"00:00:00:00:00:00";
    
    if (socketStruct != nil) {
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                            macAddress[0], macAddress[1], macAddress[2], 
                            macAddress[3], macAddress[4], macAddress[5]];
    }
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSString *)getUniqueIdentifier
{
    UIDevice * device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(uniqueIdentifier)]) {
//        return [device uniqueIdentifier];
        return [[device identifierForVendor] UUIDString];
    }
    return [self MACAddress];
}

+ (NSString*)currentLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (BOOL)isJailBroken 
{
	NSString *filePath = @"/Applications/Cydia.app";
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return YES;
	}
	
	filePath = @"/private/var/lib/apt";
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return YES;
	}
	
	return NO;
}

//+ (NSString*)connectMethodName
//{
//    NSString *name = @"";
//    if(SSNetworkWifiConnected())
//    {
//        name = @"wifi";
//    }
//    else if(SSNetowrkCellPehoneConnected())
//    {
//        name = @"mobile";
//    }
//    
//    return name;
//}

+ (CGSize)resolution
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    CGSize resolution = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
    return resolution;
}

+ (NSString*)carrierName
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return [carrier carrierName];
}

+ (NSString*)carrierMCC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [carrier mobileCountryCode];
}

+ (NSString*)carrierMNC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [carrier mobileNetworkCode];
}

+ (int)random:(NSUInteger)range
{
  return abs(arc4random() % range);
}

+ (BOOL)isAPPFirstLaunch
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * currentStatus = [defaults objectForKey:[NSString stringWithFormat:@"APP_LAUNCHED%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
    return [currentStatus intValue] == 1 ? NO : YES;
}

+ (void)setAppFirstLaunch
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"APP_LAUNCHED%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
    [defaults synchronize];
}


//+ (NSString*)dateStringSince:(NSTimeInterval)timeInterval
//{
//    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
//}

//+ (NSString*)simpleDateStringSince:(NSTimeInterval)timerInterval
//{
//    return [simpleFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timerInterval]];   
//}
//
//+ (NSString*)customtimeStringSince1970:(NSTimeInterval)timeInterval
//{
//    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
//    [comp setHour:0];
//    [comp setMinute:0];
//    [comp setSecond:0];
//    NSTimeInterval minInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
//    
//    
//	NSString *retString = nil;
//    if(timeInterval >= minInterval)
//    {
//        int t = [[NSDate date] timeIntervalSince1970] - timeInterval;
//        if(t < 60)
//        {
//            retString = @"1分钟内";
//        }
//        else if (t < 3600)
//        {
//            int val = t / 60;
//            retString = [NSString stringWithFormat:@"%d分钟前", val];
//        }
//        else if(t < 24 * 3600)
//        {
//            int val = t / 3600;
//            
//            retString = [NSString stringWithFormat:@"%d小时前", val];
//        }
//        else
//        {
//            retString = [SSCommon simpleDateStringSince:timeInterval];
//        }
//    }
//    else
//    {
//        retString = [SSCommon simpleDateStringSince:timeInterval];
//    }
//    
//	return retString;
//}

+ (NSDictionary*)parametersOfURLString:(NSString*)urlString
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSArray *patterns = [urlString componentsSeparatedByString:@"&"];
    for(NSString *pattern in patterns)
    {
        NSArray *part = [pattern componentsSeparatedByString:@"="];
        if([part count] == 2)
        {
            [result setObject:[part objectAtIndex:1] forKey:[part objectAtIndex:0]];
        }
    }
    
    return result;
}

+ (BOOL)isPadDevice
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)is568Screen
{
    return [UIScreen mainScreen].bounds.size.height == 568;
}

static AVAudioPlayer *_player = nil;
+ (void)playSound:(NSString*)fileName
{
    [_player stop];
	NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    
    //Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    NSError *error = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
    
    if (!error) {
        [_player play];
    }
    else {
        SSLog(@"SSCommon play sound error:%@", error);
    }
}
@end
