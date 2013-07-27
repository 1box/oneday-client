//
//  DailyDoView.m
//  OneDay
//
//  Created by Yu Tianhang on 12-11-26.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import "DailyDoView.h"

#import "TodoViewController.h"
#import "TimelineViewController.h"
#import "NoteViewController.h"
#import "TagViewController.h"
#import "UndoViewController.h"
#import "SummaryViewController.h"
#import "AlarmViewController.h"

#import "KMTableView.h"
#import "DailyDoTodayCell.h"
#import "DailyDoTomorrowCell.h"
#import "DailyDoLoggedCell.h"
#import "DailyDoTodoCell.h"
#import "DailyDoTodoCellListCell.h"
#import "DailyDoTagCell.h"
#import "DailyDoNoteCell.h"
#import "KMLoadMoreCell.h"
#import "MTStatusBarOverlay.h"

#import "KMModelManager.h"
#import "DailyDoManager.h"
#import "PasswordManager.h"
#import "AddonsHeader.h"
#import "DailyDoActionHelper.h"
#import "DailyDoViewHelper.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"

#define CommonCellHeight 44.f

@interface DailyDoView () <DailyDoActionHelperDelegate, UIActionSheetDelegate> {
    
    BOOL _isLoading;
    BOOL _canLoadMore;
}

@property (nonatomic) DailyDoViewHelper *viewHelper;

@property (nonatomic) DailyDoBase *todayDo;
@property (nonatomic) DailyDoBase *tomorrowDo;
@property (nonatomic) NSArray *loggedDos;
@property (nonatomic) NSArray *properties;
@property (nonatomic) NSDictionary *configurations;
@property (nonatomic) NSMutableDictionary *propertiesDict;
@end

@implementation DailyDoView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isLoading = NO;
        _canLoadMore = NO;
        
        self.viewHelper = [[DailyDoViewHelper alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DailyDoPropertyCell *tCell = sender;
    if ([[segue identifier] isEqualToString:@"showTodo"]) {
        TodoViewController *controller = [segue destinationViewController];
        controller.dailyDo = _todayDo;
        controller.navigationItem.title = tCell.nameLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"showTag"]) {
        TagViewController *controller = [segue destinationViewController];
        controller.dailyDo = _todayDo;
        controller.navigationItem.title = tCell.nameLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"showTimeline"]) {
        TimelineViewController *controller = [segue destinationViewController];
        NSMutableArray *dailyDos = [NSMutableArray arrayWithObject:_todayDo];
        [dailyDos addObjectsFromArray:_loggedDos];
        controller.dailyDos = [dailyDos copy];
        controller.navigationItem.title = tCell.nameLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"showNote"]) {
        NoteViewController *controller = [segue destinationViewController];
        controller.propertyKey = tCell.propertyKey;
        controller.propertiesDict = _propertiesDict;
        controller.dailyDo = _todayDo;
        controller.navigationItem.title = NSLocalizedString([[_properties objectAtIndex:[_listView indexPathForCell:tCell].row - 1] objectForKey:kPropertyDisplayNameKey], nil);
    }
}

#pragma mark - Viewlifecycle

