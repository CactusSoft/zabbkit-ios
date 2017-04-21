//
//  LoginView.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kUserSignInNotification;
extern NSString *const kUserDidFailLoginNotification;
extern NSString *const kCancelString;
extern NSString *const kButtonLogoutTitle;

@protocol LoginViewDelegate;

@interface LoginView : UIView <UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    UITextField *uRLTextField_;
    UITextField *passwordTextField_;
}
@property(nonatomic, unsafe_unretained) id <LoginViewDelegate> delegate;
@property(nonatomic, strong) UITextField *uRLTextField;
@property(nonatomic, strong) UITextField *passwordTextField;

- (void)hideKeyboard;

- (void)showDefaultValues;

- (void)updateLoginButton;
@end

@protocol LoginViewDelegate <NSObject>
@optional
- (void)userDidSignIn;

- (void)forwardButtonInURLTextFieldDidPressed;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

@end
