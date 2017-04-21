//
//  ServerTableViewCell.m
//  ZabbKit
//
//  Created by Andrey Kosykhin on 30.01.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "ServerTableViewCell.h"
#import "UIView+Separator.h"
#import "UIImage+Color.h"

static CGFloat const kLeftOffset = 16.0;
static CGFloat const kRightOffset = 16.0;
static CGFloat const kLabelHeight = 20.0;


@implementation ServerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        
        UIImage* colorImage = [UIImage imageWithColor:[UIColor colorWithWhite:106.0f/255.0f alpha:1.0f]];
        [self.contentView addBottomSeparatorLeft:16.0f right:16.0f height:1.0f image:colorImage highlightedImage:colorImage];
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.highlightedTextColor = [UIColor grayColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow"]];
    }
    return self;
}

@end
