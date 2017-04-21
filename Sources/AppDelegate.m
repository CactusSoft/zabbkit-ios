//
//  AppDelegate.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "AppDelegate.h"
#import "LoggedUser.h"
#import "RootViewController_iPhone.h"
#import "OldSchoolNavigationController.h"

float g_yUIShift = 0.0f;

static NSString *const kRunTimesCounterKey = @"RunTimesCounter";
static NSString *const kDontRateKey = @"DontRateKey";
static const NSUInteger kRunTimes = 10;
static NSString *const kAppStoreLink = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=605403265";

@implementation AppDelegate

@synthesize window;

+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifndef DEBUG
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"K24ZFXBBYKXPX7VZHC4Y"];
    [Flurry logEvent:@"Application Started"];
#endif
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        g_yUIShift = 20.0f;
    }
    
    [self customizeAppearance];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShtirlitsApplicationIsNotFirstRun"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShtirlitsApplicationIsNotFirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self clearKeychein];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    RootViewController_iPhone *rootVC = [[RootViewController_iPhone alloc] init];
    OldSchoolNavigationController *nc = [[OldSchoolNavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)clearKeychein
{
    [Keychain deleteStringForKey:kProtectedPasswordKeyString];
    [Keychain deleteStringForKey:kProtectedLoginKeyString];
}

- (void)addSubview:(UIView *)view
{
    [self.window.rootViewController.view addSubview:view];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kDontRateKey]) {
        NSInteger count = [userDefaults integerForKey:kRunTimesCounterKey];
        if (count == kRunTimes) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"Rate Message", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Remind me later", nil)
                                                      otherButtonTitles:NSLocalizedString(@"No Thanks", nil),
                                                                        NSLocalizedString(@"Rate The App", nil), nil];
            [alertView show];
        }
        else {
            [userDefaults setInteger:++count forKey:kRunTimesCounterKey];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kRunTimesCounterKey];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDontRateKey];
            break;
        case 2: {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDontRateKey];
            NSURL *appStoreURL = [NSURL URLWithString:kAppStoreLink];
            [[UIApplication sharedApplication] openURL:appStoreURL];
        } break;
    }
}

#pragma mark Appearance
- (void)customizeAppearance
{
     if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
         [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
     } else {
         [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:44.0/255.0f alpha:1.0]];
     }
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nb_background"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nb_background"] forBarMetrics:UIBarMetricsLandscapePhone];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"nb_background"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

@end
