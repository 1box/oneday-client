//
//  ContactUsViewController.m
//  MedAlarm
//
//  Created by Kimi on 12-10-16.
//  Copyright (c) 2012年 Kimi Yu. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "ContactUsViewController.h"
#import "KMTableView.h"

@interface ContactUsViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation ContactUsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    trackEvent(@"contactUs", @"enter");
    [_listView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: // contact mail
        {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
                controller.modalPresentationStyle = UIModalPresentationFormSheet;
                controller.mailComposeDelegate = self;
                [controller setToRecipients:[NSArray arrayWithObject:@"oneboxcode@gmail.com"]];
                [controller setSubject:NSLocalizedString(@"Onebox design feedback", nil)];
                if (controller) [self.navigationController presentViewController:controller animated:YES completion:nil];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Cannot mail", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
        }
            break;
        case 1: // contect twitter
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/oneboxappp"]];
            trackEvent(@"contactUs", @"contact_tweet");
            break;
        case 2: // contect sina weibo
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weibo.com/oneboxapp"]];
            trackEvent(@"contactUs", @"contact_sina");
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_listView updateBackgroundViewForCell:cell atIndexPath:indexPath backgroundViewType:KMTableViewCellBackgroundViewTypeNormal];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    trackEvent(@"contactUs", @"contact_mail");
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
