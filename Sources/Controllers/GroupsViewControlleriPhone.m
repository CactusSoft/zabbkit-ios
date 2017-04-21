//
//  HostGroupViewController.m
//  Shtirlits
//
//  Created by Artem Bartle on 12/12/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "GroupsViewControlleriPhone.h"
#import "ZabbixClientAPI.h"
#import "LoggedUser.h"
#import "ZabbixHostGroup.h"
#import "HostsViewControlleriPhone.h"
#import "SVProgressHUD.h"
#import "OverviewViewControlleriPhone.h"
#import "ServerTableViewCell.h"
#import "UIButton+BarButton.h"
#import "UIView+Separator.h"
#import "MSNavigationPaneViewController.h"

@interface GroupsViewControlleriPhone () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView_;
}
@property(nonatomic, strong) UITableView *tableView;

@end


@implementation GroupsViewControlleriPhone
@synthesize tableView = tableView_;
@synthesize hostGroups = hostGroups_;

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
    
    self.title = NSLocalizedString(@"Server List", nil);
    
    tableView_ = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
    tableView_.dataSource = self;
    tableView_.delegate = self;
    [self.view addSubview:tableView_];
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nb_back_button"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [[[LoggedUser sharedUser] clientAPI] loadGroupesOfHostsSuccess:^(NSArray *items) {
        self.hostGroups = items;
        [self.tableView reloadData];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    } failureBlock:^(NSError *error) {
        if (error != nil) {
            DLog(@"Failed");
            [CommonActions showErrorMessage:[error localizedDescription] withTitle:nil];
        }
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }];
    [self canDragPainView:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self canDragPainView:YES];
}

- (void)canDragPainView:(BOOL)isDrag
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [(MSNavigationPaneViewController*)[self.navigationController parentViewController] setPaneDraggingEnabled:isDrag];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hostGroups count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"HostGroupCell";
    ServerTableViewCell* cell = (ServerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ServerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"All servers", nil);
        cell.accessoryView.hidden = YES;
    } else {
        ZabbixHostGroup* group = [self.hostGroups objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = group.groupName;
        cell.accessoryView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        self.owner.currentType = ItemAll;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        ZabbixHostGroup* group = [self.hostGroups objectAtIndex:indexPath.row - 1];
        HostsViewControlleriPhone* hostsVC = [HostsViewControlleriPhone new];
        hostsVC.group = group;
        hostsVC.owner = self.owner;
        [self.navigationController pushViewController:hostsVC animated:YES];
    }
}

#pragma mark Actions
- (void)backButtonDidPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
