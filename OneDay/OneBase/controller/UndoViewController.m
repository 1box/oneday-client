//
//  UndosViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "UndoViewController.h"
#import "AddonData.h"
#import "KMTableView.h"
#import "UndoCellView.h"
#import "DailyDoManager.h"


@interface UndoViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) IBOutlet KMTableView *undosView;
@property (nonatomic) NSArray *undos;
@property (nonatomic) NSArray *groupedUndos;
@end


@implementation UndoViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self prepareDataSource];
    [_undosView reloadData];
}

#pragma mark - private

- (void)prepareDataSource
{
#warning code here
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_groupedUndos count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupedUndos objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *undoCellID = @"UndoCellID";
    
    UndoCellView *cell = [tableView dequeueReusableCellWithIdentifier:undoCellID];
    if (indexPath.section < [_groupedUndos count] &&
        indexPath.row < [[_groupedUndos objectAtIndex:indexPath.section] count]) {
        cell.todo = [[_groupedUndos objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    return cell;
}

@end
