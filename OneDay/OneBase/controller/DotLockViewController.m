//
//  DotLockViewController.m
//  OneDay
//
//  Created by Kimimaro on 13-6-8.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "DotLockViewController.h"
#import "NormalCircle.h"
#import "PasswordManager.h"


@interface DotLockViewController () <LockScreenDelegate>
@property (nonatomic) NSInteger wrongGuessCount;
@property (nonatomic) NSNumber *tempPattern;
@end


@implementation DotLockViewController

- (NSString *)pageNameForTrack
{
    return @"DotLock";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    self.lockScreenView = [[SPLockScreen alloc]initWithFrame:CGRectMake(0, 0, SSWidth(self.view), SSHeight(self.view))];
	_lockScreenView.center = self.view.center;
	_lockScreenView.delegate = self;
	_lockScreenView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_lockScreenView];
    [self.view sendSubviewToBack:_lockScreenView];
    
    _passwordSwitch.on = [[PasswordManager sharedManager] dotLockPasswordOpen];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateStatus];
}

#pragma mark - Actions

- (IBAction)passwordSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    [[PasswordManager sharedManager] setDotLockPasswordOpen:aSwitch.isOn];
    
    if (!aSwitch.isOn) {
        [self dismiss:nil];
    }
}

- (IBAction)dismiss:(id)sender
{
    if (_finishBlock) {
        _finishBlock(self);
    }
    [super dismiss:sender];
    
    if (_delegate && [_delegate respondsToSelector:@selector(lockViewControllerHasDismiss:)]) {
        [_delegate lockViewControllerHasDismiss:self];
    }
}

#pragma mark - private

- (void)updateStatus
{
    _passwordSwitch.hidden = (_infoLabelStatus != InfoStatusFirstTimeSetting);
    
	switch (self.infoLabelStatus) {
		case InfoStatusFirstTimeSetting:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusFirstTimeSettingText", nil);
			break;
		case InfoStatusConfirmSetting:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusConfirmSettingText", nil);
			break;
		case InfoStatusFailedConfirm:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusFailedConfirmText", nil);
			break;
		case InfoStatusNormal:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusNormalText", nil);
			break;
		case InfoStatusFailedMatch:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusFailedMatchText", nil);
			break;
		case InfoStatusSuccessMatch:
			self.infoLabel.text = NSLocalizedString(@"InfoStatusSuccessMatchText", nil);
			break;
			
		default:
			break;
	}
}

#pragma mark - LockScreenDelegate

- (void)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSNumber *)patternNumber
{
	switch (self.infoLabelStatus) {
		case InfoStatusFirstTimeSetting:
        {
            self.tempPattern = patternNumber;
			self.infoLabelStatus = InfoStatusConfirmSetting;
			[self updateStatus];
        }
			break;
		case InfoStatusFailedConfirm:
		case InfoStatusConfirmSetting:
            if ([patternNumber isEqualToNumber:_tempPattern]) {
                [[PasswordManager sharedManager] setDotLockPassword:[_tempPattern stringValue]];
                self.tempPattern = nil;
                [self dismiss:nil];
            }
			else {
                self.tempPattern = nil;
				self.infoLabelStatus = InfoStatusFailedConfirm;
				[self updateStatus];
			}
			break;
		case  InfoStatusNormal:
		case InfoStatusFailedMatch:
            if ([[PasswordManager sharedManager] checkDotLockPassword:[patternNumber stringValue]]) {
                self.infoLabelStatus = InfoStatusSuccessMatch;
                [self updateStatus];
                [self dismiss:nil];
            }
            else {
				self.infoLabelStatus = InfoStatusFailedMatch;
				self.wrongGuessCount ++;
				[self updateStatus];
            }
			break;
		case InfoStatusSuccessMatch:
			[self dismiss:nil];
			break;
		default:
			break;
	}
}

@end

