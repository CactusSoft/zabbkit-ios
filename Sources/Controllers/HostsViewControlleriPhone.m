//
//  HostsViewControlleriPhone.m
//  Shtirlits
//
//  Created by Artem Bartle on 1/10/13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "HostsViewControlleriPhone.h"
#import "ZabbixClientAPI.h"
#import "LoggedUser.h"
#import "ZabbixHostGroup.h"
#import "ZabbixHost.h"
#import "SVProgressHUD.h"
#import "OverviewViewControlleriPhone.h"
#import "ServerTableViewCell.h"
#import "UIButton+BarButton.h"
#import "UIView+Separator.h"
#import "MSNavigationPaneViewController.h"


@interface HostsViewControlleriPhone () <UITableViewDataSource, UITableViewDelegate> {
    UITableView* _tableView;
}

@end


@implementation HostsViewControlleriPhone

@synthesize group = group_;
@synthesize hosts = hosts_;

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

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.group.groupName;
    
    [SVProgressHUD show];
    [[[LoggedUser sharedUser] clientAPI] loadHostsWithGroupId:self.group.groupId success:^(NSArray *items) {
        self.hosts = items;
        [_tableView reloadData];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    } failureBlock:^(NSError *error) {
        if (error != nil) {
            [CommonActions showErrorMessage:[error localizedDescription] withTitle:nil];
            DLog(@"Failed");
        }
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }];
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nb_back_button"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self canDragPainView:NO];
}

- (void)canDragPainView:(BOOL)isDrag
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        MSNavigationPaneViewController *paneViewController = (MSNavigationPaneViewController *) self.navigationController.parentViewController;
        paneViewController.paneDraggingEnabled = isDrag;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self canDragPainView:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hosts count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"HostCell";
    ServerTableViewCell* cell = (ServerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ServerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"All", nil);
    } else {
        ZabbixHost* host = [self.hosts objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = host.hostName;
    }
    cell.accessoryView.hidden = YES;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        self.owner.currentType = ItemGroup;
        self.owner.selectedItemId = self.group.groupId;
        self.owner.selectedItemName = self.group.groupName;
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        ZabbixHost *host = [self.hosts objectAtIndex:indexPath.row - 1];
        self.owner.currentType = ItemHost;
        self.owner.selectedItemId = host.hostId;
        self.owner.selectedItemName = host.hostName;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark Actions
- (void)backButtonDidPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
