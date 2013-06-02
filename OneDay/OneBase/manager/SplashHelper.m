//
//  SplashHelper.m
//  OneDay
//
//  Created by Kimimaro on 13-5-10.
//  Copyright (c) 2013年 Kimi Yu. All rights reserved.
//

#import "SplashHelper.h"
#import "AppDelegateBase.h"
#import "AddonManager.h"
#import "DailyDoManager.h"
#import "AddonData.h"
#import "DailyDoBase.h"
#import "TodoData.h"
#import "UILabel+UILabelAdditions.h"

typedef NS_ENUM(NSInteger, SplashRandomTextType) {
    SplashRandomTextTypeQuote = 0,
    SplashRandomTextTypeTodayDo
};


@interface SplashHelpModel : NSObject
@property (nonatomic) SplashRandomTextType textType;
@property (nonatomic) NSString *splashTitle;
@property (nonatomic) NSString *splashText;

+ (SplashHelpModel *)randomModel;
@end


@interface SplashHelpAnimationView : UIView
@property (nonatomic) SplashHelpModel *helpModel;
@property (nonatomic) UIImageView *splashView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *textLabel;
@end


@interface SplashHelper ()
@property (nonatomic) UIImageView *animationView1;
@property (nonatomic) SplashHelpAnimationView *animationView2;
@property (nonatomic) NSMutableArray *finishedBlocks;
@end


@implementation SplashHelper

static SplashHelper *_sharedHelper = nil;
+ (SplashHelper *)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHelper = [[SplashHelper alloc] init];
    });
    return _sharedHelper;
}

+ (id)alloc
{
    NSAssert(_sharedHelper == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _hasFliped = NO;
        self.finishedBlocks = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

#pragma mark - public

- (void)addFinishedBlock:(LoadFlipSplashFinishedBlock)finishedBlock
{
    [_finishedBlocks addObject:[finishedBlock copy]];
}

- (void)prepareSplashAnimationView
{
    UIView *containerView = ((AppDelegateBase *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    NSString *imageName = @"Default.png";
    if ([KMCommon is568Screen]) {
        imageName = @"Default-568h.png";
    }
    self.animationView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [containerView addSubview:_animationView1];
    
    self.animationView2 = [[SplashHelpAnimationView alloc] initWithFrame:containerView.bounds];
    _animationView2.helpModel = [SplashHelpModel randomModel];
}

- (void)splashFlipAnimation
{
    if (_animationView1 && _animationView2) {
        [UIView transitionFromView:_animationView1
                            toView:_animationView2
                          duration:1.1f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            
                            [UIView animateWithDuration:0.8f animations:^{
                                _animationView2.alpha = 0.05f;
                            } completion:^(BOOL finished2) {
                                
                                [_animationView1 removeFromSuperview];
                                [_animationView2 removeFromSuperview];
                                
                                self.animationView1 = nil;
                                self.animationView2 = nil;
                                
                                _hasFliped = YES;
                                
                                [_finishedBlocks enumerateObjectsUsingBlock:^(LoadFlipSplashFinishedBlock block, NSUInteger idx, BOOL *stop) {
                                    block(self);
                                }];
                            }];
                        }];
    }
}

@end

#pragma mark - SplashHelpModel

@implementation SplashHelpModel
+ (SplashHelpModel *)randomModel
{
    NSString *randomTitle = @"";
    NSString *randomText = @"一天-爱计划，爱记录";
    
    int textType = arc4random()%2;
    switch (textType) {
        case SplashRandomTextTypeQuote:
        {
            NSArray *quotes = @[@"好的一天是成功的开始", @"今日事，今日毕", @"专注目标，日拱一卒，永不言败!"];
            int index = arc4random()%[quotes count];
            randomText = [quotes objectAtIndex:index];
        }
            break;
        case SplashRandomTextTypeTodayDo:
        {
            NSArray *addons = [[AddonManager sharedManager] currentAddons];
            int index = arc4random()%[addons count];
            
            DailyDoBase *todayDo = [[DailyDoManager sharedManager] todayDoForAddon:[addons objectAtIndex:index]];
            randomTitle = [NSString stringWithFormat:@"%@: ", NSLocalizedString(todayDo.addon.title, nil)];
            
            NSArray *todos = [todayDo todosSortedByIndex];
            if (todayDo && [todos count] > 0) {
                int todoIndex = arc4random()%[todos count];
                TodoData *todo = [todos objectAtIndex:todoIndex];
                randomText = [todo pureContent];
            }
            else {
                randomText = todayDo.todayText;
            }
        }
            break;
        default:
            break;
    }
    
    SplashHelpModel *ret = [[SplashHelpModel alloc] init];
    ret.textType = textType;
    ret.splashTitle = randomTitle;
    ret.splashText = randomText;
    return ret;
}
@end

#pragma mark - SplashHelpAnimationView

@implementation SplashHelpAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *imageName = @"splash-screen-no-logo.png";
        if ([KMCommon is568Screen]) {
            imageName = @"splash-screen-no-logo-568h.png";
        }
        self.splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self addSubview:_splashView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        self.textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setHelpModel:(SplashHelpModel *)helpModel
{
    _helpModel = helpModel;
    if (_helpModel) {
        _titleLabel.text = _helpModel.splashTitle;
        _textLabel.text = _helpModel.splashText;
        
        [self updateThemes];
        [self updateFrames];
    }
}

- (void)updateThemes
{
    if (_helpModel.textType == SplashRandomTextTypeTodayDo) {
        _titleLabel.font = [UIFont boldSystemFontOfSize:27.f];
        _textLabel.font = [UIFont systemFontOfSize:20.f];
    }
    else {
        _textLabel.font = [UIFont boldSystemFontOfSize:27.f];
    }
}

- (void)updateFrames
{
    _splashView.frame = self.bounds;
    [_titleLabel sizeToFit];
    [_textLabel heightThatFitsWidth:SSWidth(self) - 40.f];
    
    if (_helpModel.textType == SplashRandomTextTypeTodayDo) {
        _textLabel.center = CGPointMake(SSWidth(self)/2, SSHeight(self)/2);
        setFrameWithOrigin(_titleLabel, 20, SSMinY(_textLabel) - SSHeight(_titleLabel) - 15.f);
    }
    else {
        _textLabel.center = CGPointMake(SSWidth(self)/2, SSHeight(self)/2);
    }
}

@end
