//
//  DailyShort.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-25.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyShort.h"
#import "DailyDoManager.h"
#import "AddonData.h"

@implementation DailyShort

@dynamic shortContent;

+ (NSString *)entityName
{
    return @"DailyShortData";
}

+ (NSDictionary *)keyMapping
{
    NSMutableDictionary *keyMapping = [[super keyMapping] mutableCopy];
    [keyMapping setObject:@"shortContent" forKey:@"short_content"];
    
    return keyMapping;
}

#pragma mark - protected
- (NSString *)presentedText
{
    return self.shortContent;
}

- (NSString *)completionText
{
    NSString *ret = NSLocalizedString(@"DailyShortNoText", nil);
    if (!KMEmptyString(self.shortContent)) {
        ret = self.shortContent;
    }
    return ret;
}
@end