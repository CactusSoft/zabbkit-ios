//
//  AboutViewControlleriPhone.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 03.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "AboutViewControlleriPhone.h"
#import "AKSegmentedControl.h"
#import "UIImage+Color.h"

static CGFloat const kTopBarHeight = 48.0f;
static CGFloat const kLegendItemTitleHeight = 24.0f;
static CGFloat const kLegendItemHeight = 64.0f;
static CGFloat const kLegendItemIntend = 10.0f;
static CGFloat const kCastLineWidth = 100.0f;
static CGFloat const kCastLineHeight = 1;
static CGFloat const kSwordImageIntend = 40.0f;
static CGFloat const kFooterBlockIntend = 10.0f;
static CGFloat const kFooterBlockHeight = 100.0f;
static CGFloat const kFooterLabelIntend = 15.0f;
static CGFloat const kCompanyBlockIntend = 50.0f;
static CGFloat const kCompanyBlockHeight = 56.0f;
static CGFloat const kTitleLabelIntend = 40.0f;
static CGFloat const kDescriptionLabelIntend = 16.0f;
static CGFloat const kSeparatorBlockIntend = 36.0f;
static CGFloat const kInfoBlockIntend = 40.0f;
static CGFloat const kEndIntend = 20.0f;

@interface AboutViewControlleriPhone ()
{
    UIScrollView *scrollView_;
    UIView *_aboutView;
    UIView *_footerBlock;
    UIView *_contentBlock;
    UIView *_headerBlock;
    UIView *_subBackgroundView;
    UIView *_legendView;
    AKSegmentedControl* _segmentedControl;
}

- (void)addSegmentedControl;
- (void)addScrollViewWithContentView:(UIView*)contentView;
- (void)createAboutScreenView;
- (void)createLegendScreenView;

@end

@implementation AboutViewControlleriPhone

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
    self.title = NSLocalizedString(@"About", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addSegmentedControl];
    [self createAboutScreenView];
    [self createLegendScreenView];
    [self addScrollViewWithContentView:_aboutView];
    [Flurry logEvent:@"About page"];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resizeAboutScreenWithScreenSize:self.view.bounds.size.height - _segmentedControl.frame.size.height];
}

#pragma mark - Action Methods

- (void)tabSwitched:(id)sender
{
    [scrollView_ removeFromSuperview];
    if ([[_segmentedControl selectedIndexes] firstIndex] == 0) {
        [self addScrollViewWithContentView:_aboutView];
    } else {
        [self addScrollViewWithContentView:_legendView];
    }
}

#pragma mark - Private Methods


