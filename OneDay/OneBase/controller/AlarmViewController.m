//
//  WorkoutAlarmViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-14.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AlarmViewController.h"
#import "KMTableView.h"
#import "AlarmCellView.h"
#import "AddAlarmViewController.h"
#import "AlarmManager.h"
#import "KMModelManager.h"
#import "AlarmData.h"
#import "MTStatusBarOverlay.h"
#import "DarkNavigationBarButton.h"


@interface AlarmViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet KMTableView *alarmView;
@property (nonatomic) NSArray *alarms;
@property (nonatomic) NSIndexPath *selectIndexPath;
@end


@implementation AlarmViewController

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
        [leftButton addTarget:tController action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        tController.navigationItem.leftBarButtonItem = leftItem;
        
        DarkNavigationBarButton *rightButton = (DarkNavigationBarButton *)tController.navigationItem.rightBarButtonItem.customView;
        [rightButton removeTarget:tController action:@selector(saveAndDismiss:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton addTarget:tController action:@selector(saveAndBack:) forControlEvents:UIControlEventTouchUpInside];
        
        tController.addon = _addon;
        tController.alarm = [_alarms objectAtIndex:_selectIndexPath.row];
    }
}

#pragma mark - View Lifecycles

- (void)viewDidAppear:(BOOL)animated
{
    self.alarms = [[AlarmManager sharedManager] alarmsForAddon:_addon];
    [_alarmView reloadData];
}

#pragma mark - Actions

- (IBAction)edit:(id)sender
{
    _alarmView.editing = !_alarmView.isEditing;
}

- (IBAction)closeAll:(id)sender
{
    __block BOOL needSave = NO;
    [_alarms enumerateObjectsUsingBlock:^(AlarmData *alarm, NSUInteger idx, BOOL *stop) {
        if ([alarm.open boolValue]) {
            alarm.open = @NO;
            needSave = YES;
        }
    }];
    
    if (needSave) {
        [[KMModelManager sharedManager] saveContext:nil];
        [_alarmView reloadData];
        
        [[MTStatusBarOverlay sharedOverlay] postFinishMessage:NSLocalizedString(@"CloseAllAlarmSuccess", nil) duration:2.f];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_alarms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *alarmCelID = @"AlarmCellID";
    
    AlarmCellView *cell = [tableView dequeueReusableCellWithIdentifier:alarmCelID];
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
            
            NSMutableArray *mutAlarms = [NSMutableArray arrayWithArray:_alarms];
            [mutAlarms removeObject:alarm];
            self.alarms = [mutAlarms copy];
            
            [tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndexPath = indexPath;
    [_alarmView updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_alarmView updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

@end
