//
//  NotificationsViewController.m
//  Zabbkit
//
//  Created by Andrey Kosykhin on 20.06.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NotificationsViewController.h"
#import "LoggedUser.h"
#import "ZabbixRequestHelper.h"
#import "AFJSONRequestOperation.h"
#import "CommonConstants.h"
#import <MessageUI/MessageUI.h>
#import "SVProgressHUD.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "ZabbKitApplicationSettings.h"

static NSString *const kEmailAdress = @"";
static NSString *const kNotificationLink = @"https://www.zabbix.com/forum/showthread.php?p=136028";
static CGFloat const kLeftInset = 13;
static CGFloat const kTopInset = 5;

@interface NotificationsViewController () <MFMailComposeViewControllerDelegate>

@property(strong, nonatomic) UILabel *labelId;
@property(strong, nonatomic) UIButton *sendInstructionButton;
@property(strong, nonatomic) UITextView *textViewMessage;
@property(strong, nonatomic) UITextView *textViewToken;

- (void)didPressedMailButton:(id)sender;

@end


@implementation NotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addVisualItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenDidReceived:)
                                                 name:kZabbKitTokenReceivedNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"Notifications page"];
    [self setNotificationTokenId];
    [[AppDelegate sharedAppDelegate] registerPushNotification];
    [self resizeItems];
}

- (void)viewDidUnload {
    [self setTextViewToken:nil];
    [self setTextViewMessage:nil];
    [self setSendInstructionButton:nil];
    [self setLabelId:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didPressedMailButton:(id)sender {
    [self showMailComposerWithMail:kEmailAdress];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Notification

- (void)tokenDidReceived:(NSNotification *)notification {
    [self setNotificationTokenId];
}

- (void)setNotificationTokenId
{
    if ([ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken.length > 0) {
        self.textViewToken.text = [ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken;
    } else {
        self.textViewToken.text = @"id ...";
    }
}

#pragma mark Resize

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resizeItems];
}

- (void)addVisualItems
{
    self.title = NSLocalizedString(@"Notifications", nil);
    
    self.textViewMessage = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textViewMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textViewMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.textViewMessage.textColor = [UIColor whiteColor];
    self.textViewMessage.backgroundColor = [UIColor clearColor];
    self.textViewMessage.text = [NSString stringWithFormat:NSLocalizedString(@"NotificationsMessage %@", @"NotificationsMessage %@"), kNotificationLink];
    self.textViewMessage.dataDetectorTypes = UIDataDetectorTypeAll;
    self.textViewMessage.editable = NO;
    [self.view addSubview:self.textViewMessage];
    
    self.labelId = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelId.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.labelId.textColor = [UIColor colorWithWhite:0.88f alpha:1.0f];
    self.labelId.text = NSLocalizedString(@"Your id:",nil);
    self.labelId.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.labelId.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.labelId];
    
    self.textViewToken = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textViewToken.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textViewToken.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.textViewToken.textColor = [UIColor lightGrayColor];
    self.textViewToken.backgroundColor = [UIColor colorWithWhite:58.0f/255.0f alpha:1.0f];
    self.textViewToken.text = @"id ...";
    [self.view addSubview:self.textViewToken];
    
    self.sendInstructionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendInstructionButton addTarget:self action:@selector(didPressedMailButton:) forControlEvents:UIControlEventTouchUpInside];
    self.sendInstructionButton.backgroundColor = [UIColor colorWithWhite:0.55f alpha:0.1f];
    [self.sendInstructionButton setTitle:@"Send it on email" forState:UIControlStateNormal];
    self.sendInstructionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    [self.sendInstructionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.sendInstructionButton];
}


- (void)resizeItems
{
    CGSize size = [self.textViewMessage sizeThatFits:CGSizeMake(self.view.frame.size.width - 2*kLeftInset, self.view.frame.size.height)];
    self.textViewMessage.frame = CGRectMake(kLeftInset, 0, size.width, size.height);
    self.labelId.frame = CGRectMake(kLeftInset, CGRectGetMaxY(self.textViewMessage.frame), self.view.frame.size.width - 2*kLeftInset, 20);
    self.textViewToken.frame = CGRectMake(kLeftInset, CGRectGetMaxY(self.labelId.frame), self.view.frame.size.width - 2*kLeftInset, 28);
    self.sendInstructionButton.frame = CGRectMake(kLeftInset, CGRectGetMaxY(self.textViewToken.frame) + kTopInset*2, self.view.frame.size.width - 2*kLeftInset, 46);
}

#pragma mark - Create MailComposer

- (void)showMailComposerWithMail:(NSString *)emailString {
    NSString *digsNoSpace =
            [emailString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *av = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"Failed to send mail", nil)
                      message:NSLocalizedString(@"Mail account is not configured", nil)
                     delegate:nil
            cancelButtonTitle:NSLocalizedString(@"Ok", nil)
            otherButtonTitles:nil];
        [av show];
        return;
    }
    MFMailComposeViewController *mc =
            [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setToRecipients:[NSArray arrayWithObjects:digsNoSpace, nil]];
    [mc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    if ([ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken.length > 0) {
        [mc setMessageBody:[NSString stringWithFormat:@"%@ \n\n\n %@ %@", self.textViewMessage.text, self.labelId.text, [ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken] isHTML:NO];
    } else {
        [mc setMessageBody:[NSString stringWithFormat:@"%@ \n\n\n %@ %@", self.textViewMessage.text, self.labelId.text, @"<id is not retrieved yet>"] isHTML:NO];

    }
    [self presentViewController:mc animated:YES completion:nil];
}

#pragma mark - MailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            DLog(@"Cancelled");
            break;
        case MFMailComposeResultSaved:
            DLog(@"Saved");
            break;
        case MFMailComposeResultFailed: {
            DLog(@"Failed");
            UIAlertView *av = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"Failed to send mail", nil)
                          message:[error localizedDescription]
                         delegate:nil
                cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                otherButtonTitles:nil];
            [av show];
        }
            break;
        case MFMailComposeResultSent:
            DLog(@"Sent");
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
