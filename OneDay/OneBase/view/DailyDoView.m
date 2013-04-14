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

#import "KMTableView.h"
#import "DailyDoTodayCell.h"
#import "DailyDoTomorrowCell.h"
#import "DailyDoLoggedCell.h"
#import "DailyDoTodoCell.h"
#import "DailyDoTodoCellListCell.h"
#import "DailyDoTagCell.h"
#import "DailyDoNoteCell.h"
#import "KMAlertView.h"

#import "KMModelManager.h"
#import "DailyDoManager.h"
#import "AddonsHeader.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"

#define CommonCellHeight 44.f
#define LoggedDoUnfoldDefaultIndex -1

@interface DailyDoView () <KMAlertViewDelegate>

@property (nonatomic) DailyDoBase *todayDo;
@property (nonatomic) DailyDoBase *tomorrowDo;
@property (nonatomic) NSArray *loggedDos;
@property (nonatomic) NSArray *properties;
@property (nonatomic) NSDictionary *configurations;
@property (nonatomic) NSMutableDictionary *propertiesDict;
@end

@implementation DailyDoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
        trackEvent(@"dailyDo", [NSString stringWithFormat:@"showTodo_%@", _todayDo.addon.dailyDoName]);

        TodoViewController *controller = [segue destinationViewController];
        controller.dailyDo = _todayDo;
        controller.navigationItem.title = tCell.nameLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"showTag"]) {
        trackEvent(@"dailyDo", [NSString stringWithFormat:@"showTag_%@", _todayDo.addon.dailyDoName]);
        
        TagViewController *controller = [segue destinationViewController];
        controller.dailyDo = _todayDo;
        controller.navigationItem.title = tCell.nameLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"showTimeline"]) {
        trackEvent(@"dailyDo", [NSString stringWithFormat:@"showTimeline_%@", _todayDo.addon.dailyDoName]);

        TimelineViewController *controller = [segue destinationViewController];
        NSMutableArray *dailyDos = [NSMutableArray arrayWithObject:_todayDo];
        [dailyDos addObjectsFromArray:_loggedDos];
        controller.dailyDos = [dailyDos copy];
        controller.navigationItem.title = tCell.nameLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"showNote"]) {
        trackEvent(@"dailyDo", [NSString stringWithFormat:@"showNote_%@", _todayDo.addon.dailyDoName]);

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
    
    _todaySectionIndex = 0;
    _tomorrowSectionIndex = [_tomorrowDo.todos count] > 0 ? 1 : -1;
    _loggedSectionIndex = _tomorrowSectionIndex == 1 ? 2 : 1;
    
    _loggedDoUnfoldIndex = LoggedDoUnfoldDefaultIndex;
    _todayDoUnfold = YES;
    
    self.todayDo = [[DailyDoManager sharedManager] todayDoForAddon:_addon];
    self.tomorrowDo = [[DailyDoManager sharedManager] tomorrowDoForAddon:_addon];
    self.loggedDos = [[DailyDoManager sharedManager] loggedDosForAddon:_addon];
    self.properties = [[DailyDoManager sharedManager] propertiesForDoName:_addon.dailyDoName];
    self.configurations = [[DailyDoManager sharedManager] configurationsForDoName:_addon.dailyDoName];
    self.propertiesDict = [[[DailyDoManager sharedManager] propertiesDictForProperties:_properties inDailyDo:_todayDo] mutableCopy];
    
    BOOL showMoveToTomorrow = [[[[DailyDoManager sharedManager] configurationsForDoName:_addon.dailyDoName] objectForKey:kConfigurationShowMoveToTomorrow] boolValue];
    if (!showMoveToTomorrow) {
        NSArray *items = [_toolbar.items subarrayWithRange:NSMakeRange(1, [_toolbar.items count] - 1)];
        _toolbar.items = items;
    }
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self reloadData];
    
    trackEvent(@"dailyDo", @"enter");
}

#pragma mark - private

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
    __strong AddonData *tAddon = _todayDo.addon;
    
    trackEvent(@"dailyDo", [NSString stringWithFormat:@"quick_enter_%@", tAddon.dailyDoName]);
    
    KMAlertView *quickAlert = [[KMAlertView alloc] initWithTitle:NSLocalizedString(tAddon.dailyDoName, nil)
                                                        messages:@[NSLocalizedString(@"_quickEntryMessage", nil)]
                                                        delegate:self];
    quickAlert.userInfo = tAddon;
    [quickAlert show];
}

- (IBAction)moveTodoToTomorrow:(id)sender
{
    if ([_todayDo.check boolValue] || [_todayDo.todos count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"NoUndoToTomorrowMessage", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_confirm", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSMutableString *undoString = [NSMutableString string];
        for (int i=0; i < [_todayDo.todos count]; i++) {
            if (i != [_todayDo.todos count] - 1) {
                [undoString appendString:@" "];
            }
            
            TodoData *todo = [[_todayDo todosSortedByIndex] objectAtIndex:i];
            if (![todo.check boolValue]) {
                [undoString appendFormat:@"%d. %@", i + 1, todo.content];
            }
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"MoveToTomorrowMessage", nil), undoString]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"MoveToTomorrow", nil), nil];
        [alert show];
    }
}

