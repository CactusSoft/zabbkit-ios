//
//  GraphViewController.m
//  Shtirlits
//
//  Created by Artem Bartle on 12/14/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "GraphViewControlleriPhone.h"
#import "ZabbixGraph.h"
#import "LoggedUser.h"
#import "ZabbixClientAPI.h"
#import "AFHTTPRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "ZabbixRequestHelper.h"
#import "SVProgressHUD.h"
#import "MSNavigationPaneViewController.h"
#import "UIScrollView+ZoomToPoint.h"
#import "UIButton+BarButton.h"
#import "NSString+AdditionsMethods.h"
#import "UIColor+MoreColors.h"
#import "UIImage+Color.h"
#import <MessageUI/MessageUI.h>
#import "ZabbixGraph.h"

static const NSTimeInterval kToggleFullscreenTimeout = 2.0f;
static float const kToolBarHeight = 44.0;
static float const kStatusBarHeight = 20.0;
static float const kBarTransparency = 0.9;

typedef enum {
    ShareByEmail = 0,
    ShareBySave,
    ShareByFavorite,
    ShareTypeCount
} ShareType;

@interface GraphViewControlleriPhone () <UIScrollViewDelegate, MFMailComposeViewControllerDelegate> {
    CGSize _imageSize;
    NSTimer *_fullscreenTimer;
    NSDate *_currentDate;
    UIBarButtonItem *_shareButtonItem;
    UIActionSheet *_actionSheet;
}

@property(strong, nonatomic) UILabel *durationLabel;
@property(strong, nonatomic) UILabel *topLabel;
@property(strong, nonatomic) UILabel *bottomLabel;
@property(strong, nonatomic) UIImageView *graphImageView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIToolbar *bottomToolbar;
@property(strong, nonatomic) UIView *topView;
@property(assign, nonatomic) BOOL fullscreenMode;

- (void)startFullscreenTimer;
- (void)resetFullscrenTimer;

- (void)addViewElements;
- (void)setImageSize;

- (void)loadGraph:(NSDate *)endDate range:(NSTimeInterval)timeInterval;

- (void)sendByEmail;
- (void)saveInGallery;

- (void)addGraphToFavorite;
- (void)removeGraphFromFavorite;

@end

@implementation GraphViewControlleriPhone

#pragma mark - Init & Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.wantsFullScreenLayout = YES;
        [self setImageSize];
        _currentDate = [NSDate date];
    }
    return self;
}

- (id)initWithGraph:(ZabbixGraph*)graph
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _graph = graph;
    }
    return self;
}

- (void)dealloc
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}


#pragma mark - View Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addViewElements];
    [self addAllRecognizers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Flurry logEvent:@"Show Graph"];
    [self loadGraph:_currentDate range:(_graph.range + 1) * 3600];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resetFullscrenTimer];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setBottomToolbar:nil];
    [self setDurationLabel:nil];
    [self setTopLabel:nil];
    [self setBottomLabel:nil];
    [self setTopView:nil];
    [super viewDidUnload];
}


#pragma mark - Device orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollView setZoomScale:1 animated:YES];
    [_scrollView setContentOffset:CGPointZero];

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [_scrollView setContentSize:self.view.frame.size];
    } else {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.width)];
    }
}

#pragma mark - Fullscreen Methods

- (void)startFullscreenTimer
{
    [self resetFullscrenTimer];
    [self performSelector:@selector(toggleFullscreen) withObject:nil afterDelay:kToggleFullscreenTimeout];
}

- (void)resetFullscrenTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleFullscreen) object:nil];
}

- (void)setFullscreenMode:(BOOL)fullscreenMode
{   
    if (fullscreenMode) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            _topView.frame = CGRectMake(0, - self.topView.frame.size.height, self.view.bounds.size.width, self.topView.frame.size.height);
            _bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.bottomToolbar.frame.size.height);
        } completion:^(BOOL finished) {
            _fullscreenMode = fullscreenMode;
        }];
    } else {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            _topView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.topView.frame.size.height);
            _bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - self.bottomToolbar.frame.size.height, self.view.bounds.size.width, self.bottomToolbar.frame.size.height);
        } completion:^(BOOL finished) {
            _fullscreenMode = fullscreenMode;
        }];
    }
}


#pragma mark - Add Visual Components


- (void)addViewElements
{
    [self addGraphArea];
    [self addHeaderBar];
    [self addFooterBar];
}

