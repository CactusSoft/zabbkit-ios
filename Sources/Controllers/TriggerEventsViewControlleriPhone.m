//
//  TriggerEventsViewControlleriPhone.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 12.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "TriggerEventsViewControlleriPhone.h"
#import "ZabbixEvent.h"
#import "LoggedUser.h"
#import "ZabbixClientAPI.h"
#import "TriggerEventCell.h"
#import "ZabbixTrigger.h"
#import "NSString+AdditionsMethods.h"
#import "UIColor+MoreColors.h"
#import "EGORefreshTableHeaderView.h"
#import "UIButton+BarButton.h"
#import "SVProgressHUD.h"
#import "MSNavigationPaneViewController.h"
#import "UILabel+SH_UILabel.h"
#import "PullableView.h"

static CGFloat const kTopViewHeight = 84.0f;
static CGFloat const kLeftOffset = 16.0;
static CGFloat const kRightOffset = 16.0;
static CGFloat const kInfoOffset = 26.0f;
static CGFloat const kTopOffset = 10.0;

@interface TriggerEventsViewControlleriPhone () <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableView* _tableView;
    EGORefreshTableHeaderView* _refreshHeaderView;
    NSArray* _eventsArray;
    BOOL _reloading;
    PullableView *_pullableView;
    UIImageView *_actionImageView;
    UIView *_contentView;
}

- (void)refreshItems:(BOOL)isPullToRefresh;

@end


@implementation TriggerEventsViewControlleriPhone

@synthesize trigger = _trigger;

- (void)setTrigger:(ZabbixTrigger *)trigger
{
    _trigger = trigger;
    [_tableView reloadData];
}

- (NSArray *)sortedItems:(NSArray *)items
{
    if (items.count == 0) {
        return nil;
    }
    for (int i = [items count] - 1; i > 0; i--) {
        ZabbixEvent *event = [items objectAtIndex:i];
        ZabbixEvent *nextEvent = [items objectAtIndex:i - 1];
        event.duration = nextEvent.clock - event.clock;
    }
    ZabbixEvent *lastEvent = [items objectAtIndex:0];
    NSDate *lastEventDate = [NSDate dateWithTimeIntervalSince1970:lastEvent.clock];
    lastEvent.duration = fabs([lastEventDate timeIntervalSinceNow]);
    return items;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _eventsArray = [NSArray array];
    }
    return self;
}

- (void)dealloc
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Trigger history", nil);
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nb_back_button"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + kInfoOffset, self.view.bounds.size.width, self.view.bounds.size.height - kInfoOffset)];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -_tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
    _refreshHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];
    
    _pullableView = [[PullableView alloc] initWithFrame:CGRectZero];
    _pullableView.backgroundColor = [UIColor clearColor];
    _pullableView.animate = YES;
    [self.view addSubview:_pullableView];
    
    [self refreshItems:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Flurry logEvent:@"Show Trigger Events"];
    [self canDragPainView:NO];
    [self resizePullabelView];
    _pullableView.closedCenter = CGPointMake(_pullableView.frame.size.width/2, - _pullableView.frame.size.height/2 + kInfoOffset) ;
    _pullableView.openedCenter = CGPointMake(_pullableView.frame.size.width/2, _pullableView.frame.size.height/2);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self canDragPainView:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_pullableView setOpened:NO animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resizePullabelView];

    _pullableView.closedCenter = CGPointMake(_pullableView.frame.size.width/2, - _pullableView.frame.size.height/2 + kInfoOffset) ;
    _pullableView.openedCenter = CGPointMake(_pullableView.frame.size.width/2, _pullableView.frame.size.height/2);
}

#pragma mark - Resize Views

- (void)resizePullabelView
{
    [self createContentView];
    _pullableView.frame = CGRectMake(0, -_contentView.frame.size.height, _contentView.frame.size.width, _contentView.frame.size.height + kInfoOffset);
    _pullableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    [_pullableView addSubview:_actionImageView];
    [_pullableView addSubview:_contentView];
}

