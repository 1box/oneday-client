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


@interface WorkoutAlarmViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet KMTableView *alarmView;
@property (nonatomic) NSArray *alarms;
@end


@implementation WorkoutAlarmViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_alarms count]) {
        // need code
    }
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