- (void)loadView
{
    [super loadView];
    
    self.todayDo = [[DailyDoManager sharedManager] todayDoForAddon:_addon];
    self.tomorrowDo = [[DailyDoManager sharedManager] tomorrowDoForAddon:_addon];
    self.loggedDos = [NSArray array];
    self.properties = [[DailyDoManager sharedManager] propertiesForDoName:_addon.dailyDoName];
    self.configurations = [[DailyDoManager sharedManager] configurationsForDoName:_addon.dailyDoName];
    self.propertiesDict = [[[DailyDoManager sharedManager] propertiesDictForProperties:_properties inDailyDo:_todayDo] mutableCopy];
    
    [DailyDoActionHelper sharedHelper].delegate = self;
    
    _todaySectionIndex = 0;
    _tomorrowSectionIndex = [_tomorrowDo.todos count] > 0 ? 1 : -1;
    _loggedSectionIndex = _tomorrowSectionIndex == 1 ? 2 : 1;
    
    
    UIImage *selectBackgroundImage = [UIImage imageNamed:@"light_nav_btn_bg_press.png"];
    [_unfoldButton setBackgroundImage:[selectBackgroundImage stretchableImageWithLeftCapWidth:selectBackgroundImage.size.width/2 topCapHeight:selectBackgroundImage.size.height/2] forState:UIControlStateSelected];
    _unfoldButton.selected = _viewHelper.allUnfold;
    
    // load action items
    NSArray *items = _toolbar.items;
    NSMutableArray *mutItems = [NSMutableArray arrayWithCapacity:[items count]];
    NSInteger actionType = [[_configurations objectForKey:kConfigurationActionType] integerValue];
    
    if ((actionType & DailyDoActionTypeMoveToTomorrow) == DailyDoActionTypeMoveToTomorrow) {
        [mutItems addObject:[items objectAtIndex:0]];
    }
    
    if ((actionType & DailyDoActionTypeQuickAdd) == DailyDoActionTypeQuickAdd) {
        [mutItems addObject:[items objectAtIndex:1]];
    }
    
    [mutItems addObject:[items objectAtIndex:2]];
    
    // 至少会有"编辑"这个功能
    //    if ((actionType & DailyDoActionTypeShowAllUndos) == DailyDoActionTypeShowAllUndos ||
    //        (actionType & DailyDoActionTypeCashMonthSummary) == DailyDoActionTypeCashMonthSummary ||
    //        (actionType & DailyDoActionTypeCashYearSummary) == DailyDoActionTypeCashYearSummary ||
    //        (actionType & DailyDoActionTypeAlarmNotification) == DailyDoActionTypeAlarmNotification) {
    [mutItems addObject:[items objectAtIndex:3]];
    //    }
    
    _toolbar.items = [mutItems copy];
    
    [[PasswordManager sharedManager] showAddonLock:_addon finishBlock:nil];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self registerNotifications];
    [self loadLoggedDos:NO];
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
    [self unregisterNotifications];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_listView reloadData];
}

#pragma mark - notifications

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportUIApplicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataFinished:)
                                                 name:DailyDoManagerLoggedDosLoadFinishedNotification
                                               object:[DailyDoManager sharedManager]];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reportUIApplicationDidChangeStatusBarOrientationNotification:)
//                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
//                                               object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DailyDoManagerLoggedDosLoadFinishedNotification object:[DailyDoManager sharedManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)reportUIApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    if (![PasswordManager launchPasswordOpen]) {
        [[PasswordManager sharedManager] showAddonLock:_addon finishBlock:nil];
    }
}

//- (void)reportUIApplicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification
//{
//    // fix bug
//    [_listView reloadData];
//}

#pragma mark - setter&getter

- (void)setAddon:(AddonData *)addon
{
    _addon = addon;
    if (_addon) {
        _viewHelper.addon = _addon;
    }
}

#pragma mark - private

- (void)loadLoggedDos:(BOOL)loadMore
{
    if (!_isLoading) {
        _isLoading = YES;
        
        NSMutableDictionary *mutCondition = [NSMutableDictionary dictionaryWithDictionary:
                                             @{ kDailyDoManagerLoadConditionCountKey : [NSNumber numberWithInt:20],
                                                kDailyDoManagerLoadConditionIsLoadMoreKey : [NSNumber numberWithBool:loadMore],
                                                kDailyDoManagerLoadConditionAddonKey : _addon}];
        if ([_loggedDos count] > 0 && loadMore) {
            DailyDoBase *dailyDo = [_loggedDos lastObject];
            [mutCondition setObject:dailyDo.createTime forKey:kDailyDoManagerLoadConditionMaxCreateTimeKey];
        }
        [[DailyDoManager sharedManager] loadLoggedDosForCondition:[mutCondition copy]];
    }
}

- (void)reloadData
{
    _todaySectionIndex = 0;
    _tomorrowSectionIndex = [_tomorrowDo.todos count] > 0 ? 1 : -1;
    _loggedSectionIndex = _tomorrowSectionIndex == 1 ? 2 : 1;
    
    [_listView reloadData];
}

#pragma mark - Actions

- (IBAction)addTodo:(id)sender
{
    [[DailyDoActionHelper sharedHelper] quickAddTodo:_todayDo];
}