- (void)addSegmentedControl
{
    _segmentedControl = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 44)];
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleBottomMargin;
    [_segmentedControl addTarget:self action:@selector(tabSwitched:) forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setSelectedIndex:0];
    [self.view addSubview:_segmentedControl];
    
    UIImage* separatorImage = [UIImage imageWithColor:[UIColor colorWithWhite:81.0f/255.0f alpha:1.0f]];
    UIImage* backgroundNormal = [UIImage imageWithColor:[UIColor colorWithWhite:62.0f/255.0f alpha:1.0f]];
    UIImage* backgroundHilighted = [UIImage imageWithColor:[UIColor colorWithWhite:44.0f/255.0f alpha:1.0f]];
    UIImage* castIconNormal = [UIImage imageNamed:@"about_icon.png"];
    UIImage* castIconHighlighted = [UIImage imageNamed:@"about_icon.png"];
    UIImage* legendIconNormal = [UIImage imageNamed:@"legend_icon.png"];
    UIImage* legendIconHightlighted = [UIImage imageNamed:@"legend_icon.png"];
    UIColor* titleColorNormal = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];
    UIColor* titleColorHighlighted = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0];
    UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    
    [_segmentedControl setBackgroundImage:backgroundNormal];
    [_segmentedControl setSeparatorImage:separatorImage];
    
    UIButton* buttonCast = [[UIButton alloc] init];
    [buttonCast setTitle:NSLocalizedString(@"Cast",nil) forState:UIControlStateNormal];
    [buttonCast.titleLabel setFont:font];
    [buttonCast setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [buttonCast setBackgroundImage:backgroundNormal forState:UIControlStateNormal];
    [buttonCast setBackgroundImage:backgroundHilighted forState:UIControlStateHighlighted];
    [buttonCast setBackgroundImage:backgroundHilighted forState:UIControlStateSelected];
    [buttonCast setTitleColor:titleColorNormal forState:UIControlStateNormal];
    [buttonCast setTitleColor:titleColorHighlighted forState:UIControlStateHighlighted];
    [buttonCast setTitleColor:titleColorHighlighted forState:UIControlStateSelected];
    [buttonCast setImage:castIconNormal forState:UIControlStateNormal];
    [buttonCast setImage:castIconHighlighted forState:UIControlStateHighlighted];
    [buttonCast setImage:castIconHighlighted forState:UIControlStateSelected];
    
    UIButton* buttonLegend = [[UIButton alloc] init];
    [buttonLegend setTitle:NSLocalizedString(@"Legend", nil) forState:UIControlStateNormal];
    [buttonLegend.titleLabel setFont:font];
    [buttonLegend setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    [buttonLegend setBackgroundImage:backgroundNormal forState:UIControlStateNormal];
    [buttonLegend setBackgroundImage:backgroundHilighted forState:UIControlStateHighlighted];
    [buttonLegend setBackgroundImage:backgroundHilighted forState:UIControlStateSelected];
    [buttonLegend setTitleColor:titleColorNormal forState:UIControlStateNormal];
    [buttonLegend setTitleColor:titleColorHighlighted forState:UIControlStateHighlighted];
    [buttonLegend setTitleColor:titleColorHighlighted forState:UIControlStateSelected];
    [buttonLegend setImage:legendIconNormal forState:UIControlStateNormal];
    [buttonLegend setImage:legendIconHightlighted forState:UIControlStateHighlighted];
    [buttonLegend setImage:legendIconHightlighted forState:UIControlStateSelected];
    
    [_segmentedControl setButtonsArray:@[buttonCast, buttonLegend]];
}


- (void)addScrollViewWithContentView:(UIView*)contentView
{
    scrollView_ = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentedControl.bounds), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(_segmentedControl.bounds))];
    scrollView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView_.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
    [contentView setFrame:CGRectMake(0, 0, self.view.frame.size.width, contentView.frame.size.height)];
    scrollView_.contentSize = CGSizeMake(1, contentView.frame.size.height);
    [scrollView_ addSubview:contentView];
    [self.view addSubview:scrollView_];
}

#pragma mark - Cast Screen

- (void)createAboutScreenView
{
    _aboutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(_segmentedControl.bounds))];
    _aboutView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _aboutView.backgroundColor = [UIColor clearColor];
    [self addHeaderBlock];
    [self addContentBlock];
    [self addFooterBlock];
    [self resizeAboutScreenWithScreenSize:self.view.bounds.size.height - _segmentedControl.frame.size.height];
}


