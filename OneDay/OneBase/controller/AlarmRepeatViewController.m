//
//  AlarmRepeatViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmRepeatViewController.h"
#import "AlarmData.h"

@interface AlarmRepeatViewController () {
    AlarmRepeatType _repeatType;
}

@end

@implementation AlarmRepeatViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.editing = !cell.isEditing;
    
    AlarmRepeatType repeatType;
    switch (indexPath.row) {
        case 0:
            repeatType = AlarmRepeatTypeSunday;
            break;
        case 1:
            repeatType = AlarmRepeatTypeMonday;
            break;
        case 2:
            repeatType = AlarmRepeatTypeTuesday;
            break;
        case 3:
            repeatType = AlarmRepeatTypeWednesday;
            break;
        case 4:
            repeatType = AlarmRepeatTypeThursday;
            break;
        case 5:
            repeatType = AlarmRepeatTypeFriday;
            break;
        case 6:
            repeatType = AlarmRepeatTypeSaturday;
            break;
    }
    
    if (cell.isEditing) {
        _repeatType = _repeatType&repeatType;
    }
    else {
        _repeatType = _repeatType|repeatType;
    }
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    _alarm.repeatType = [NSNumber numberWithInteger:_repeatType];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
