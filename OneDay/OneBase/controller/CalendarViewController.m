//
//  CalendarViewController.m
//  OneDay
//
//  Created by kimimaro on 13-10-29.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "CalendarViewController.h"
#import "DailyCalendarView.h"
#import "CalendarDayCellView.h"
#import "DailyDoBase.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "DailyDoManager.h"
#import "SMDetector.h"
#import "DailyPeriod.h"


@interface CalendarViewController () <MNCalendarViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    BOOL _showPicker;
}
@property (nonatomic) DailyDoBase *pickDailyDo;
@end


@implementation CalendarViewController

- (NSString *)pageNameForTrack
{
    return [NSString stringWithFormat:@"CalendarPage_%@", _addon.dailyDoName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _calendarView.delegate = self;
    _calendarView.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    _calendarView.fromDate = [NSDate dateWithDaysBeforeNow:DailyCalendarBeforeDays];
    _calendarView.toDate = [NSDate dateWithDaysFromNow:DailyCalendarAfterDays];
    _calendarView.selectedDate = [NSDate date];
    [_calendarView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_calendarView scrollToSelectedDate:^{
        if (_showPickerWhenAppear) {
            [self showPickerView];
        }
    }];
}

#pragma mark - Actions

- (IBAction)pickConfirmButtonClicked:(id)sender
{
    NSLog(@"confirm");
}

- (IBAction)pickCancelButtonClicked:(id)sender
{
    NSLog(@"cancel");
}

#pragma mark - private

- (void)showPickerView
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         if (!_showPicker) {
                             setFrameWithOrigin(_pickerContainer, 0, SSHeight(self.view) - SSHeight(_pickerContainer));
                             _showPicker = YES;
                         }
                         else {
                             setFrameWithOrigin(_pickerContainer, 0, SSHeight(self.view));
                             _showPicker = NO;
                         }
                     }
                     completion:^(BOOL finished){
                         NSLog(@"picker:%@", _pickerContainer);
                     }];
}

#pragma mark - MNCalendarViewDelegate

- (void)calendarView:(MNCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    self.pickDailyDo = [[DailyDoManager sharedManager] dailyDoInList:_dailyDos atDate:date];
    [self showPickerView];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 7;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *ret = @"";
    switch (row) {
        case 0:
            ret = NSLocalizedString(@"PeriodFirstDay", nil);
            break;
        case 1:
            ret = NSLocalizedString(@"PeriodSecondDay", nil);
            break;
        case 2:
            ret = NSLocalizedString(@"PeriodThirdDay", nil);
            break;
        case 3:
            ret = NSLocalizedString(@"PeriodFourthDay", nil);
            break;
        case 4:
            ret = NSLocalizedString(@"PeriodFifthDay", nil);
            break;
        case 5:
            ret = NSLocalizedString(@"PeriodSixthDay", nil);
            break;
        case 6:
            ret = NSLocalizedString(@"PeriodSeventhDay", nil);
            break;
            
        default:
            break;
    }
    return ret;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (!_pickDailyDo) {
        self.pickDailyDo = [DailyPeriod dataEntityWithInsert:YES];
        [_pickDailyDo updateWithDictionary:@{}];
        _pickDailyDo.addon = _addon;
    }
    
    [[_pickDailyDo todosSortedByIndex] enumerateObjectsUsingBlock:^(TodoData *todo, NSUInteger idx, BOOL *stop){
        if (todo.days == nil || CheckStringInvalid(todo.days)) {
            todo.days = [[SMDetector defaultDetector] stringForValue:@(row+1) byType:SmarkDetectTypeDays];
            todo.content = todo.days;
        }
    }];
    [_pickDailyDo detectTodos];
    
    [_calendarView reloadData];
    [self showPickerView];
    SSLog();
}

@end
