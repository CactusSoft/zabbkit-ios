//
//  NavigationTableController.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 10.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NavigationTableController_iPhone.h"
#import "MSNavigationPaneViewController.h"
#import "RootViewController_iPhone.h"
#import "ZabbixServer.h"
#import "LoggedUser.h"
#import "LoginView.h"
#import "NavigationTableViewCell.h"
#import "AppDelegate.h"
#import "UIView+Separator.h"
#import "TableHeaderViewCell.h"
#import "OldSchoolNavigationController.h"
#import "OverviewViewControlleriPhone.h"
#import "AboutViewControlleriPhone.h"
#import "NotificationsViewController.h"
#import "FavoritesViewController.h"
#import "ServerListViewController_iPhone.h"


@interface NavigationTableController_iPhone () <UITableViewDelegate, UIActionSheetDelegate, LoggedUserDelegate, MSNavigationPaneViewControllerDelegate> {
    UIActionSheet* _logoutActionSheet;
    UITableView*   _tableView;
    NSDictionary*  _paneViewControllerClasses;
    ZabbKitPaneType _paneType;
}

@end

@implementation NavigationTableController_iPhone

- (id)init {
    self = [super init];
    if (self) {
        _paneType = ZabbKitPaneTypeNone;
        _paneViewControllerClasses = @{
                                       @(ZabbKitPaneTypeOverview) : OverviewViewControlleriPhone.class,
                                       @(ZabbKitPaneTypeFavorites) : FavoritesViewController.class,
                                       @(ZabbKitPaneTypeAbout) : AboutViewControlleriPhone.class,
                                       @(ZabbKitPaneTypeNotifications) : NotificationsViewController.class,
                                       @(ZabbKitPaneTypeServerList) : ServerListViewController_iPhone.class
                                    };
        _dataSource = [NavigationTableDataSource new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0f];
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = _dataSource;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    self.navigationPaneViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    
    ZabbKitPaneType type = _paneType;
    if (type == ZabbKitPaneTypeNone) {
        type = ZabbKitPaneTypeOverview;
        [self transitionToViewController:type];
    }
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:type inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - MSMasterViewController

- (void)transitionToViewController:(ZabbKitPaneType)paneType
{
    if (paneType == _paneType) {
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
        return;
    }
    _paneType = paneType;
    
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    
    Class paneViewControllerClass = _paneViewControllerClasses[@(paneType)];
    NSParameterAssert([paneViewControllerClass isSubclassOfClass:UIViewController.class]);
    UIViewController* paneViewController = (UIViewController *)[[paneViewControllerClass alloc] init];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"nb_menu_icon"] forState:UIControlStateNormal];
    [menuButton sizeToFit];
    [menuButton addTarget:self action:@selector(navigationPaneBarButtonItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    paneViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    UINavigationController* paneNavigationViewController = [[OldSchoolNavigationController alloc] initWithRootViewController:paneViewController];
    [self.navigationPaneViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    //switch to ovreview VC when user select a server
    if ([paneViewController isKindOfClass:[ServerListViewController_iPhone class]]) {
        ServerListViewController_iPhone *serverListVC =  (ServerListViewController_iPhone *)paneViewController;
        serverListVC.completion = ^{
            [self transitionToViewController:ZabbKitPaneTypeOverview];
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:ZabbKitPaneTypeOverview inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        };
    }
}

- (void)navigationPaneBarButtonItemTapped:(id)sender {
    [self.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > ZabbKitPaneTypeTopCell && indexPath.row < ZabbKitPaneTypeLogout) {
        [self transitionToViewController:[self.dataSource paneViewControllerTypeForIndexPath:indexPath]];
    } else if (indexPath.row == ZabbKitPaneTypeLogout) {
        [self showlogoutActionSheet];
    }
}

#pragma mark - MSNavigationPaneViewControllerDelegate
- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    _tableView.scrollsToTop = (state == MSNavigationPaneStateOpen);
}

- (void)showlogoutActionSheet
{
    if (!_logoutActionSheet) {
        _logoutActionSheet = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                              destructiveButtonTitle:nil
                              otherButtonTitles:NSLocalizedString(@"Logout", @""), nil];
    }
    _logoutActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [_logoutActionSheet showInView:self.view];
}

#pragma mark - Actionsheet Delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _logoutActionSheet && buttonIndex != _logoutActionSheet.cancelButtonIndex) {
        [LoggedUser sharedUser].password = nil;
        [LoggedUser sharedUser].delegate = self;
        [[LoggedUser sharedUser] logout];
    }
}

#pragma mark - LoggedUserDelegate
- (void)didSuccessfullyLogout
{
    self.owner.loginView.passwordTextField.text = nil;
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFailLogoutWithError:(NSError *)error
{
}

@end