- (void)addHeaderBlock
{
    _headerBlock = [[UIView alloc] initWithFrame:CGRectMake(0,  0 , self.view.frame.size.width, 0)];
    _headerBlock.backgroundColor = [UIColor clearColor];
    _headerBlock.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_aboutView addSubview:_headerBlock];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zabbkit.png"]];
    logoImage.center = CGPointMake(_headerBlock.center.x, kInfoBlockIntend);
    logoImage.contentMode = UIViewContentModeCenter;
    logoImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_headerBlock addSubview:logoImage];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSString *keyStr = @"CFBundleShortVersionString";
    NSString *versionSt = [[[NSBundle mainBundle] infoDictionary] objectForKey:keyStr];
    versionLabel.text = [NSString stringWithFormat:@"V. %@",versionSt];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    versionLabel.textColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0];
    versionLabel.textAlignment = NSTextAlignmentLeft;
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [versionLabel sizeToFit];
    versionLabel.center = CGPointMake(CGRectGetMaxX(logoImage.bounds) + 6 + versionLabel.frame.size.width/2, logoImage.bounds.origin.y - 10);
    [logoImage addSubview:versionLabel];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    infoLabel.text = NSLocalizedString(@"Client-application for Zabbix monitoring system.", nil);
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    infoLabel.textColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    infoLabel.numberOfLines = 2;
    [infoLabel sizeToFit];
    infoLabel.center = CGPointMake(self.view.center.x,  CGRectGetMaxY(logoImage.frame) + 15);
    [_headerBlock addSubview:infoLabel];
    
    UIView *castView = [[UIView alloc] initWithFrame:CGRectZero];
    castView.backgroundColor = [UIColor clearColor];
    castView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_headerBlock addSubview:castView];
    
    UILabel *castLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    castLabel.text = NSLocalizedString(@"Cast", nil).uppercaseString;
    castLabel.backgroundColor = [UIColor clearColor];
    castLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    castLabel.textColor = [UIColor whiteColor];
    castLabel.textAlignment = NSTextAlignmentCenter;
    [castLabel sizeToFit];
    castLabel.center = CGPointMake(CGRectGetMidX(_headerBlock.frame), kSeparatorBlockIntend);
    [castView addSubview:castLabel];
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(castLabel.frame.origin.x - kCastLineWidth - 15, CGRectGetMidY(castLabel.frame), kCastLineWidth, kCastLineHeight)];
    leftLine.backgroundColor = [UIColor colorWithWhite:62.0f/255.0f alpha:1.0f];
    [castView addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(castLabel.frame.origin.x + castLabel.frame.size.width + 15, CGRectGetMidY(castLabel.frame), kCastLineWidth, kCastLineHeight)];
    rightLine.backgroundColor = [UIColor colorWithWhite:62.0f/255.0f alpha:1.0f];
    [castView addSubview:rightLine];
    castView.frame = CGRectMake(0, CGRectGetMaxY(infoLabel.frame) , _headerBlock.frame.size.width, CGRectGetMaxY(castLabel.frame));
    
    CGRect frame = _headerBlock.frame;
    frame.size.height = CGRectGetMaxY(castView.frame);
    _headerBlock.frame = frame;
}

- (void)addContentBlock
{
    _contentBlock = [[UIView alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(_headerBlock.frame) , self.view.frame.size.width, 0)];
    _contentBlock.backgroundColor = [UIColor clearColor];
    _contentBlock.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_aboutView addSubview:_contentBlock];
    
    [self addBlockWithTitle:NSLocalizedString(@"iOS Developing", nil) description:NSLocalizedString(@"Developers", nil)];
    [self addBlockWithTitle:NSLocalizedString(@"Interface Design", nil) description:NSLocalizedString(@"Designers", nil)];
    [self addBlockWithTitle:NSLocalizedString(@"Policeman in pub", nil) description:NSLocalizedString(@"Policeman", nil)];
    
    CGRect frame = _contentBlock.frame;
    frame.size.height = CGRectGetMaxY(((UIView*)_contentBlock.subviews.lastObject).frame);
    _contentBlock.frame = frame;
}

- (void)addBlockWithTitle:(NSString*)title description:(NSString*)descriprion
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    titleLabel.textColor = [UIColor colorWithWhite:168.0f/255.0f alpha:1.0];
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(_contentBlock.center.x, CGRectGetMaxY(((UIView*)_contentBlock.subviews.lastObject).frame) + kTitleLabelIntend);
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_contentBlock addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    descriptionLabel.text = descriprion;
    [descriptionLabel sizeToFit];
    descriptionLabel.center = CGPointMake(_contentBlock.center.x, CGRectGetMaxY(titleLabel.frame) + descriptionLabel.frame.size.height/2 + kDescriptionLabelIntend);
    descriptionLabel.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_contentBlock addSubview:descriptionLabel];
}


