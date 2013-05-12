//
//  UndosViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-5-11.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "UndoViewController.h"
#import "AddonData.h"
#import "TodoData.h"
#import "DailyDoBase.h"
#import "KMTableView.h"
#import "UndoCellView.h"
#import "KMLoadMoreCell.h"
#import "TodoManager.h"
#import "KMDateUtils.h"


@interface UndoDateGroupedData : NSObject
@property (nonatomic) NSArray *dataList;
@property (nonatomic) NSDate *lastDate;
@property (nonatomic) NSString *dateString;
@end


@interface UndoViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    BOOL _isLoading;
    BOOL _canLoadMore;
}
@property (nonatomic) IBOutlet KMTableView *undosView;
@property (nonatomic) NSArray *undos;
@property (nonatomic) NSArray *groupedUndos;
@end


@implementation UndoViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportTodoManagerUndosLoadFinishedNotification:)
                                                 name:TodoManagerUndosLoadFinishedNotification
                                               object:[TodoManager sharedManager]];
    self.undos = [NSArray array];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TodoManagerUndosLoadFinishedNotification object:[TodoManager sharedManager]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadUndos:NO];
}

#pragma mark - Load Data

- (void)reportTodoManagerUndosLoadFinishedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *condition = [userInfo objectForKey:kTodoManagerUndosLoadConditionKey];
    if ([condition objectForKey:kTodoManagerLoadConditionAddonKey] != _addon) {
        return;
    }
    
    NSDictionary *result = [userInfo objectForKey:kTodoManagerUndosLoadResultKey];
    NSError *error = [result objectForKey:kTodoManagerLoadResultErrorKey];
    if (!error) {
        NSArray *dataList = [result objectForKey:kTodoManagerLoadResultDataListKey];
        if ([dataList count] > 0) {
            NSMutableArray *mutUndos = [NSMutableArray arrayWithArray:_undos];
            [mutUndos addObjectsFromArray:dataList];
            self.undos = [mutUndos copy];
        }
        
        _canLoadMore = [dataList count] > 0;
        
        [self prepareDataSource];
        [_undosView reloadData];
    }
    else {
        _canLoadMore = NO;
    }
    
    _isLoading = NO;
}

- (void)loadUndos:(BOOL)loadMore
{
    if (!_isLoading) {
        _isLoading = YES;
        
        NSMutableDictionary *mutCondition = [NSMutableDictionary dictionaryWithDictionary:
                                             @{ kTodoManagerLoadConditionCountKey : [NSNumber numberWithInt:20],
                                                kTodoManagerLoadConditionAddonKey : _addon}];
        if ([_undos count] > 0 && loadMore) {
            TodoData *todo = [_undos lastObject];
            [mutCondition setObject:kTodoManagerLoadConditionIsLoadMoreKey forKey:[NSNumber numberWithBool:loadMore]];
            [mutCondition setObject:todo.dailyDo.createTime forKey:kTodoManagerLoadConditionMaxCreateTimeKey];
        }
        [[TodoManager sharedManager] undosForCondition:[mutCondition copy]];
    }
}

- (void)prepareDataSource
{
    if ([_undos count] > 0) {
        NSMutableArray *tGrouped = [NSMutableArray array];
        NSMutableArray *tDataList = [NSMutableArray array];
        
        NSDate *lastDate = [NSDate date];
        for (TodoData *tData in _undos) {
            NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[tData.dailyDo.createTime doubleValue]];
            if ([currentDate isSameDayWithDate:lastDate]) {
                [tDataList addObject:tData];
            }
            else {
                if ([tDataList count] > 0) {
                    UndoDateGroupedData *tGroupedData = [[UndoDateGroupedData alloc] init];
                    tGroupedData.dataList = [tDataList copy];
                    tGroupedData.lastDate = lastDate;
                    tGroupedData.dateString = [YearToDayWeekFormatter() stringFromDate:lastDate];
                    [tGrouped addObject:tGroupedData];
                }
                
                [tDataList removeAllObjects];
                [tDataList addObject:tData];
            }
            
            lastDate = currentDate;
        }
        
        if ([tDataList count] > 0) {
            UndoDateGroupedData *tGroupedData = [[UndoDateGroupedData alloc] init];
            tGroupedData.dataList = [tDataList copy];
            tGroupedData.lastDate = lastDate;
            tGroupedData.dateString = [YearToDayWeekFormatter() stringFromDate:lastDate];
            [tGrouped addObject:tGroupedData];
        }
        
        self.groupedUndos = [tGrouped copy];
    }
    else {
        self.groupedUndos = [NSArray array];
    }
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
    NSInteger ret = [[_groupedUndos objectAtIndex:section] count];
    if (section == [_groupedUndos count] - 1 && _canLoadMore) {
        ret ++;
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *undoCellID = @"UndoCellID";
    static NSString *loadMoreCellID = @"LoadMoreCellID";
    
    if (indexPath.section == [_groupedUndos count] &&
        indexPath.row == [[_groupedUndos objectAtIndex:indexPath.section] count] - 1) {
        
        KMLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellID];
        cell.loading = YES;
        
        [self performBlock:^{
            [self loadUndos:YES];
        } afterDelay:0.1f];
        
        return cell;
    }
    else {
        UndoCellView *cell = [tableView dequeueReusableCellWithIdentifier:undoCellID];
        cell.todo = [[_groupedUndos objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return cell;
    }
}

@end


@implementation UndoDateGroupedData
@end
