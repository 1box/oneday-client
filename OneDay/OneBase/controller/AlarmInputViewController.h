//
//  AlarmInputViewController.h
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "KMViewControllerBase.h"

typedef NS_ENUM(NSInteger, AlarmInputType) {
    AlarmInputTypeTitle,
    AlarmInputTypeText
};

@class AlarmData;

@interface AlarmInputViewController : KMViewControllerBase
@property (nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) AlarmInputType inputType;
@property (nonatomic) AlarmData *alarm;
@end
