//
//  NavigationTableViewCell.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 30.01.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NavigationTableViewCell.h"
#import "UIImage+Color.h"
#import "UIView+Separator.h"
#import "CommonConstants.h"

@interface NavigationTableViewCell ()

@end


@implementation NavigationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:59.0f/255.0f alpha:1.0f];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0f];
        
        UIImage* colorImage = [UIImage imageWithColor:[UIColor colorWithWhite:106.0f/255.0f alpha:1.0f]];
        [self.contentView addBottomSeparatorLeft:0.0f right:0.0f height:1.0f image:colorImage highlightedImage:colorImage];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    }
    return self;
}

- (void)updateWithType:(ZabbKitPaneType)paneType
{
    switch (paneType) {
        case ZabbKitPaneTypeOverview:
            self.imageView.image = [UIImage imageNamed:@"main_icon_overview.png"];
            self.textLabel.text = NSLocalizedString(@"Overview", @"Overview");
            break;
        case ZabbKitPaneTypeFavorites:
            self.imageView.image = [UIImage imageNamed:@"main_icon_bookmark.png"];
            self.textLabel.text = NSLocalizedString(@"Favorites", @"Favorites");
            break;
        case ZabbKitPaneTypeNotifications:
            self.imageView.image = [UIImage imageNamed:@"main_icon_notification.png"];
            self.textLabel.text = NSLocalizedString(@"Notifications", @"Notifications");
            break;
        case ZabbKitPaneTypeServerList:
            self.imageView.image = [UIImage imageNamed:@"main_icon_overview.png"];
            self.textLabel.text = NSLocalizedString(@"Server list", @"Server list");
            break;
        case ZabbKitPaneTypeAbout:
            self.imageView.image = [UIImage imageNamed:@"main_icon_about.png"];
            self.textLabel.text = NSLocalizedString(@"About", @"About");
            break;
        case ZabbKitPaneTypeLogout:
            self.imageView.image = [UIImage imageNamed:@"main_icon_logout.png"];
            self.textLabel.text = NSLocalizedString(@"Logout", @"Logout");
            break;
        default:
            self.imageView.image = nil;
            self.textLabel.text = nil;
            break;
    }
    [self setNeedsDisplay];
}

@end
