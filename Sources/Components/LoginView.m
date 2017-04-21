//
//  LoginView.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "LoginView.h"
#import "UIColor+MoreColors.h"
#import "NSString+AdditionsMethods.h"
#import "NSURL+URLfromString.h"
#import "LoggedUser.h"
#import "CommonConstants.h"
#import "UITextField+Placeholder.h"

NSString *const kUserSignInNotification = @"userDidSignInNotification";
NSString *const kUserDidFailLoginNotification = @"userDidFailLoginNotification";

static CGFloat const kHightBetweenButtonAndTextField = 8.0;

static const CGRect kPaddingRect = {
        0, 0, 15, 20
};

@interface LoginView () <LoggedUserDelegate> {
    UITextField *userTextField_;
    UIActionSheet *cancelActionSheet_;
    UIButton *loginButton_;
    CGFloat heightItems;
    CGFloat heightBetweenItems;
}

- (void)setLoginButtonEnable:(BOOL)buttonEnable;
- (BOOL)allTextFieldsHaveValue;

@end

@implementation LoginView
@synthesize delegate = delegate_;
@synthesize uRLTextField = uRLTextField_;
@synthesize passwordTextField = passwordTextField_;

- (id)init {
    if ([super init] != nil) {
        [self addAllVisibleElements];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addAllVisibleElements];
    }
    return self;
}

#pragma mark Create visual elements

- (UITextField *)createTextField {
    UITextField *textField = nil;
    CGRect frame = self.bounds;
    frame.size.height = heightItems;
    textField = [[UITextField alloc] initWithFrame:frame];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setFont:[UIFont fontWithName:@"Helvetica"
                                       size:17]];
    [textField setTextColor:[UIColor whiteColor]];
    [textField setContentVerticalAlignment
    :UIControlContentVerticalAlignmentCenter];
    [textField setTextAlignment:UITextAlignmentLeft];
    [textField setDelegate:self];
    UIView *paddingView = [[UIView alloc] initWithFrame:kPaddingRect];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.clearButtonMode = YES;
    [textField setReturnKeyType:UIReturnKeyNext];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return textField;
}

