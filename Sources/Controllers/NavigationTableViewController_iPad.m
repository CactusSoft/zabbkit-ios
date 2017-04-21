
//
//  NavigationTableViewController_iPad.m
//  Zabbkit
//
//  Created by Anna on 09.10.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NavigationTableViewController_iPad.h"
#import "LoggedUser.h"
#import "OverviewViewControlleriPhone.h"
#import "NotificationsViewController.h"
#import "AboutViewControlleriPhone.h"
#import "LoginView.h"
#import "AppDelegate.h"
#import "FavoritesViewController.h"

@interface NavigationTableViewController_iPad ()<UITableViewDelegate, UIActionSheetDelegate, LoggedUserDelegate>
{
    ZabbKitPaneType _paneType;
    UIActionSheet* _logoutActionSheet;
    UITableView*   _tableView;
}

@property (nonatomic, retain) UIBarButtonItem *navigationPaneButtonItem;
@property (nonatomic, retain) UIPopoverController *navigationPopoverController;

@end

@implementation NavigationTableViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _paneType = ZabbKitPaneTypeOverview;
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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_paneType inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
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

#pragma mark - Actions

- (void)transitionToViewController:(ZabbKitPaneType)paneType
{
    _paneType = paneType;

    UIViewController *viewController = nil;

    switch (paneType) {
        case ZabbKitPaneTypeOverview:
            viewController = [OverviewViewControlleriPhone new];
            break;
        case ZabbKitPaneTypeNotifications:
            viewController = [NotificationsViewController new];
            break;
        case ZabbKitPaneTypeAbout:
            viewController = [AboutViewControlleriPhone new];
            break;
        case ZabbKitPaneTypeFavorites:
            viewController = [FavoritesViewController new];
            break;
        default:
            break;
    }
    
    NavigationDetailsViewController_iPad *navController = [[NavigationDetailsViewController_iPad alloc] initWithRootViewController:viewController];
    [self setDetailViewController:navController];
}

- (void)setDetailViewController:(NavigationDetailsViewController_iPad  *)detailViewController
{
    self.detailViewController.navigationPaneBarButtonItem = nil;
    _detailViewController = detailViewController;
    
    _detailViewController.navigationPaneBarButtonItem = self.navigationPaneButtonItem;

    self.splitViewController.viewControllers = @[self,_detailViewController];
    
    if (self.navigationPopoverController)
    {
        [self.navigationPopoverController dismissPopoverAnimated:YES];
    }
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

#pragma mark - UIActionSheetDelegate

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
    ((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController = self.owner;
}

- (void)didFailLogoutWithError:(NSError *)error
{
}

#pragma mark -
#pragma mark UISplitViewDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{

    barButtonItem.image = [UIImage imageNamed:@"nb_menu_icon.png"];
    self.navigationPaneButtonItem = barButtonItem;
    self.navigationPopoverController = pc;
     self.detailViewController.navigationPaneBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationPaneButtonItem = nil;
    self.navigationPopoverController = nil;
    self.detailViewController.navigationPaneBarButtonItem = nil;
}



@end
