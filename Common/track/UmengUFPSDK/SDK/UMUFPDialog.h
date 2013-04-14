//
//  UMUFPDialog.h
//  UFP
//
//  Created by liu yu on 4/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMUFPDialogDelegate;

@interface UMUFPDialog : UIView {
@private        
    id<UMUFPDialogDelegate> _delegate;
}

@property (nonatomic, assign) id<UMUFPDialogDelegate> delegate; 

/** 
 
 This method return a UMDialog object
 
 @param  appkey appkey get from www.umeng.com
 @param  slotId slotId get from www.ufp.umeng.com
 
 @return a UMDialog object
 */

- (id)initWithAppkey:(NSString *)appkey slotId:(NSString *)slotId;

/** 
 
 Dialog will show Asynchronous， after all the releated data loaded
 
 */

- (void)showAlertView;

/** 
 
 This method set channel for this app, the default channel is App Store, call this method if you want to set channel for another value, don't need to call this method among different views, only once is enough
 
 */

+ (void)setAppChannel:(NSString *)channel;

@end

@protocol UMUFPDialogDelegate <NSObject>

@optional

- (void)dialogWillShow:(UMUFPDialog *)dialog;      //called when will appear the 1st time, implement this mothod if you want to change animation for the dialog appear or do something else before dialog appear
- (void)dialogWillDisappear:(UMUFPDialog *)dialog; //called before dialog will disappear
- (void)dialog:(UMUFPDialog *)dialog didLoadDataFinish:(NSURL *)targetUrl;      //called when promoter list loaded from the server
- (void)dialog:(UMUFPDialog *)dialog didLoadDataFailWithError:(NSError *)error; //called when promoter list loaded failed for some reason, for example network problem or the promoter list is empty
- (void)dialog:(UMUFPDialog *)dialog openAdsForFlag:(NSString *)flagStr;

@end