- (void)addFooterBlock
{
    _footerBlock = [[UIView alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(_contentBlock.frame) + kCompanyBlockIntend, self.view.frame.size.width, 0)];
    _footerBlock.backgroundColor = [UIColor clearColor];
    _footerBlock.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_aboutView addSubview:_footerBlock];
    
    UIView *companyView = [[UIView alloc] initWithFrame:CGRectZero];
    companyView.backgroundColor = [UIColor clearColor];
    companyView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_footerBlock addSubview:companyView];
    
    UIImageView *companyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cactus.png"]];
    companyImage.center = CGPointMake(_footerBlock.center.x + companyImage.image.size.width/2 - 5, companyImage.center.y);
    companyImage.contentMode = UIViewContentModeCenter;
    [companyView addSubview:companyImage];
    
    UILabel *companyLabel =[[UILabel alloc] initWithFrame:CGRectZero];
    companyLabel.text = NSLocalizedString(@"Developed by:", nil);
    companyLabel.backgroundColor = [UIColor clearColor];
    companyLabel.textAlignment = NSTextAlignmentRight;
    companyLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    companyLabel.textColor = [UIColor colorWithWhite:108/255.0 alpha:1.0];
    [companyLabel sizeToFit];
    companyLabel.center = CGPointMake(_footerBlock.center.x - companyLabel.frame.size.width/2 - 25,companyImage.center.y);
    [companyView addSubview:companyLabel];
    
    companyView.frame = CGRectMake(0, 0, _footerBlock.frame.size.width, CGRectGetMaxY(companyImage.frame));
    

    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(companyView.frame) + kFooterBlockIntend, _footerBlock.frame.size.width, kFooterBlockHeight)];
    [backgroundView setBackgroundColor:[UIColor colorWithWhite:24.0f/255.0f alpha:1.0f]];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_footerBlock addSubview:backgroundView];
    
    UIImageView* swordImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sword.png"]];
    swordImage.center = CGPointMake(backgroundView.center.x, kSwordImageIntend);
    swordImage.contentMode = UIViewContentModeCenter;
    swordImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [backgroundView addSubview:swordImage];

    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    footerLabel.text = NSLocalizedString(@"May the force be with you", nil).uppercaseString;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    footerLabel.textColor = [UIColor colorWithRed:108/255.0 green:108/255.0 blue:108/255.0 alpha:1.0];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [footerLabel sizeToFit];
    footerLabel.center = CGPointMake(backgroundView.center.x, CGRectGetMaxY(swordImage.frame) + kFooterLabelIntend);
    [backgroundView addSubview:footerLabel];

    CGRect frame = _footerBlock.frame;
    frame.size.height = CGRectGetMaxY(((UIView*)_footerBlock.subviews.lastObject).frame);
    _footerBlock.frame = frame;
    
    _subBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [_subBackgroundView setBackgroundColor:[UIColor colorWithWhite:24.0f/255.0f alpha:1.0f]];
    _subBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_aboutView insertSubview:_subBackgroundView belowSubview:_footerBlock];
}

- (void)resizeAboutScreenWithScreenSize:(CGFloat)screenHeight
{
    
    CGRect frame = _footerBlock.frame;
    frame.origin.y = CGRectGetMaxY(_contentBlock.frame) + kCompanyBlockIntend;
    _footerBlock.frame = frame;
    
    if (CGRectGetMaxY(_footerBlock.frame) >= screenHeight) {
        [_aboutView setFrame:CGRectMake(_aboutView.frame.origin.x, _aboutView.frame.origin.y, _aboutView.frame.size.width, CGRectGetMaxY(_footerBlock.frame))];
    } else {
        [_aboutView setFrame:CGRectMake(_aboutView.frame.origin.x, _aboutView.frame.origin.y, _aboutView.frame.size.width, screenHeight)];
    }
    
    frame.origin.y = _aboutView.frame.size.height - frame.size.height;
    _footerBlock.frame = frame;
    _subBackgroundView.frame = CGRectMake(0, CGRectGetMaxY(_footerBlock.frame), _footerBlock.frame.size.width, _aboutView.bounds.size.height);
    scrollView_.contentSize = CGSizeMake(1, _aboutView.frame.size.height);
}


#pragma mark - Legend Screen