- (void)addHeaderBar
{
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nb_back_button"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"graph_share_button.png"] forState:UIControlStateNormal];
    [shareButton sizeToFit];
    [shareButton addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
    _shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    UILabel *topTitleLabel = [self createLabel];
    topTitleLabel.text =  _graph.graphName;
    topTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    topTitleLabel.minimumFontSize = 14;
    [topTitleLabel sizeToFit];
    UIBarButtonItem *topLabelItem = [[UIBarButtonItem alloc] initWithCustomView:topTitleLabel];
    
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIToolbar *topToolbar  = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, self.view.bounds.size.width, kToolBarHeight)];
    topToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topToolbar.items = @[backButtonItem,flexiableItem,topLabelItem,flexiableItem,_shareButtonItem];
    topToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    HeaderMenu *headerMenu = [[HeaderMenu alloc] initWithFrame:CGRectZero];
    headerMenu.menuDelegate = self;
    headerMenu.menuDataSource = self;
    headerMenu.tabWidth = 54;
    headerMenu.indicatorColor = [UIColor colorWithRed:109.0/255.0f green:180.0/255.0f blue:226.0/255.0f alpha:1.0f];
    headerMenu.textFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    headerMenu.defaultTextColor = [UIColor colorWithWhite:140.0f/255.0f alpha:1.0f];
    headerMenu.selectedTextColor = [UIColor whiteColor];
    headerMenu.backgroundColor = [UIColor clearColor];
    [headerMenu reloadData];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        headerMenu.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        headerMenu.frame =CGRectMake(self.view.bounds.size.width/2 - headerMenu.contentSize.width/2, CGRectGetMaxY(topToolbar.frame), headerMenu.contentSize.width, 44);
    } else {
        headerMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerMenu.frame = CGRectMake(0, CGRectGetMaxY(topToolbar.frame), self.view.frame.size.width, 44);
    }
    [headerMenu setActiveTabIndex:_graph.range];
    
    self.topView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetMaxY(headerMenu.frame))];
    self.topView.backgroundColor = [UIColor colorWithWhite:71.0f/255.0f alpha:1.0f];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.topView addSubview:headerMenu];
    [self.topView addSubview:topToolbar];
    self.topView.clipsToBounds = YES;
    self.topView.alpha = kBarTransparency;
    [self.view addSubview:self.topView];
}

- (void)addGraphArea
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, kStatusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - kStatusBarHeight)];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setCanCancelContentTouches:NO];
    _scrollView.clipsToBounds = NO;
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 3.0;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_scrollView];
    
    _graphImageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
    _graphImageView.contentMode = UIViewContentModeScaleAspectFit;
    _graphImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
    [_scrollView addSubview:_graphImageView];
}

- (void)addFooterBar
{
    UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
    dateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _durationLabel = [self createLabel];
    _durationLabel.frame = CGRectMake(0, 0, 220, 40);
    [dateView addSubview:_durationLabel];
    
    _topLabel = [self createLabel];
    _topLabel.frame = CGRectMake(0, 0, 220, 21);
    [dateView addSubview:_topLabel];
    
    _bottomLabel= [self createLabel];
    _bottomLabel.frame = CGRectMake(0, 21, 220, 19);
    _bottomLabel.textColor = [UIColor colorFromInt:0xb2b2b2];
    [dateView addSubview:_bottomLabel];
    
    UIBarButtonItem *dateItem = [[UIBarButtonItem alloc] initWithCustomView:dateView];
    
    UIButton* previousDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousDateButton setImage:[UIImage imageNamed:@"graphics_left.png"] forState:UIControlStateNormal];
    [previousDateButton sizeToFit];
    [previousDateButton addTarget:self action:@selector(onPreviousDate:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton= [[UIBarButtonItem alloc] initWithCustomView:previousDateButton];
    
    UIButton* nextDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextDateButton setImage:[UIImage imageNamed:@"graphics_right.png"] forState:UIControlStateNormal];
    [nextDateButton sizeToFit];
    [nextDateButton addTarget:self action:@selector(onNextDate:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:nextDateButton];
    
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    _bottomToolbar  = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kToolBarHeight,self.view.frame.size.width, kToolBarHeight)];
    _bottomToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _bottomToolbar.items = @[leftBarButton,flexiableItem,dateItem,flexiableItem,rightBarButton];
    _bottomToolbar.alpha = kBarTransparency;
    _bottomToolbar.clipsToBounds = YES;
    [self.view addSubview:_bottomToolbar];
}

- (UILabel*)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return label;
}

- (void)addAllRecognizers
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFullscreen:)];
    [_scrollView addGestureRecognizer:tapRecognizer];
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomGraph:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTapRecognizer];
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}


#pragma mark - Config Visual Components

- (void)setImageSize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    _imageSize = CGSizeMake(screenRect.size.height * scale, screenRect.size.width * scale);
}


#pragma mark - Loading Image

