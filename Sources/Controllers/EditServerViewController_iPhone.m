//
//  EditServerViewControlleriPhoneViewController.m
//  Shtirlits
//
//  Created by bartle on 12/27/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "EditServerViewController_iPhone.h"
#import "ZabbixServer.h"
#import "NSURL+URLfromString.h"
#import "UIButton+BarButton.h"
#import "UIImage+Color.h"

static const CGRect kPaddingRect = { 0, 0, 15, 20 };
static const NSInteger intend = 20;
static const NSInteger switchWidth = 80;
static const NSInteger switchHeight = 40;
static const NSInteger switchLabelWidth = 200;

@interface EditServerViewController_iPhone () <UITextFieldDelegate>

@end


@implementation EditServerViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *serverBackgroundImage = [UIImage imageNamed:@"new_server_baackground.png"];
    serverBackgroundImage = [serverBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImageView *newServerView = [[UIImageView alloc] initWithImage:serverBackgroundImage];
    newServerView.frame = CGRectMake(intend/4, intend/2, self.view.bounds.size.width - intend/2, newServerView.image.size.height);
    newServerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:newServerView];
    
    self.urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(intend, intend, self.view.frame.size.width - intend*2, newServerView.frame.size.height/2 - intend)];
    self.urlTextField.textColor = [UIColor whiteColor];
    self.urlTextField.delegate = self;
    self.urlTextField.clearButtonMode = UITextFieldViewModeAlways;
    if ([self.urlTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.urlTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    } else {
        [self.urlTextField setPlaceholder:NSLocalizedString(@"URL", nil)];
    }
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    self.urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.urlTextField];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(intend, CGRectGetMaxY(self.urlTextField.frame) + intend, self.view.frame.size.width - intend*2, newServerView.frame.size.height/2 - intend)];
    self.nameTextField.textColor = [UIColor whiteColor];
    self.nameTextField.delegate = self;
    self.nameTextField.clearButtonMode = UITextFieldViewModeAlways;
    if ([self.nameTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    } else {
        [self.nameTextField setPlaceholder:NSLocalizedString(@"Name", nil)];
    }
    self.nameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.nameTextField];
    
    self.trustCerteficateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(newServerView.frame.origin.x, self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height + intend, switchWidth, switchHeight)];
    self.trustCerteficateSwitch.onTintColor = [UIColor darkGrayColor];
    [self.view addSubview:self.trustCerteficateSwitch];
    
    UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.trustCerteficateSwitch.frame.origin.x + self.trustCerteficateSwitch.frame.size.width + 5, self.trustCerteficateSwitch.frame.origin.y + 4, switchLabelWidth, switchHeight)];
    switchLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    switchLabel.minimumFontSize = 14;
    switchLabel.textColor = [UIColor whiteColor];
    switchLabel.backgroundColor = [UIColor clearColor];
    switchLabel.text = NSLocalizedString(@"Trust self-signed SSL-certificate", nil);
    [switchLabel sizeToFit];
    [self.view addSubview:switchLabel];
    
    if (self.server) {
        self.navigationItem.title = self.server.name;
        self.nameTextField.text = self.server.name;
        self.urlTextField.text = self.server.url;
        self.trustCerteficateSwitch.on = self.server.isTrustedSertificate;
    } else {
        self.navigationItem.title = NSLocalizedString(@"New server", nil);
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    [rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    rightButton.tintColor = [UIColor colorWithWhite:180.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nb_back_button"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.clipsToBounds = NO;
}

- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setUrlTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (void)backButtonDidPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkIncludingNameInArray {
    BOOL isInclud = NO;
    for (ZabbixServer *zabServer in self.items) {
        if ([zabServer.name isEqualToString:self.nameTextField.text]) {
            [self showErrorMessage:NSLocalizedString(@"You already have such name", nil) withTitle:NSLocalizedString(@"Error", nil)];
            isInclud = YES;
            break;
        }
        if ([zabServer.url isEqualToString:self.urlTextField.text]) {
            [self showErrorMessage:NSLocalizedString(@"You already have such URL", nil) withTitle:NSLocalizedString(@"Error", nil)];
            isInclud = YES;
            break;
        }
    }
    return isInclud;
}

- (void)createNewServer {
    ZabbixServer *server = nil;
    if (self.server) {
        server = self.server;
    } else {
        server = [ZabbixServer new];
        [self.items addObject:server];
        [Flurry logEvent:@"The Server was added"];
    }
    server.name = self.nameTextField.text;
    server.url = self.urlTextField.text;
    server.isTrustedSertificate = self.trustCerteficateSwitch.on;
}

- (void)onDone:(id)sender {
    if (self.nameTextField.text.length && self.urlTextField.text.length) {
        if (![NSURL detectURLFromString:self.urlTextField.text]) {
            [self showErrorMessage:NSLocalizedString(@"URL is not correct", nil) withTitle:NSLocalizedString(@"Error", nil)];
            return;
        }
        if ([self checkIncludingNameInArray]) {
            return;
        }
        [self createNewServer];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showErrorMessage:NSLocalizedString(@"Please enter server name and URL", nil) withTitle:NSLocalizedString(@"Error", nil)];
    }
}

- (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
    [alert show];
}


#pragma mark Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.urlTextField) {
        [self.nameTextField becomeFirstResponder];
    }
    if (textField == self.nameTextField) {
        [self onDone:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.urlTextField) {
        NSMutableString *newString = [NSMutableString stringWithString:self.urlTextField.text];
        if (string.length > 0) {
            [newString insertString:string atIndex:range.location];
        } else {
            [newString replaceCharactersInRange:range withString:@""];
        }
        NSString *url = [NSString stringWithString:newString];
        self.nameTextField.text = [NSURL hostFromString:url];
    }
    return YES;
}

@end