- (void)createLegendScreenView
{
    _legendView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), 0)];
    _legendView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _legendView.clipsToBounds = NO;
    [self addLegendTitle];
    [self addLegendItemWithTitle:NSLocalizedString(@"Ok", nil) description:NSLocalizedString(@"Your weapons, you will not need them.", nil) backgroundColor:[UIColor colorWithRed:140/255.0 green:196/255.0 blue:31/255.0 alpha:1.0]];
    [self addLegendItemWithTitle:NSLocalizedString(@"Not classified", nil) description:NSLocalizedString(@"Difficult to see. Always in motion is the future", nil) backgroundColor:[UIColor colorWithRed:161/255.0 green:172/255.0 blue:180/255.0 alpha:1.0]];
    [self addLegendItemWithTitle:NSLocalizedString(@"Information", nil) description:NSLocalizedString(@"Mind what you have learned. Save you it can.", nil) backgroundColor:[UIColor colorWithRed:17/255.0 green:169/255.0 blue:240/255.0 alpha:1.0]];
    [self addLegendItemWithTitle:NSLocalizedString(@"Warning", nil) description:NSLocalizedString(@"Named must your fear be before banish it you can", nil) backgroundColor:[UIColor colorWithRed:247/255.0 green:181/255.0 blue:22/255.0 alpha:1.0]];
    [self addLegendItemWithTitle:NSLocalizedString(@"Average", nil) description:NSLocalizedString(@"Happens to every guy sometimes this does", nil) backgroundColor:[UIColor colorWithRed:250/255.0 green:115/255.0 blue:41/255.0 alpha:1.0]];
    [self addLegendItemWithTitle:NSLocalizedString(@"High", nil) description:NSLocalizedString(@"Hurry, the galaxy is in danger", nil) backgroundColor:[UIColor colorWithRed:205/255.0 green:61/255.0 blue:208/255.0 alpha:1.0]];
    [self addLegendItemWithTitle:NSLocalizedString(@"Disaster", nil) description:NSLocalizedString(@"May the force be with you", nil) backgroundColor:[UIColor colorWithRed:199/255.0 green:29/255.0 blue:33/255.0 alpha:1.0]];
}

- (void)addLegendTitle
{
    UILabel *legendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    legendLabel.backgroundColor = [UIColor clearColor];
    legendLabel.text = NSLocalizedString(@"Colors used for trigger markers", nil);
    legendLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    legendLabel.minimumFontSize = 12;
    legendLabel.textColor= [UIColor whiteColor];
    legendLabel.textAlignment = NSTextAlignmentCenter;
    legendLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    legendLabel.numberOfLines = 2;
    [legendLabel sizeToFit];
    legendLabel.center = CGPointMake(_legendView.center.x, 20);
    [_legendView addSubview:legendLabel];
}

- (void)addLegendItemWithTitle:(NSString*)title description:(NSString*)description backgroundColor:(UIColor*)backgroundColor
{
    UIView* legendItem = [[UIView alloc] initWithFrame:CGRectMake(kLegendItemIntend, CGRectGetMaxY(((UIView*)_legendView.subviews.lastObject).frame) + kLegendItemIntend, CGRectGetMaxX(_legendView.frame) - 2*kLegendItemIntend, kLegendItemHeight)];
    legendItem.backgroundColor = backgroundColor;
    legendItem.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_legendView addSubview:legendItem];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(kLegendItemIntend, kLegendItemIntend, CGRectGetMaxX(legendItem.frame) - 2*kLegendItemIntend, kLegendItemTitleHeight)];
    titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    [titleLabel sizeToFit];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin ;
    [legendItem addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame: CGRectMake(kLegendItemIntend, CGRectGetMaxY(titleLabel.frame), CGRectGetMaxX(legendItem.frame) - 2*kLegendItemIntend, kLegendItemTitleHeight)];
    descriptionLabel.text = description;
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    descriptionLabel.numberOfLines = 2;
    [descriptionLabel sizeToFit];
    descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin ;

    [legendItem addSubview:descriptionLabel];
    [_legendView setFrame:CGRectMake(_legendView.frame.origin.x, _legendView.frame.origin.y, _legendView.frame.size.width, CGRectGetMaxY(legendItem.frame) + kEndIntend)];
}


@end