- (void)loadGraph:(NSDate *)endDate range:(NSTimeInterval)timeInterval
{
    [SVProgressHUD show];
    ZabbixRequestHelper *requestHelper = [[[LoggedUser sharedUser] clientAPI] requestHelper];
    NSURLRequest *imageRequest = [requestHelper graphImageRequestWithGraphId:_graph.graphId imageSize:_imageSize timeRange:timeInterval currentDate:endDate];
    AFImageRequestOperation *graphImageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:imageRequest imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self imageDidLoaded:image];
        [SVProgressHUD dismiss];
        [self showDurationWithStartDate:[endDate dateByAddingTimeInterval:-timeInterval] endDate:endDate];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        DLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
    }];
    [graphImageOperation start];
}


#pragma mark - Date Formatter

- (NSDate *)dateForRange:(GraphViewRange)range previousDate:(BOOL)isPreviousDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    NSDate *endDate = nil;
    NSUInteger factor = isPreviousDate ? -1 : 1;

    switch (range) {
        case GraphViewRangeOneHour:
            [offsetComponents setHour:factor * 1];
            break;
        case GraphViewRangeTwoHours:
            [offsetComponents setHour:factor * 2];
            break;
        case GraphViewRangeThreeHours:
            [offsetComponents setHour:factor * 3];
            break;
        case GraphViewRangeSixHours:
            [offsetComponents setHour:factor * 6];
            break;
        case GraphViewRangeTwelveHours:
            [offsetComponents setHour:factor * 12];
            break;
        case GraphViewRangeOneDay:
            [offsetComponents setHour:factor * 24];
            break;
        case GraphViewRangeSevenDays:
            [offsetComponents setDay:factor * 7];
            break;
        case GraphViewRangeFourteenDays:
            [offsetComponents setDay:factor * 14];
            break;
        case GraphViewRangeOneMonth:
            [offsetComponents setMonth:factor * 1];
            break;
        case GraphViewRangeTwoMonths:
            [offsetComponents setMonth:factor * 2];
            break;
        case GraphViewRangeThreeMonths:
            [offsetComponents setMonth:factor * 3];
            break;
        case GraphViewRangeSixMonths:
            [offsetComponents setMonth:factor * 6];
            break;
        case GraphViewRangeOneYear:
            [offsetComponents setYear:factor * 1];
            break;
        default:
            break;
    }

    endDate = [gregorian dateByAddingComponents:offsetComponents toDate:_currentDate options:0];
    return endDate;
}


- (void)showDurationWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.dateFormat = @"dd MMMM yyyy";
    NSString *startDateString = [dateFormatter stringFromDate:startDate];
    NSString *endDateString = [dateFormatter stringFromDate:endDate];
    if ([startDateString isEqualToString:endDateString]) {
        dateFormatter.dateFormat = @"dd MMMM yyyy";
        _topLabel.text = [NSString stringWithFormat:@"%@", startDateString];
        dateFormatter.dateFormat = @"h:mm a";
        startDateString = [dateFormatter stringFromDate:startDate];
        endDateString = [dateFormatter stringFromDate:endDate];
        _bottomLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
        _durationLabel.text = @"";
    } else {
        _durationLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
        _topLabel.text = @"";
        _bottomLabel.text = @"";
    }
}

#pragma mark - Actions

- (void)imageDidLoaded:(UIImage *)image
{
    _graphImageView.image = image;
    [self startFullscreenTimer];
}

- (void)toggleFullscreen
{
    [self setFullscreenMode:YES];
}

- (void)toggleFullscreen:(id)sender
{
    [self setFullscreenMode:!_fullscreenMode];
    if (_fullscreenMode) {
        [self resetFullscrenTimer];
    }
}

- (void)zoomGraph:(id)sender
{
    UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *) sender;
    CGPoint location = [recognizer locationInView:_graphImageView];
    [_scrollView zoomToPoint:location withScale:_scrollView.maximumZoomScale animated:YES];
}

- (void)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onShare:(id)sender
{
    if (_actionSheet == nil) {
        
        NSString *favoriteActionString = nil;
        if ([self hasGraphInFavorites]) {
            favoriteActionString = NSLocalizedString(@"Remove from Favorites", nil);
        } else {
            favoriteActionString = NSLocalizedString(@"Add to Favorites", nil);
        }
        
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Send by email",nil),NSLocalizedString(@"Save to library",nil),favoriteActionString, nil];
        _actionSheet.delegate = self;

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [_actionSheet showFromBarButtonItem:_shareButtonItem  animated:YES];
        } else {
            [_actionSheet showFromToolbar:_bottomToolbar];
        }

    } else {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
        _actionSheet = nil;
    }
}


