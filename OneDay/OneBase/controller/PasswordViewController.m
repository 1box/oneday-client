//
//  PasswordViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "PasswordViewController.h"
#import "KMTableView.h"
#import "PasswordAddonCell.h"
#import "PasswordManager.h"
#import "AddonManager.h"
#import "KMModelManager.h"
#import "AddonData.h"

@interface PasswordViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet KMTableView *listView;
@property (nonatomic) NSArray *currentAddons;
@end

@implementation PasswordViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentAddons = [[AddonManager sharedManager] currentAddons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_listView reloadData];
}

- (NSString *)pageNameForTrack
{
    return @"PasswordPage";
}

#pragma mark - Actions

- (IBAction)passwordOn:(id)sender
{
    UISwitch *aSwitch = sender;
    NSIndexPath *indexPath = [_listView indexPathForCell:(PasswordAddonCell *)aSwitch.superview];
    if (indexPath.section == 0) {
        [PasswordManager setLaunchPasswordOpen:aSwitch.isOn];
    }
    else if (indexPath.section == 1) {
        AddonData *tAddonOn = [_currentAddons objectAtIndex:indexPath.row];
        tAddonOn.passwordOn = [NSNumber numberWithBool:aSwitch.isOn];
        [[KMModelManager sharedManager] saveContext:nil];
    }
}

- (IBAction)closeAll:(id)sender
{
    for (AddonData *addon in _currentAddons) {
        addon.passwordOn = @NO;
    }
    [[KMModelManager sharedManager] saveContext:nil];
    
    [_listView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 1;
    if (section == 1) {
        ret = [_currentAddons count];
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PasswordAddonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordAddonCellID"];
    if (indexPath.section == 0) {
        cell.addonLabel.text = NSLocalizedString(@"LaunchPasswordCellText", nil);
        cell.passwordSwitch.on = [PasswordManager launchPasswordOpen];
    }
    else if (indexPath.section == 1) {
        AddonData *tAddon = [_currentAddons objectAtIndex:indexPath.row];
        cell.addonLabel.text = NSLocalizedString(tAddon.dailyDoName, nil);
        cell.passwordSwitch.on = [tAddon.passwordOn boolValue];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(KMTableViewCell *)cell refreshUI];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