- (IBAction)unfoldAll:(id)sender
{
    _viewHelper.allUnfold = !_viewHelper.allUnfold;
    
    _unfoldButton.selected = _viewHelper.allUnfold;
    [_listView reloadData];
}

- (IBAction)moveTodoToTomorrow:(id)sender
{
    [[DailyDoActionHelper sharedHelper] move:_todayDo toTomorrow:_tomorrowDo];
}

- (IBAction)edit:(id)sender
{
    [_listView setEditing:!_listView.editing animated:YES];
}

- (IBAction)search:(id)sender
{
    
}

- (IBAction)checkbox:(id)sender
{
    UIButton *checkBox = sender;
    BOOL toChecked = !checkBox.selected;
    checkBox.selected = toChecked;
    
    if ([checkBox.superview.superview isKindOfClass:[DailyDoTodoCellListCell class]]) {
        TodoData *todo = ((DailyDoTodoCellListCell*)checkBox.superview.superview).todo;
        todo.check = [NSNumber numberWithBool:toChecked];
    }
    else if ([checkBox.superview.superview isKindOfClass:[DailyDoTodayCell class]]) {
        for (TodoData *todo in _todayDo.todos) {
            todo.check = [NSNumber numberWithBool:toChecked];
        }
    }
    
    [[KMModelManager sharedManager] saveContext:nil];
    [self reloadData];
}

- (IBAction)otherActions:(id)sender
{
    NSMutableArray *otherButtonTitles = [NSMutableArray arrayWithCapacity:10];
    NSInteger actionType = [[_configurations objectForKey:kConfigurationActionType] integerValue];
    
    NSString *editTitle = NSLocalizedString(@"_edit", nil);
    if (_listView.editing) {
        editTitle = NSLocalizedString(@"_editDone", nil);
    }
    [otherButtonTitles addObject:editTitle];
    
    if (DailyDoActionTypeShowAllUndos == (actionType & DailyDoActionTypeShowAllUndos)) {
        [otherButtonTitles addObject:NSLocalizedString(@"ShowAllUndosTitle", nil)];
    }
    if (DailyDoActionTypeCashMonthSummary == (actionType & DailyDoActionTypeCashMonthSummary)) {
        [otherButtonTitles addObject:NSLocalizedString(@"CashMonthSummaryTitle", nil)];
    }
    if (DailyDoActionTypeCashYearSummary == (actionType & DailyDoActionTypeCashYearSummary)) {
        [otherButtonTitles addObject:NSLocalizedString(@"CashYearSummaryTitle", nil)];
    }
    if (DailyDoActionTypeAlarmNotification == (actionType & DailyDoActionTypeAlarmNotification)) {
        [otherButtonTitles addObject:NSLocalizedString(@"AlarmNotificationTitle", nil)];
    }
    if (DailyDoActionTypeClearAllBlank == (actionType & DailyDoActionTypeClearAllBlank)) {
        [otherButtonTitles addObject:NSLocalizedString(@"ClearAllBlankTitle", nil)];
    }
    [otherButtonTitles addObject:NSLocalizedString(@"_cancel", nil)];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@""
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    for (NSString *title in otherButtonTitles) {
        [sheet addButtonWithTitle:title];
    }
    sheet.cancelButtonIndex = [otherButtonTitles count] - 1;
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self];
}

#pragma mark - DailyDoManagerLoggedDosLoadFinishedNotification