- (void)onPreviousDate:(id)sender
{
    [Flurry logEvent:@"Previous date pressed"];
    NSDate *endDate = [self dateForRange:_graph.range previousDate:YES];
    NSTimeInterval secondsBetween = [_currentDate timeIntervalSinceDate:endDate];

    _currentDate = endDate;
    [self resetFullscrenTimer];
    [self loadGraph:_currentDate range:secondsBetween];
}

- (void)onNextDate:(id)sender
{
    [Flurry logEvent:@"Next date pressed"];
    NSDate *endDate = [self dateForRange:_graph.range previousDate:NO];
    if ([endDate compare:[NSDate date]] != NSOrderedDescending) {
        NSTimeInterval secondsBetween = [endDate timeIntervalSinceDate:_currentDate];
        _currentDate = endDate;
        [self resetFullscrenTimer];
        [self loadGraph:_currentDate range:secondsBetween];
    }
}

- (void)sendByEmail
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:NSLocalizedString(@"Failed to send mail", nil)
                           message:NSLocalizedString(@"Mail account is not configured", nil)
                           delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:[NSString stringWithFormat:@"%@ (%@)",_graph.graphName,[_graph stringValueForRange:_graph.range]]];
    
    NSData *myData = UIImagePNGRepresentation(_graphImageView.image);
    [picker addAttachmentData:myData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",_graph.graphName]];
    
    [self presentModalViewController:picker animated:YES];
}

- (void)saveInGallery
{
    UIImageWriteToSavedPhotosAlbum(_graphImageView.image, nil, nil, nil);
}

#pragma mark - Favorite Methods

- (void)addGraphToFavorite
{
    if (![self hasGraphInFavorites]) {
        NSMutableArray* graphFavorites = [[[ZabbKitApplicationSettings sharedApplicationSettings] graphFavoritesForServer:[LoggedUser sharedUser].currentServer] mutableCopy];
        [graphFavorites addObject:_graph];
        [[ZabbKitApplicationSettings sharedApplicationSettings] setGraphFavorites:graphFavorites forServer:[LoggedUser sharedUser].currentServer];
    }
}

- (void)removeGraphFromFavorite
{
    
    if ([self hasGraphInFavorites]) {
        NSMutableArray* graphFavorites = [[[ZabbKitApplicationSettings sharedApplicationSettings] graphFavoritesForServer:[LoggedUser sharedUser].currentServer] mutableCopy];
        [graphFavorites removeObject:_graph];
        [[ZabbKitApplicationSettings sharedApplicationSettings] setGraphFavorites:graphFavorites.copy forServer:[LoggedUser sharedUser].currentServer];
    }
}

- (BOOL)hasGraphInFavorites
{
    NSArray* graphFavorites = [[ZabbKitApplicationSettings sharedApplicationSettings] graphFavoritesForServer:[LoggedUser sharedUser].currentServer];
    NSInteger index = [graphFavorites indexOfObjectPassingTest:^BOOL(ZabbixGraph* graph, NSUInteger idx, BOOL *stop) {
        return [_graph isEqual:graph];
    }];
    
    if (index != NSNotFound && graphFavorites) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _graphImageView;
}

#pragma mark - HeaderMenu Delegate

- (NSUInteger)numberOfTabsForHeaderMenu:(HeaderMenu *)headerMenu
{
    return GraphViewRangeCount;
}

- (NSString *)headerMenu:(HeaderMenu *)headerMenu titleForItemAtIndex:(NSUInteger)index{
    return [_graph stringValueForRange:index];
}

- (void)headerMenu:(HeaderMenu *)headerMenu didSelectItemAtIndex:(NSUInteger)index
{
    _graph.range = index;
    NSDate *endDate = [self dateForRange:index previousDate:YES];
    NSTimeInterval secondsBetween = [_currentDate timeIntervalSinceDate:endDate];
    [self loadGraph:_currentDate range:secondsBetween];
    [self startFullscreenTimer];
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == ShareByEmail) {
        [self sendByEmail];
    } else if (buttonIndex == ShareBySave) {
        [self saveInGallery];
    } else if (buttonIndex == ShareByFavorite) {
        if ([self hasGraphInFavorites])
        {
            [self removeGraphFromFavorite];
        } else {
            [self addGraphToFavorite];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _actionSheet = nil;
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            DLog(@"Cancelled");
            break;
        case MFMailComposeResultSaved:
            DLog(@"Saved");
            break;
        case MFMailComposeResultFailed: {
            DLog(@"Failed");
            UIAlertView *av = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Failed to send mail", nil)
                               message:[error localizedDescription]
                               delegate:nil
                               cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                               otherButtonTitles:nil];
            [av show];
        }
            break;
        case MFMailComposeResultSent:
            DLog(@"Sent");
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
