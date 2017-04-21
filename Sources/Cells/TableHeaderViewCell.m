//
//  TableHeaderViewCell.m
//  Zabbkit
//
//  Created by Anna on 26.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "TableHeaderViewCell.h"
#import "UIView+Separator.h"

@implementation TableHeaderViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float g_yUIShift = 0.0f;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
            g_yUIShift = 20.0f;
        }
        
        self.backgroundColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0f];
        self.userInteractionEnabled = NO;
        
        _serverNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0 + g_yUIShift, self.frame.size.width, 24)];
        _serverNameLabel.textAlignment = UITextAlignmentLeft;
        _serverNameLabel.textColor = [UIColor colorWithWhite:255.0f/255.0f alpha:1.0f];
        _serverNameLabel.backgroundColor = [UIColor clearColor];
        _serverNameLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        [self addSubview:_serverNameLabel];
        
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 20 + g_yUIShift, self.frame.size.width, 18)];
        _userNameLabel.textAlignment = UITextAlignmentLeft;
        _userNameLabel.textColor = [UIColor colorWithWhite:161.0f/255.0f alpha:1.0f];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        [self addSubview:_userNameLabel];
        
        [self.contentView addBottomSeparatorLeft:0.0f right:0.0f height:1.0f image:[UIImage imageNamed:@"table_separator"] highlightedImage:[UIImage imageNamed:@"table_separator"]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
