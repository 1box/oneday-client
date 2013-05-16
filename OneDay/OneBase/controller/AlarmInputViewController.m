//
//  AlarmInputViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmInputViewController.h"
#import "AlarmData.h"

@interface AlarmInputViewController () <UITextFieldDelegate>
@end

@implementation AlarmInputViewController

- (IBAction)back:(id)sender
{
    _alarm.text = _textField.text;
    [super back:sender];
}

@end