- (UIButton *)createButton {
    CGRect frame = self.bounds;
    frame.size = CGSizeMake(307, 45);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    [button setTitle:NSLocalizedString(@"Log in", nil) forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithWhite:33.0f/255.0f alpha:1.0]];
    [button addTarget:self
               action:@selector(loginButtonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.enabled = NO;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return button;
}

- (void)addAllVisibleElements {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        heightItems = [UIImage imageNamed:kImgLoginView].size.height / 3;
        heightBetweenItems = 0.0;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        heightItems = [UIImage imageNamed:kImgLoginView].size.height / 3;
        heightBetweenItems = 0.0;
    }
// add uRLTextField_
    uRLTextField_ = [self createTextField];
    [uRLTextField_ setKeyboardType:UIKeyboardTypeURL];
    uRLTextField_.clearButtonMode = UITextFieldViewModeNever;
    if ([uRLTextField_ respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        uRLTextField_.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    } else {
        [uRLTextField_ setPlaceholder:NSLocalizedString(@"URL", nil)];
    }
    [self addSubview:uRLTextField_];

    UIImageView *acessoryImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kImgLoginRightArrow]];
    CGRect rect = acessoryImage.frame;
    rect.size.height = [UIImage imageNamed:kImgLoginRightArrow].size.height;
    rect.size.width = [UIImage imageNamed:kImgLoginRightArrow].size.width;
    rect.origin.x = uRLTextField_.bounds.size.width - rect.size.width - 7;
    rect.origin.y = (uRLTextField_.bounds.size.height - rect.size.height) / 2.0;
    acessoryImage.frame = rect;
    acessoryImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:acessoryImage];
    
    UIButton *selectUrlButton = [[UIButton alloc] initWithFrame:CGRectMake(uRLTextField_.frame.origin.x + uRLTextField_.frame.size.width * 0.8, uRLTextField_.frame.origin.y, uRLTextField_.frame.size.width * 0.2 + 20, uRLTextField_.frame.size.height)];
    [selectUrlButton addTarget:self
                        action:@selector(forwardButtonDidPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    selectUrlButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:selectUrlButton];

    rect = uRLTextField_.textInputView.frame;
    rect.size.width = selectUrlButton.frame.origin.x;
    uRLTextField_.textInputView.frame = rect;
  

// add loginTextField_
    CGRect newFrame = uRLTextField_.frame;
    userTextField_ = [self createTextField];
    [userTextField_ setKeyboardType:UIKeyboardTypeEmailAddress];
    if ([userTextField_ respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        userTextField_.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"User Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    } else {
        [userTextField_ setPlaceholder:NSLocalizedString(@"User Name", nil)];
    }
    [self addSubview:userTextField_];
    newFrame.size.width = self.bounds.size.width;
    newFrame.origin.y += uRLTextField_.frame.size.height + heightBetweenItems;
    userTextField_.frame = newFrame;

// add passwordTextField_
    passwordTextField_ = [self createTextField];
    [passwordTextField_ setReturnKeyType:UIReturnKeyJoin];
    if ([passwordTextField_ respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        passwordTextField_.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    } else {
        [passwordTextField_ setPlaceholder:NSLocalizedString(@"Password", nil)];
    }
    [passwordTextField_ setSecureTextEntry:YES];
    [self addSubview:passwordTextField_];
    newFrame = userTextField_.frame;
    newFrame.size.width = self.bounds.size.width;
    newFrame.origin.y += userTextField_.frame.size.height + heightBetweenItems;
    passwordTextField_.frame = newFrame;

// add loginButton_
    loginButton_ = [self createButton];
    [self addSubview:loginButton_];
    newFrame = passwordTextField_.frame;
    newFrame.origin.y += heightItems + kHightBetweenButtonAndTextField;
    newFrame.size = loginButton_.frame.size;
    newFrame.origin.x -= (newFrame.size.width - self.bounds.size.width) / 2 - 1;
    loginButton_.frame = newFrame;
}

#pragma mark Actions

- (void)updateLoginButton
{
    [self setLoginButtonEnable: [self allTextFieldsHaveValue]];
}

- (BOOL)allTextFieldsHaveValue {
    if (uRLTextField_.text.length > 0 &&
            userTextField_.text.length > 0 &&
            passwordTextField_.text.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setLoginButtonEnable:(BOOL)buttonEnable {
    if (buttonEnable) {
        loginButton_.enabled = YES;
        loginButton_.alpha = 1.0f;
    } else {
        loginButton_.enabled = NO;
        loginButton_.alpha = 0.4f;
    }
}

- (void)showDefaultValues
{
    userTextField_.text = [LoggedUser sharedUser].nameUser;
    uRLTextField_.text = [LoggedUser sharedUser].urlString;
    passwordTextField_.text = [LoggedUser sharedUser].password;
    [self updateLoginButton];
    [LoggedUser sharedUser].delegate = self;
    [[LoggedUser sharedUser] loginWithDefaultValues];
}

- (void)loginButtonPressed:(id)sender
{
    if (![NSURL detectURLFromString:uRLTextField_.text]) {
        [self showErrorMessage:NSLocalizedString(@"URL is not correct", nil) withTitle:NSLocalizedString(@"Error", nil)];
        return;
    }
    if (![NSString isStringWithoutWhitespaces:userTextField_.text]) {
        [self showErrorMessage:NSLocalizedString(@"Please check your Name", nil) withTitle:NSLocalizedString(@"Error", nil)];
        return;
    }
    if (![NSString isStringWithoutWhitespaces:passwordTextField_.text]) {
        [self showErrorMessage:NSLocalizedString(@"Please check your Password", nil) withTitle:NSLocalizedString(@"Error", nil)];
        return;
    }
    [self hideKeyboard];
    [self showCancelActionSheet];
    [self requestLogin];
}

- (void)forwardButtonDidPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(forwardButtonInURLTextFieldDidPressed)]) {
        [self.delegate forwardButtonInURLTextFieldDidPressed];
    }
}

#pragma mark - Login User
- (void)requestLogin
{
    [self setLoginButtonEnable:NO];
    [LoggedUser sharedUser].delegate = self;
    [[LoggedUser sharedUser] startLogin:userTextField_.text urlString:uRLTextField_.text userPassword:passwordTextField_.text];
}

#pragma mark LoggedUserDelegate
- (void)didSuccessfullyLogin
{
    [self setLoginButtonEnable:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserSignInNotification object:nil];
    [cancelActionSheet_ dismissWithClickedButtonIndex:-1 animated:0];
}

- (void)didFailLoginWithError:(NSError *)error
{
    [self setLoginButtonEnable:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidFailLoginNotification object:nil];
    [cancelActionSheet_ dismissWithClickedButtonIndex:-1 animated:0];
    if (error.code == -1012) {
        [self showCertificateError];
    } else {
        [self showErrorMessage:[error localizedDescription] withTitle:NSLocalizedString(@"Error", nil)];
    }
}

- (void)didStartRequest
{
}

#pragma mark
- (void)showCancelActionSheet
{
    if (!cancelActionSheet_) {
        cancelActionSheet_ = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    [cancelActionSheet_ setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [cancelActionSheet_ showInView:self];
}

- (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
    [alert show];
}

- (void)showCertificateError
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Attention!", nil)
                          message:NSLocalizedString(@"The server's SSL certificate is untrusted. Would you like to continue?", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
    [alert show];
}

- (void)hideKeyboard
{
    [userTextField_ resignFirstResponder];
    [passwordTextField_ resignFirstResponder];
    [uRLTextField_ resignFirstResponder];
}

#pragma mark - Actionsheet Delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == cancelActionSheet_ && buttonIndex == cancelActionSheet_.cancelButtonIndex) {
        [[LoggedUser sharedUser] cancelLoginRequest];
        [self setLoginButtonEnable:YES];
    }
}

#pragma mark - UIAlertView Dalegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[LoggedUser sharedUser] makeTrustedServer];
        [self requestLogin];
    }
}

#pragma mark Delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == uRLTextField_) {
        [userTextField_ becomeFirstResponder];
    }
    if (textField == userTextField_) {
        [passwordTextField_ becomeFirstResponder];
    }
    if (textField == passwordTextField_) {
        if (loginButton_.enabled) {
            [self loginButtonPressed:nil];
        }
    }
    if ([delegate_ respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate_ textFieldShouldReturn:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([delegate_ respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate_ textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateLoginButton];
}

- (BOOL)isDeleteAllText:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location == 0 && range.length == [textField.text length] && [string length] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self isDeleteAllText:textField shouldChangeCharactersInRange:range replacementString:string]) {
        [self setLoginButtonEnable:NO];
    } else {
        [self updateLoginButton];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self setLoginButtonEnable:NO];
    return YES;
}

- (void)dealloc
{
    self.delegate = nil;
    userTextField_.delegate = nil;
    passwordTextField_.delegate = nil;
    uRLTextField_.delegate = nil;
    cancelActionSheet_.delegate = nil;
}

@end
