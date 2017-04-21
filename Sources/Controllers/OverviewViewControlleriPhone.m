//
//  OverviewViewControlleriPhone.m
//  Shtirlits
//
//  Created by Artem Bartle on 1/9/13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "OverviewViewControlleriPhone.h"
#import "ZabbixClientAPI.h"
#import "LoggedUser.h"
#import "GroupsViewControlleriPhone.h"
#import "EGORefreshTableHeaderView.h"
#import "CommonConstants.h"
#import "UIButton+BarButton.h"
#import "UIColor+MoreColors.h"
#import "SVProgressHUD.h"
#import "RDScrollHeaderView.h"
#import "AKSegmentedControl.h"
#import "UIImage+Color.h"
#import "EventsDataSourceManager.h"
#import "TriggersDataSourceManager.h"
#import "DataDataSourceManager.h"

static CGFloat const kTopBarHeight = 48.0f;

typedef NS_ENUM(NSUInteger, OverviewViewDataManagerType) {
    OverviewViewDataManagerTypeTriggers = 0,
    OverviewViewDataManagerTypeData,
    OverviewViewDataManagerTypeEvents,
    OverviewViewDataManagerTypeCount
};


@interface OverviewViewControlleriPhone () <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    UITableView* _tableView;
    EGORefreshTableHeaderView* _refreshHeaderView;
    RDScrollHeaderView* _headerView;
    AKSegmentedControl* _segmentedControl;
    NSMutableDictionary* _managers;
    BOOL _needUpdate;
    id<OverviewDataSource> _currentManager;
}

- (void)tabSwitched:(id)sender;
- (void)refreshItems:(BOOL)isPullToRefresh;
- (void)selectManager:(OverviewViewDataManagerType)type;

@end


@implementation OverviewViewControlleriPhone

@synthesize selectedItemId = _selectedItemId;
@synthesize selectedItemName = _selectedItemName;
@synthesize currentType = _currentType;

- (void)setSelectedItemId:(NSString *)selectedItemId
{
    _selectedItemId = selectedItemId;
    _needUpdate = YES;
}

- (void)setSelectedItemName:(NSString *)selectedItemName
{
    _selectedItemName = selectedItemName;
    _needUpdate = YES;
}

- (void)setCurrentType:(ItemType)currentType
{
    _currentType = currentType;
    _needUpdate = YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        _managers = [[NSMutableDictionary alloc] init];
        _needUpdate = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.clipsToBounds = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.contentInset = UIEdgeInsetsMake(kTopBarHeight, 0, 0, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kTopBarHeight, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_tableView.bounds.size.height-1, _tableView.bounds.size.width, _tableView.bounds.size.height)];
    _refreshHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.defaultInset = kTopBarHeight;
    [_tableView addSubview:_refreshHeaderView];
    
    _headerView = [[RDScrollHeaderView alloc] initWithFrame:CGRectMake(0, -kTopBarHeight, _tableView.bounds.size.width, kTopBarHeight)] ;
    [_tableView addSubview:_headerView];
    
    [self setupSegmentedControl];
    
    UIButton* serversButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [serversButton setImage:[UIImage imageNamed:@"nb_servers_icon"] forState:UIControlStateNormal];
    [serversButton sizeToFit];
    [serversButton addTarget:self action:@selector(onGroups:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:serversButton];
}

