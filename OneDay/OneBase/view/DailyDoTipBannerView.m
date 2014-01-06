//
//  DailyDoTipBannerView.m
//  Article
//
//  Created by Yu Tianhang on 13-6-5.
//
//

#import "DailyDoTipBannerView.h"
#import "UIColor+UIColorAddtions.h"

@interface DailyDoTipBannerView()

@end

@implementation DailyDoTipBannerView

- (IBAction)confirm:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(tipBannerViewConfirmButtonClicked:)]) {
        [_delegate tipBannerViewConfirmButtonClicked:self];
    }
}

- (IBAction)close:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(tipBannerViewCloseButtonClicked:)]) {
        [_delegate tipBannerViewCloseButtonClicked:self];
    }
}

@end
