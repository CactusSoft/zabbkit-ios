//
//  RootViewControllerIPhone.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "RootViewController_iPhone.h"
#import "LoggedUser.h"
#import "LoginView.h"
#import "MSNavigationPaneViewController.h"
#import "ServerListViewController_iPhone.h"
#import "NavigationTableController_iPhone.h"
#import "AppDelegate.h"
#import "ZabbixServer.h"
#import "OldSchoolNavigationController.h"
#import "NavigationDetailsViewController_iPad.h"
#import "NavigationTableViewController_iPad.h"
#import "OverviewViewControlleriPhone.h"

static const CGRect kFrameLoginViewBackground = {{6.0, 49.0}, {308.0, 128.0}};
static const CGRect kFrameLoginView = {{6.0, 49.0}, {308.0, 300.0}};

static const NSTimeInterval kTransitionDuration = 0.4f;
static const NSTimeInterval kAnimateLogImageDuration = 0.75f;
static const NSTimeInterval kAnimateAlphaDuration = 0.75f;

@interface RootViewController_iPhone () <LoggedUserDelegate, LoginViewDelegate, UIScrollViewDelegate> {
    UIButton *backgroundButton_;
    UIScrollView *scrollView_;
    UIImageView *logoImageView_;
    UIImageView *backgroundLoginView_;
    BOOL isFirstLoad;
    float yShift;
}

@end


@implementation RootViewController_iPhone

@synthesize loginView = loginView_;

#pragma mark view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstLoad = YES;
    
    UIImage *backgroundLoginImage = [UIImage imageNamed:kImgLoginView];
    backgroundLoginImage = [backgroundLoginImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    backgroundLoginView_ = [[UIImageView alloc] initWithImage:backgroundLoginImage];
    backgroundLoginView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    logoImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kImgLogoBig]];
    logoImageView_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    logoImageView_.contentMode = UIViewContentModeCenter;
    CGRect frame = backgroundLoginView_.frame;
    frame.origin = kFrameLoginViewBackground.origin;
    frame.origin.y += g_yUIShift;

    backgroundLoginView_.frame = frame;
    [self.view addSubview:backgroundLoginView_];
    
    [self addScrollView];
    [self addBackgroundButton];
    [self addNotifications];
    
    frame = kFrameLoginView;
    frame.origin.y += g_yUIShift;
    loginView_ = [[LoginView alloc] initWithFrame:frame];
    [scrollView_ addSubview:loginView_];
    [self.view addSubview:logoImageView_];
    self.loginView.delegate = self;
    [loginView_ showDefaultValues];
    [self moveAllElementsInDefaultState];
}

- (void)moveAllElementsInDefaultState
{
    logoImageView_.center = self.view.center;
    backgroundLoginView_.center = CGPointMake(self.view.center.x, backgroundLoginView_.center.y);
    loginView_.center = CGPointMake(self.view.center.x, loginView_.center.y);
    backgroundLoginView_.alpha = 0.0;
    loginView_.alpha = 0.0;
    logoImageView_.alpha = 0.0;
}

- (void)showElementsAnimated
{
    isFirstLoad = NO;
    [UIView animateWithDuration:kAnimateLogImageDuration animations:^{
        logoImageView_.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            CGRect frame = logoImageView_.frame;
            frame.origin.y = 15 + g_yUIShift;
            logoImageView_.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.75 animations:^{
                backgroundLoginView_.alpha = 1.0;
                loginView_.alpha = 1.0;
            } completion:^(BOOL finished) {
                [self presentPaneViewController];
            }];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.loginView updateLoginButton];
    if (isFirstLoad) {
        [self showElementsAnimated];
    }
}

- (void)dealloc
{
    loginView_.delegate = nil;
    scrollView_.delegate = nil;
}

# pragma mark - Creating controls
- (void)addScrollView
{
    scrollView_ = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView_ setAutoresizesSubviews:YES];
    [scrollView_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [scrollView_ setDelegate:self];
    [scrollView_ setScrollEnabled:NO];
    [scrollView_ setContentSize:self.view.bounds.size];
    [self.view addSubview:scrollView_];
}

- (void)addBackgroundButton
{
    backgroundButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [backgroundButton_ addTarget:self action:@selector(backgroundButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    backgroundButton_.frame = self.view.bounds;
    [backgroundButton_ setUserInteractionEnabled:YES];
    [scrollView_ addSubview:backgroundButton_];
}

#pragma mark Actions
- (void)onServerList
{
    [self presentServerList];
}

- (void)logoutPressed:(id)sender
{
    [LoggedUser sharedUser].delegate = self;
    [[LoggedUser sharedUser] logout];
}

- (void)backgroundButtonTouch:(id)sender
{
    [loginView_ hideKeyboard];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userSignIn:)
                                                 name:kUserSignInNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidFailLogin:)
                                                 name:kUserDidFailLoginNotification
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)presentServerList
{
    [loginView_ hideKeyboard];

    ServerListViewController_iPhone* serverListVC = [[ServerListViewController_iPhone alloc] init];
    serverListVC.owner = self;
    [self.navigationController pushViewController:serverListVC animated:YES];
}

- (void)presentPaneViewController
{
    if (![LoggedUser sharedUser].userIsLoginIn) {
        return;
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (self.presentedViewController == nil) {
            [loginView_ hideKeyboard];
            
            NavigationTableController_iPhone* master = [[NavigationTableController_iPhone alloc] init];
            master.owner = self;
            MSNavigationPaneViewController *paneViewController = [[MSNavigationPaneViewController alloc] init];
            paneViewController.masterViewController = master;
            paneViewController.appearanceType = MSNavigationPaneAppearanceTypeFade;
            master.navigationPaneViewController = paneViewController;
            [self presentViewController:paneViewController animated:YES completion:nil];
        }
    } else {
        OverviewViewControlleriPhone *over = [[OverviewViewControlleriPhone alloc] init];
        NavigationDetailsViewController_iPad *overNavCon = [[NavigationDetailsViewController_iPad alloc] initWithRootViewController:over];
        
        NavigationTableViewController_iPad *table = [[NavigationTableViewController_iPad alloc] init];
        table.detailViewController = overNavCon;
        table.owner = self;
        
        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        splitViewController.viewControllers = @[table,overNavCon];
        splitViewController.delegate = table;
        
        table.splitViewController = splitViewController;
        ((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController = splitViewController;
    }
}

- (void)dismissPaneViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Delegate LoginView
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)userSignIn:(NSNotification *)notification
{
    [LoggedUser sharedUser].delegate = self;
    if (isFirstLoad) {
        [self showElementsAnimated];
    } else {
        [self presentPaneViewController];
    }
}

- (void)userDidFailLogin:(NSNotification *)notification
{
    if (isFirstLoad) {
        [self showElementsAnimated];
    }
}

#pragma mark - LoginViewDelegate
- (void)forwardButtonInURLTextFieldDidPressed
{
    [self onServerList];
}

#pragma mark - LoggedUserDelegate
- (void)didSuccessfullyLogout
{
    DLog(@"didSuccessfullyLogout");
}

- (void)didFailLogoutWithError:(NSError *)error
{
    DLog(@"didFailLoginWithError");
}

@end
