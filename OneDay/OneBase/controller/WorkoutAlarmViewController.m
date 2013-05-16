//
//  WorkoutAlarmViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "WorkoutAlarmViewController.h"
#import "KMTableView.h"
#import "WorkoutAlarmCellView.h"
#import "AddAlarmViewController.h"
#import "AlarmManager.h"
#import "MTStatusBarOverlay.h"


@interface WorkoutAlarmViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet KMTableView *alarmView;
@property (nonatomic) NSArray *alarms;
@property (nonatomic) NSIndexPath *selectIndexPath;
@end


@implementation WorkoutAlarmViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showAddAlarmView"]) {
        UINavigationController *nav = segue.destinationViewController;
        AddAlarmViewController *tController = (AddAlarmViewController *)nav.topViewController;
        tController.addon = _addon;
    }
    else if ([segue.identifier isEqualToString:@"showEditAddAlarmView"]) {
        AddAlarmViewController *tController = (AddAlarmViewController *)segue.destinationViewController;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(5.f, 0, 44.f, 44.f);
        [leftButton setImage:[UIImage imageNamed:@"dark_nav_back.png"] forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [leftButton addTarget:tController action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        tController.navigationItem.leftBarButtonItem = leftItem;
        
        tController.addon = _addon;
        
#warning test if earlier than willAppear?
        tController.alarm = [_alarms objectAtIndex:_selectIndexPath];
    }
}

#pragma mark - Actions

- (IBAction)edit:(id)sender
{
    _alarmView.editing = !_alarmView.isEditing;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_alarms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *alarmCelID = @"AlarmCellID";
    
    WorkoutAlarmCellView *cell = [tableView dequeueReusableCellWithIdentifier:alarmCelID];
    if (indexPath.row < [_alarms count]) {
        AlarmData *alarm = [_alarms objectAtIndex:indexPath.row];
        cell.alarm = alarm;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_alarmView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"delete", nil);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row < [_alarms count]) {
        AlarmData *alarm = [_alarms objectAtIndex:indexPath.row];
        if ([[AlarmManager sharedManager] removeAlarm:alarm]) {
            [[MTStatusBarOverlay sharedOverlay] postFinishMessage:NSLocalizedString(@"DeleteAlarmSuccess", nil) duration:2.f];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_alarmView updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_alarmView updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

@end
