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
    switch (_inputType) {
        case AlarmInputTypeTitle:
            _alarm.title = _textField.text;
            break;
            case AlarmInputTypeText:
            _alarm.text = _textField.text;
            break;
        default:
            break;
    }
    [super back:sender];
}

@end
