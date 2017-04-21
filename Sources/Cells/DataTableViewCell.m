//
//  DataTableViewCell.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 19.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "DataTableViewCell.h"
#import "UIImage+Color.h"
#import "UIView+Separator.h"
#import "ZabbixItem.h"
#import "ZabbixHost.h"

static CGFloat const kTopOffset = 10.0f;
static CGFloat const kLeftOffset = 20.0;
static CGFloat const kRightOffset = 10.0;
static CGFloat const kNameHieght = 20.0;
static CGFloat const kLabelHeight = 20.0;
static CGFloat const kLabelPadding = 6.0;

@interface DataTableViewCell () {
}

@end

@implementation DataTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        
        UIImage* colorImage = [UIImage imageWithColor:[UIColor colorWithWhite:106.0f/255.0f alpha:1.0f]];
        [self.contentView addBottomSeparatorLeft:16.0f right:5.0f height:1.0f image:colorImage highlightedImage:colorImage];
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        self.textLabel.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        self.textLabel.numberOfLines = 1;

        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        self.detailTextLabel.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        self.detailTextLabel.numberOfLines = 1;
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setImage:[UIImage imageNamed:@"overview_chart_icon"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"overview_chart_icon_highlighted"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"overview_chart_icon_highlighted"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = button;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.bounds;
    self.textLabel.frame = CGRectMake(kLeftOffset, kTopOffset, frame.size.width - kLeftOffset - kRightOffset, kNameHieght);
    self.detailTextLabel.frame = CGRectMake(kLeftOffset, kTopOffset + (kNameHieght + kLabelPadding), frame.size.width - kLeftOffset - kRightOffset, kLabelHeight);
}

- (void)accessoryButtonTapped:(id)sender event:(id)event
{
    UIView* tableView = (UIView*)self.superview;
    while (tableView!= nil) {
        if ([tableView isKindOfClass:[UITableView class]]) {
            NSIndexPath* indexPath = [(UITableView*)tableView indexPathForCell:self];
            [[(UITableView*)tableView delegate] tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
            break;
        }
        tableView = tableView.superview;
    }
}

- (void)updateWithItem:(ZabbixItem *)item
{
    self.textLabel.text = [NSString stringWithFormat:@"%@: %@", item.host.hostName, item.itemName];
    NSString* valueString = nil;
    if (item.lastValue.length > 0) {
        if (item.valueUnits.length > 0) {
            valueString = [NSString stringWithFormat:@"%@ %@", item.lastValue, item.valueUnits];
        } else {
            valueString = [NSString stringWithFormat:@"%@", item.lastValue];
        }
    }
    self.detailTextLabel.text = valueString;
    self.accessoryView.hidden = item.graph == nil;
    [self setNeedsLayout];
}

@end