- (void)loadDataFinished:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *condition = [userInfo objectForKey:kDailyDoManagerLoggedDosLoadConditionKey];
    AddonData *addon = [condition objectForKey:kDailyDoManagerLoadConditionAddonKey];
    if (addon != _addon) {
        return;
    }
    
    NSDictionary *result = [userInfo objectForKey:kDailyDoManagerLoggedLoadResultKey];
    NSError *error = [result objectForKey:kDailyDoManagerLoadResultErrorKey];
    BOOL isLoadMore = [[condition objectForKey:kDailyDoManagerLoadConditionIsLoadMoreKey] boolValue];
    if (!error) {
        NSArray *dataList = [result objectForKey:kDailyDoManagerLoadResultDataListKey];
        if ([dataList count] > 0) {
            if (isLoadMore) {
                NSMutableArray *mutLoggedDos = [[NSMutableArray alloc] initWithArray:_loggedDos];
                [mutLoggedDos addObjectsFromArray:dataList];
                self.loggedDos = [mutLoggedDos copy];
            }
            else {
                self.loggedDos = dataList;
            }
        }
        
        _canLoadMore = [dataList count] > 0;
        
        [_listView reloadData];
    }
    else {
        _canLoadMore = NO;
    }
    
    _isLoading = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger ret = 3;
    return ret;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    
    if (section == _todaySectionIndex) {
        ret = 1;
        if (_viewHelper.todayDoUnfold) {
            ret += [_properties count] + ([[_configurations objectForKey:kConfigurationShowTimelineKey] boolValue] ? 1 : 0);
        }
    }
    else if (section == _tomorrowSectionIndex) {
        ret = [_tomorrowDo.todos count] > 0 ? 1 : 0;
    }
    else if (section == _loggedSectionIndex) {
        ret = [_loggedDos count];
        if (_canLoadMore) {
            ret ++;
        }
    }
    
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ret = CommonCellHeight;
    
    if (indexPath.section == _todaySectionIndex) {
        if (indexPath.row == 0) {
            ret = [DailyDoTodayCell heightOfCellForDailyDo:_todayDo unfold:_viewHelper.todayDoUnfold];
        }
        else {
            if (indexPath.row == 1) {
                ret = [DailyDoTodoCell heightOfCellForDailyDo:_todayDo];
            }
        }
    }
    else if (indexPath.section == _tomorrowSectionIndex) {
       ret = [_tomorrowDo.todos count] == 0 ? 0.f : [DailyDoTomorrowCell heightOfCellForDailyDo:_tomorrowDo unfolded:_viewHelper.tomorrowDoUnfold]; 
    }
    else if (indexPath.section == _loggedSectionIndex) {
        if (indexPath.row < [_loggedDos count]) {
            ret = [DailyDoLoggedCell heightOfCellForDailyDo:[_loggedDos objectAtIndex:indexPath.row]
                                                   unfolded:[_viewHelper loggedUnfoldForIndex:indexPath.row]];
        }
        else {
            ret = 44.f;
        }
    }
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *todayDoCell = @"TodayDoCellID";
    static NSString *todayPropertyTodosCell = @"TodayPropertyTodosCellID";
    static NSString *todayPropertyNotesCell = @"TodayPropertyNotesCellID";
    static NSString *todayPropertyTagsCell = @"TodayPropertyTagsCellID";
    static NSString *todayPropertyTimelineCell = @"TodayPropertyTimelineCellID";
    static NSString *loggedDoCell = @"LoggedDoCellID";
    static NSString *tomorrowDoCell = @"TomorrowCellID";
    static NSString *loadMoreCell = @"LoadMoreCellID";
    
    if (indexPath.section == _todaySectionIndex) {
        if (indexPath.row == 0) {
            DailyDoTodayCell *cell = [tableView dequeueReusableCellWithIdentifier:todayDoCell];
            cell.dailyDo = _todayDo;
            cell.unfolded = _viewHelper.todayDoUnfold;
            return cell;
        }
        else if (indexPath.row == [_properties count] + 1) {
            DailyDoPropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:todayPropertyTimelineCell];
            cell.nameLabel.text = NSLocalizedString([_configurations objectForKey:kConfigurationTimelineTitle], nil);
            cell.propertyKey = @"timeline";
            return cell;
        }
        else {
            NSDictionary *property = [_properties objectAtIndex:indexPath.row - 1];
            
            if ([[property objectForKey:kPropertyTypeKey] isEqualToString:PropertyTypeTodos]) {
                DailyDoTodoCell *cell = [tableView dequeueReusableCellWithIdentifier:todayPropertyTodosCell];
                cell.nameLabel.text = NSLocalizedString([property objectForKey:kPropertyDisplayNameKey], nil);
                cell.iconImage.image = [UIImage imageNamed:_todayDo.addon.icon];
                cell.dailyDo = _todayDo;
                return cell;
            }
            else if ([[property objectForKey:kPropertyTypeKey] isEqualToString:PropertyTypeTags]) {
                DailyDoTagCell *cell = [tableView dequeueReusableCellWithIdentifier:todayPropertyTagsCell];
                cell.nameLabel.text = NSLocalizedString([property objectForKey:kPropertyNameKey], nil);
                cell.iconImage.image = [UIImage imageNamed:[property objectForKey:kProperyIconKey]];
                cell.propertyKey = [property objectForKey:kPropertyNameKey];
                cell.dailyDo = _todayDo;
                return cell;
            }
            else if ([[property objectForKey:kPropertyTypeKey] isEqualToString:ProperyTypeString]) {
                DailyDoNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:todayPropertyNotesCell];
                NSString *tString = [_todayDo valueForKeyPath:[property objectForKey:kPropertyNameKey]];
                if (KMEmptyString(tString)) {
                    tString = NSLocalizedString([property objectForKey:kPropertyDisplayNameKey], nil);
                }
                cell.nameLabel.text = tString;
                cell.iconImage.image = [UIImage imageNamed:[property objectForKey:kProperyIconKey]];
                cell.propertyKey = [property objectForKey:kPropertyNameKey];
                return cell;
            }
        }
    }
    else if (indexPath.section == _tomorrowSectionIndex) {
        DailyDoTomorrowCell *cell = [tableView dequeueReusableCellWithIdentifier:tomorrowDoCell];
        cell.tomorrowDo = _tomorrowDo;
        cell.unfolded = _viewHelper.tomorrowDoUnfold;
        return cell;
    }
    else if (indexPath.section == _loggedSectionIndex) {
        if (indexPath.row < [_loggedDos count]) {
            DailyDoLoggedCell *cell = [tableView dequeueReusableCellWithIdentifier:loggedDoCell];
            cell.loggedDo = [_loggedDos objectAtIndex:indexPath.row];
            cell.unfolded = [_viewHelper loggedUnfoldForIndex:indexPath.row];
            [cell refreshUI];
            return cell;
        }
        else {
            KMLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCell];
            cell.loading = YES;
            
            [self performBlock:^{
                [self loadLoggedDos:YES];
            } afterDelay:0.1f];
            
            return cell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == _loggedSectionIndex) {
        title = NSLocalizedString(@"Logged", nil);
    }
    else if (section == _tomorrowSectionIndex && [_tomorrowDo.todos count] > 0) {
        title = NSLocalizedString(@"TomorrowDo", nil);
    }
    
    if (KMEmptyString(title)) {
        return nil;
    }
    else {
        UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        
        UILabel *tLabel = [[UILabel alloc] init];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.text = title;
        tLabel.font = [UIFont boldSystemFontOfSize:16.f];
        tLabel.textColor = [UIColor whiteColor];
        [tLabel sizeToFit];
        setFrameWithX(tLabel, 10);
        [ret addSubview:tLabel];
        
        return ret;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"delete", nil);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL ret = YES;
    ret &= !(indexPath.section == _todaySectionIndex && indexPath.row != 0);
    ret &= !(indexPath.section == _loggedSectionIndex && indexPath.row >= [_loggedDos count]);
    return ret;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == _todaySectionIndex) {
            [[KMModelManager sharedManager] removeEntities:@[_todayDo] error:nil];
            self.todayDo = [[DailyDoManager sharedManager] todayDoForAddon:_addon];
        }
        else if (indexPath.section == _tomorrowSectionIndex) {
            [[KMModelManager sharedManager] removeEntities:@[_tomorrowDo] error:nil];
            self.tomorrowDo = [[DailyDoManager sharedManager] tomorrowDoForAddon:_addon];
        }
        else if (indexPath.section == _loggedSectionIndex) {
            [[KMModelManager sharedManager] removeEntities:@[[_loggedDos objectAtIndex:indexPath.row]] error:nil];
            self.loggedDos = [[DailyDoManager sharedManager] loggedDosForAddon:_addon];
        }
        
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(_viewHelper.todayDoUnfold && [[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[DailyDoTodoCell class]])) {
        [_listView updateBackgroundViewForCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeSelected];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in tableView.visibleCells) {
        [_listView updateBackgroundViewForCell:tCell atIndexPath:[tableView indexPathForCell:tCell] backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == _todaySectionIndex) {
        if ((_viewHelper.todayDoUnfold && indexPath.row == 0) || !_viewHelper.todayDoUnfold) {
            [_viewHelper updateTodayDoUnfold];
        }
    }
    else if (indexPath.section == _tomorrowSectionIndex) {
        [_viewHelper updateTomorrowDoUnfold];
    }
    else if (indexPath.section == _loggedSectionIndex) {
        if (indexPath.row < [_loggedDos count]) {
            [_viewHelper updateLoggedUnfoldForIndex:indexPath.row];
        }
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DailyDoActionHelperDelegate

- (void)dailyDoActionHelper:(DailyDoActionHelper *)helper doActionForType:(DailyDoActionType)actionType
{
    switch (actionType) {
        case DailyDoActionTypeMoveToTomorrow:
        case DailyDoActionTypeQuickAdd:
        {
            [self reloadData];
        }
            break;
        case DailyDoActionTypeShowAllUndos:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UndoNavigationControllerID"];
            if ([KMCommon isPadDevice]) {
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            UndoViewController *controller = (UndoViewController *)nav.topViewController;
            controller.addon = _addon;
            UIViewController *topViewController = [KMCommon topMostViewControllerFor:self];
            [topViewController.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case DailyDoActionTypeCashMonthSummary:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SummaryNavigationControllerID"];
            if ([KMCommon isPadDevice]) {
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            SummaryViewController *controller = (SummaryViewController *)nav.topViewController;
            controller.type = SummaryViewTypeMonth;
            controller.addon = _addon;
            UIViewController *topViewController = [KMCommon topMostViewControllerFor:self];
            [topViewController.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case DailyDoActionTypeCashYearSummary:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SummaryNavigationControllerID"];
            if ([KMCommon isPadDevice]) {
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            SummaryViewController *controller = (SummaryViewController *)nav.topViewController;
            controller.type = SummaryViewTypeYear;
            controller.addon = _addon;
            UIViewController *topViewController = [KMCommon topMostViewControllerFor:self];
            [topViewController.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case DailyDoActionTypeAlarmNotification:
        {
            UINavigationController *nav = [[UIStoryboard storyboardWithName:UniversalStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WorkoutAlarmNavigationControllerID"];
            if ([KMCommon isPadDevice]) {
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            AlarmViewController *controller = (AlarmViewController *)nav.topViewController;
            controller.addon = _addon;
            UIViewController *topViewController = [KMCommon topMostViewControllerFor:self];
            [topViewController.navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case DailyDoActionTypeClearAllBlank:
        {
            [[MTStatusBarOverlay sharedOverlay] postFinishMessage:NSLocalizedString(@"ClearAllBlankSuccess", nil) duration:2.f];
            [self loadLoggedDos:NO];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSInteger actionType = [[_configurations objectForKey:kConfigurationActionType] integerValue];
        
        switch (buttonIndex) {
            case 0:
            {
                [self edit:nil];
            }
                break;
            case 1:
            {
                if (DailyDoActionTypeShowAllUndos == (actionType & DailyDoActionTypeShowAllUndos)) {
                    [[DailyDoActionHelper sharedHelper] showAllUndos:_addon];
                }
                else if (DailyDoActionTypeCashMonthSummary == (actionType & DailyDoActionTypeCashMonthSummary)) {
                    [[DailyDoActionHelper sharedHelper] showCashMonthSummary];
                }
            }
                break;
            case 2:
            {
                if (DailyDoActionTypeCashYearSummary == (actionType & DailyDoActionTypeCashYearSummary)) {
                    [[DailyDoActionHelper sharedHelper] showCashYearSummary];
                }
                else if (DailyDoActionTypeAlarmNotification == (actionType & DailyDoActionTypeAlarmNotification)) {
                    [[DailyDoActionHelper sharedHelper] showWorkoutAlarms];
                }
                else if (DailyDoActionTypeClearAllBlank == (actionType & DailyDoActionTypeClearAllBlank)) {
                    [[DailyDoActionHelper sharedHelper] clearAllBlank:_addon];
                }
            }
                break;
            case 3:
            {
                if (DailyDoActionTypeClearAllBlank == (actionType & DailyDoActionTypeClearAllBlank)) {
                    [[DailyDoActionHelper sharedHelper] clearAllBlank:_addon];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

@end