- (void)setupSegmentedControl
{
    _segmentedControl = [[AKSegmentedControl alloc] initWithFrame:_headerView.bounds];
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_segmentedControl addTarget:self action:@selector(tabSwitched:) forControlEvents:UIControlEventValueChanged];
    [_headerView addSubview:_segmentedControl];
    [_segmentedControl setSelectedIndex:0];
    
    UIImage* separatorImage = [UIImage imageWithColor:[UIColor colorWithWhite:81.0f/255.0f alpha:1.0f]];
    [_segmentedControl setSeparatorImage:separatorImage];
    
    UIImage* backgroundImageNormal = [UIImage imageWithColor:[UIColor colorWithWhite:62.0f/255.0f alpha:1.0f]];
    UIImage* backgroundImageHilighted = [UIImage imageWithColor:[UIColor colorWithWhite:44.0f/255.0f alpha:1.0f]];
    [_segmentedControl setBackgroundImage:backgroundImageNormal];
    
    UIImage* eventsIconNormal = [UIImage imageNamed:@"overview_events_icon_normal"];
    UIImage* eventsIconHighlighted = [UIImage imageNamed:@"overview_events_icon_highlighted"];
    
    UIImage* dataIconNormal = [UIImage imageNamed:@"overview_data_icon_normal"];
    UIImage* dataIconHightlighted = [UIImage imageNamed:@"overview_data_icon_highlighted"];
    
    UIImage* triggersIconNormal = [UIImage imageNamed:@"overview_triggers_icon_normal"];
    UIImage* triggersIconHightlighted = [UIImage imageNamed:@"overview_triggers_icon_highlighted"];
    
    UIColor* titleColorNormal = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];
    UIColor* titleColorHighlighted = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0];
    UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    
    // Tab triggers
    UIButton* buttonTriggers = [[UIButton alloc] init];
    [buttonTriggers setTitle:NSLocalizedString(@"Triggers", nil) forState:UIControlStateNormal];
    [buttonTriggers.titleLabel setFont:font];
    [buttonTriggers setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [buttonTriggers setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    [buttonTriggers setBackgroundImage:backgroundImageHilighted forState:UIControlStateHighlighted];
    [buttonTriggers setBackgroundImage:backgroundImageHilighted forState:UIControlStateSelected];
    [buttonTriggers setTitleColor:titleColorNormal forState:UIControlStateNormal];
    [buttonTriggers setTitleColor:titleColorHighlighted forState:UIControlStateHighlighted];
    [buttonTriggers setTitleColor:titleColorHighlighted forState:UIControlStateSelected];
    [buttonTriggers setImage:triggersIconNormal forState:UIControlStateNormal];
    [buttonTriggers setImage:triggersIconHightlighted forState:UIControlStateHighlighted];
    [buttonTriggers setImage:triggersIconHightlighted forState:UIControlStateSelected];
    
    // Tab data
    UIButton* buttonData = [[UIButton alloc] init];
    [buttonData setTitle:NSLocalizedString(@"Data", nil) forState:UIControlStateNormal];
    [buttonData.titleLabel setFont:font];
    [buttonData setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [buttonData setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    [buttonData setBackgroundImage:backgroundImageHilighted forState:UIControlStateHighlighted];
    [buttonData setBackgroundImage:backgroundImageHilighted forState:UIControlStateSelected];
    [buttonData setTitleColor:titleColorNormal forState:UIControlStateNormal];
    [buttonData setTitleColor:titleColorHighlighted forState:UIControlStateHighlighted];
    [buttonData setTitleColor:titleColorHighlighted forState:UIControlStateSelected];
    [buttonData setImage:dataIconNormal forState:UIControlStateNormal];
    [buttonData setImage:dataIconHightlighted forState:UIControlStateHighlighted];
    [buttonData setImage:dataIconHightlighted forState:UIControlStateSelected];
    
    // Tab events
    UIButton* buttonEvents = [[UIButton alloc] init];
    [buttonEvents setTitle:NSLocalizedString(@"Events", nil) forState:UIControlStateNormal];
    [buttonEvents.titleLabel setFont:font];
    [buttonEvents setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [buttonEvents setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    [buttonEvents setBackgroundImage:backgroundImageHilighted forState:UIControlStateHighlighted];
    [buttonEvents setBackgroundImage:backgroundImageHilighted forState:UIControlStateSelected];
    [buttonEvents setTitleColor:titleColorNormal forState:UIControlStateNormal];
    [buttonEvents setTitleColor:titleColorHighlighted forState:UIControlStateHighlighted];
    [buttonEvents setTitleColor:titleColorHighlighted forState:UIControlStateSelected];
    [buttonEvents setImage:eventsIconNormal forState:UIControlStateNormal];
    [buttonEvents setImage:eventsIconHighlighted forState:UIControlStateHighlighted];
    [buttonEvents setImage:eventsIconHighlighted forState:UIControlStateSelected];
    
    [_segmentedControl setButtonsArray:@[buttonTriggers, buttonData, buttonEvents]];
}

// should be viewWillAppear but not invoke in first appear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    switch (self.currentType) {
        case ItemAll:
            self.title = NSLocalizedString(@"All servers", nil);
            break;
        case ItemGroup:
        case ItemHost:
            self.title = self.selectedItemName;
            break;
    }
    
    [Flurry logEvent:@"Show OverView"];
    if (_currentManager == nil) {
        [_segmentedControl setSelectedIndex:OverviewViewDataManagerTypeTriggers];
        [self selectManager:OverviewViewDataManagerTypeTriggers];
    } else if (_needUpdate) {
        for (id<OverviewDataSource> manager in _managers.allValues) {
            [manager clearData];
        }
        [_tableView reloadData];
        [self refreshItems:NO];
    }
    _needUpdate = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_managers removeAllObjects];
    _currentManager = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_currentManager updateLayout];
}

#pragma mark - Actions
- (void)selectManager:(OverviewViewDataManagerType)type
{
    NSAssert(type >= 0 && type < OverviewViewDataManagerTypeCount, @"Ivalid manager type");
    _currentManager = [_managers objectForKey:@(type)];
    if (_currentManager == nil) {
        switch([[_segmentedControl selectedIndexes] firstIndex]) {
            case OverviewViewDataManagerTypeEvents: {
                _currentManager = [[EventsDataSourceManager alloc] initWithOwnerController:self tableView:_tableView];
            } break;
            case OverviewViewDataManagerTypeData: {
                _currentManager = [[DataDataSourceManager alloc] initWithOwnerController:self];
            } break;
            case OverviewViewDataManagerTypeTriggers: {
                _currentManager = [[TriggersDataSourceManager alloc] initWithOwnerController:self];
            } break;
        }
        [_managers setObject:_currentManager forKey:@(type)];
    }
    
    // if manager is empty, then reload data
    if (_currentManager.isEmpty) {
        [self refreshItems:NO];
    }
    [_tableView reloadData];
}

- (void)tabSwitched:(id)sender
{
    [self selectManager:(OverviewViewDataManagerType)[[_segmentedControl selectedIndexes] firstIndex]];
}

- (void)refreshItems:(BOOL)isPullToRefresh
{
    if (_currentManager == nil) {
        return;
    }
    
    if (!isPullToRefresh) {
        [SVProgressHUD show];
    }
    
    [_currentManager refreshItems:isPullToRefresh type:self.currentType itemId:self.selectedItemId success:^{
        [_tableView reloadData];
        [_refreshHeaderView refreshLastUpdatedDate];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSError *error) {
        if (error != nil) {
            [CommonActions showErrorMessage:[error localizedDescription] withTitle:nil];
        }
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)onGroups:(id)sender
{
    GroupsViewControlleriPhone* hostGroupVC = [GroupsViewControlleriPhone new];
    hostGroupVC.owner = self;
    [self.navigationController pushViewController:hostGroupVC animated:YES];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self refreshItems:YES];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return [_currentManager isReloading];
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [_headerView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_currentManager numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentManager tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_currentManager tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_currentManager tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_currentManager tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_currentManager tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [_currentManager tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

@end