- (IBAction)edit:(id)sender
{
    [_listView setEditing:!_listView.editing animated:YES];
    
    UIButton *editButton = sender;
    if (_listView.editing) {
        [editButton setTitle:NSLocalizedString(@"_done", nil) forState:UIControlStateNormal];
    }
    else {
        [editButton setTitle:NSLocalizedString(@"_edit", nil) forState:UIControlStateNormal];
    }
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [[DailyDoManager sharedManager] moveDailyDoUndos:_todayDo toAnother:_tomorrowDo];
        [self reloadData];
    }
}

#pragma mark - KMAlertViewDelegate

- (void)kmAlertView:(KMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *tContent = alertView.textView.text;
        if (!KMEmptyString(tContent)) {
            AddonData *tAddon = (AddonData *)alertView.userInfo;
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:tAddon];
            TodoData *todo = [todayDo insertNewTodoAtIndex:[todayDo.todos count]];
            todo.content = tContent;
            
            [[KMModelManager sharedManager] saveContext:nil];
            
            [_todayDo detectTodos];
            [self reloadData];
        }
    }
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
        if (_todayDoUnfold) {
            ret += [_properties count] + ([[_configurations objectForKey:kConfigurationShowTimelineKey] boolValue] ? 1 : 0);
        }
    }
    else if (section == _tomorrowSectionIndex) {
        ret = [_tomorrowDo.todos count] > 0 ? 1 : 0;
    }
    else if (section == _loggedSectionIndex) {
        ret = [_loggedDos count];
    }
    
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ret = CommonCellHeight;
    
    if (indexPath.section == _todaySectionIndex) {
        if (indexPath.row == 0) {
            ret = [DailyDoTodayCell heightOfCellForDailyDo:_todayDo unfold:_todayDoUnfold];
        }
        else {
            if (indexPath.row == 1) {
                ret = [DailyDoTodoCell heightOfCellForDailyDo:_todayDo];
            }
        }
    }
    else if (indexPath.section == _tomorrowSectionIndex) {
       ret = [_tomorrowDo.todos count] == 0 ? 0.f : [DailyDoTomorrowCell heightOfCellForDailyDo:_tomorrowDo unfolded:_tomorrowDoUnfold]; 
    }
    else if (indexPath.section == _loggedSectionIndex) {
        ret = [DailyDoLoggedCell heightOfCellForDailyDo:[_loggedDos objectAtIndex:indexPath.row]
                                               unfolded:(indexPath.row == _loggedDoUnfoldIndex)];
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
    
    if (indexPath.section == _todaySectionIndex) {
        if (indexPath.row == 0) {
            DailyDoTodayCell *cell = [tableView dequeueReusableCellWithIdentifier:todayDoCell];
            cell.dailyDo = _todayDo;
            cell.unfolded = _todayDoUnfold;
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
        cell.unfolded = _tomorrowDoUnfold;
        return cell;
    }
    else if (indexPath.section == _loggedSectionIndex) {
        DailyDoLoggedCell *cell = [tableView dequeueReusableCellWithIdentifier:loggedDoCell];
        cell.loggedDo = [_loggedDos objectAtIndex:indexPath.row];
        cell.unfolded = indexPath.row == _loggedDoUnfoldIndex;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(KMTableViewCell *)cell refreshUI];
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
    if (indexPath.section == _todaySectionIndex && indexPath.row != 0) {
        return NO;
    }
    return YES;
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
    if (!(_todayDoUnfold && [[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[DailyDoTodoCell class]])) {
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
        if (_todayDoUnfold) {
            if (indexPath.row == 0) {
                trackEvent(@"dailyDo", [NSString stringWithFormat:@"select_today_%@", _todayDo.addon.dailyDoName]);
                
                _todayDoUnfold = NO;
            }
        }
        else {
            _todayDoUnfold = YES;
        }
    }
    else if (indexPath.section == _tomorrowSectionIndex) {
        trackEvent(@"dailyDo", [NSString stringWithFormat:@"select_tomorrow_%@", _todayDo.addon.dailyDoName]);
        _tomorrowDoUnfold = !_tomorrowDoUnfold;
    }
    else if (indexPath.section == _loggedSectionIndex) {
        trackEvent(@"dailyDo", [NSString stringWithFormat:@"select_log_%@", _todayDo.addon.dailyDoName]);
        _loggedDoUnfoldIndex = (indexPath.row == _loggedDoUnfoldIndex) ? LoggedDoUnfoldDefaultIndex : indexPath.row;
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