- (void)createContentView
{
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    _contentView.backgroundColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0f];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _contentView.clipsToBounds = YES;
    
    UILabel* eventSeverityLabel = [UILabel sh_labelWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16] textColor:[UIColor whiteColor]];
    eventSeverityLabel.frame = CGRectMake(kLeftOffset, kTopOffset, _contentView.bounds.size.width - kLeftOffset - kRightOffset, 20.0f);
    eventSeverityLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin
    ;
    eventSeverityLabel.numberOfLines = 1;
    eventSeverityLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    eventSeverityLabel.text = [ZabbixTrigger triggerPriorityString:_trigger.priority];
    [_contentView addSubview:eventSeverityLabel];
    
    UIImageView *descriptionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bell.png"]];
    descriptionImageView.center = CGPointMake(kLeftOffset + descriptionImageView.image.size.width/2, CGRectGetMaxY(eventSeverityLabel.frame) + kTopOffset + descriptionImageView.image.size.height/2);
    [_contentView addSubview:descriptionImageView];
    
    UILabel* triggerDescriptionLabel = [UILabel sh_labelWithFont:[UIFont fontWithName:@"Helvetica" size:14] textColor:[UIColor whiteColor]];
    triggerDescriptionLabel.frame = CGRectMake(CGRectGetMaxX(descriptionImageView.frame) + kLeftOffset/2, CGRectGetMaxY(eventSeverityLabel.frame) + kTopOffset, _contentView.bounds.size.width - kLeftOffset - kRightOffset - CGRectGetMaxX(descriptionImageView.frame), 25);
    triggerDescriptionLabel.numberOfLines = 0;
    triggerDescriptionLabel.text = _trigger.triggerDescription;
    [triggerDescriptionLabel sizeToFit];
    triggerDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [_contentView addSubview:triggerDescriptionLabel];
    
    UIView* lastView = triggerDescriptionLabel;
    
    if (_trigger.url.length > 0) {
        UIImageView *urlImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_earth.png"]];
        urlImageView.center = CGPointMake(kLeftOffset + urlImageView.image.size.width/2, CGRectGetMaxY(triggerDescriptionLabel.frame) + kTopOffset + urlImageView.image.size.height/2);
        [_contentView addSubview:urlImageView];
        
        UITextView *urlTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        urlTextView.backgroundColor = [UIColor clearColor];
        urlTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
        urlTextView.textColor = [UIColor whiteColor];
        urlTextView.text = _trigger.url;
        urlTextView.editable = NO;
        urlTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        urlTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        urlTextView.scrollEnabled = NO;
        CGSize size = [urlTextView sizeThatFits:CGSizeMake(_contentView.bounds.size.width - kLeftOffset - kRightOffset - CGRectGetMaxX(urlImageView.frame), CGFLOAT_MAX)];
        urlTextView.frame = CGRectMake(CGRectGetMaxX(urlImageView.frame) + kLeftOffset/2 - 6, CGRectGetMaxY(triggerDescriptionLabel.frame) + kTopOffset - 6, size.width, size.height );
        [_contentView addSubview:urlTextView];
        
        lastView = urlTextView;
    }
    
    if (_trigger.comments.length > 0) {
        UIImageView *commentsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_message.png"]];
        commentsImageView.center = CGPointMake(kLeftOffset + commentsImageView.image.size.width/2, CGRectGetMaxY(lastView.frame) + kTopOffset + commentsImageView.image.size.height/2);
        [_contentView addSubview:commentsImageView];
        
        UILabel *commentsLabel = [UILabel sh_labelWithFont:[UIFont fontWithName:@"Helvetica" size:14] textColor:[UIColor whiteColor]];
        commentsLabel.frame = CGRectMake(CGRectGetMaxX(commentsImageView.frame) + kLeftOffset/2, CGRectGetMaxY(lastView.frame) + kTopOffset, _contentView.bounds.size.width - kLeftOffset - kRightOffset - CGRectGetMaxX(commentsImageView.frame), 25);
        commentsLabel.numberOfLines = 0;
        commentsLabel.text = _trigger.comments;
        commentsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [commentsLabel sizeToFit];
        [_contentView addSubview:commentsLabel];
        
        lastView = commentsLabel;
    }
    
    _contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMaxY(lastView.frame) + kTopOffset);
    
    if (_actionImageView) {
        [_actionImageView removeFromSuperview];
        _actionImageView = nil;
    }
    
    _actionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_open.png"]];
    _actionImageView.contentMode = UIViewContentModeCenter;
    _actionImageView.frame = CGRectMake(_contentView.frame.size.width/2 -  23, CGRectGetMaxY(_contentView.frame), 46, kInfoOffset);
    _actionImageView.backgroundColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0f];
    _actionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

#pragma mark - Actions

- (void)canDragPainView:(BOOL)isDrag
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        MSNavigationPaneViewController *paneViewController = (MSNavigationPaneViewController *) self.navigationController.parentViewController;
        paneViewController.paneDraggingEnabled = isDrag;
    }
}

- (void)backButtonDidPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshItems:(BOOL)isPullToRefresh
{
    _reloading = YES;
    if (!isPullToRefresh) {
        [SVProgressHUD show];
    }
    [[LoggedUser sharedUser].clientAPI loadTriggerEventsWithTriggerId:_trigger.triggerid success:^(NSArray *items) {
        _eventsArray = [self sortedItems:items];
        [_tableView reloadData];
        [_refreshHeaderView refreshLastUpdatedDate];
        _reloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    } failureBlock:^(NSError *error) {
        if (error != nil) {
            [CommonActions showErrorMessage:[error localizedDescription] withTitle:nil];
            DLog(@"%@", [error description]);
        }
        _reloading = NO;
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self refreshItems:YES];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"TriggerEventsCell";
    TriggerEventCell* cell = (TriggerEventCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TriggerEventCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    if ([_eventsArray count] > 0) {
        ZabbixEvent* event = [_eventsArray objectAtIndex:indexPath.row];
        [cell updateWithTrigger:_trigger event:event];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

@end
