//
//  DailyDoTipBannerView.h
//  Article
//
//  Created by Yu Tianhang on 13-6-5.
//
//

#import <UIKit/UIKit.h>
#import "KMViewBase.h"

typedef NS_ENUM(NSInteger, DailyDoTipBannerDisplayStatus) {
    DailyDoTipBannerDisplayStatusShow = 0,
    DailyDoTipBannerDisplayStatusShowing,
    DailyDoTipBannerDisplayStatusHide,
    DailyDoTipBannerDisplayStatusHiding
};

@class DailyDoTipBannerView;

@protocol DailyDoTipBannerViewDelegate <NSObject>
@optional
- (void)tipBannerViewConfirmButtonClicked:(DailyDoTipBannerView *)tipBannerView;
- (void)tipBannerViewCloseButtonClicked:(DailyDoTipBannerView *)tipBannerView;
@end

@interface DailyDoTipBannerView : KMViewBase

@property (nonatomic, weak) id<DailyDoTipBannerViewDelegate> delegate;
@property (nonatomic) DailyDoTipBannerDisplayStatus displayStatus;

@property (nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic) IBOutlet UIButton *confirmButton;
@property (nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) IBOutlet UILabel *textLabel;

@end
