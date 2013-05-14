//
//  AddAlarmViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-15.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "AddAlarmViewController.h"
#import "KMTableView.h"
#import "KMTableViewCell.h"

@interface AddAlarmViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation AddAlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
    
}

- (IBAction)switchAlarmType:(id)sender
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *addAlarmRepeatTypeCellID = @"AddAlarmRepeatTypeCellID";
    static NSString *addAlarmAlarmTypeCellID = @"AddAlarmAlarmTypeCellID";
    static NSString *addAlarmTitleCellID = @"AddAlarmTitleCellID";
    static NSString *addAlarmTextCellID = @"AddAlarmTextCellID";
    
    if (indexPath.section == 0) {
        KMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addAlarmRepeatTypeCellID];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_listView updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

@end
