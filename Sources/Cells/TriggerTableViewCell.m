//
//  TriggerTableViewCell.m
//  Shtirlits
//
//  Created by Alexey Dozortsev
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "TriggerTableViewCell.h"
#import "ZabbixTrigger.h"
#import "UIView+Separator.h"
#import "SerializationKeys.h"
#import "UIImage+Color.h"
#import <QuartzCore/QuartzCore.h>

static CGRect const kPriorityRect = {{24.0f, 13.0f}, {4.0f, 40.0f}};
static UIEdgeInsets const kTextInsets = {13.0f, 34.0f, 0.0f, 18.0f};
static UIEdgeInsets const kDetailTextInsets = {0.0f, 34.0f, 13.0f, 18.0f};
static CGFloat const kTextLabelHeight = 20;
static CGFloat const kDetailTextLabelHeight = 16;

@interface TriggerTableViewCell () {
    UIView* _priorityView;
    UIView* _highlightedPriorityView;
}

- (UIColor*)colorForPriority:(ZabbixTriggerPriority)priority;

@end


@implementation TriggerTableViewCell

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
        
        _priorityView = [[UIView alloc] initWithFrame:kPriorityRect];
        _priorityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.backgroundView addSubview:_priorityView];
        
        _highlightedPriorityView = [[UIView alloc] initWithFrame:kPriorityRect];
        _highlightedPriorityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.selectedBackgroundView addSubview:_highlightedPriorityView];
        
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithWhite:255.0f/255.0f alpha:1.0f];
        self.textLabel.highlightedTextColor = [UIColor colorWithWhite:127.0f/255.0f alpha:1.0f];
        
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:117.0f/255.0f alpha:1.0f];
        self.detailTextLabel.highlightedTextColor = [UIColor colorWithWhite:58.0f/255.0f alpha:1.0f];
        
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow"]];
    }
    return self;
}

- (void) updateWithTrigger:(ZabbixTrigger*)trigger
{
    if (!trigger.triggerDescription) {
        self.textLabel.text = NSLocalizedString(@"No Name",nil);
    } else {
        self.textLabel.text = trigger.triggerDescription;
    }
    
    if (trigger.hosts && trigger.hosts.count > 0) {
        NSDictionary* hostDict = [trigger.hosts objectAtIndex:0];
        if ([hostDict objectForKey:kHostName]) {
            self.detailTextLabel.text = [hostDict objectForKey:kHostName];
        }
    }
    if (trigger.value == 1) {
        _priorityView.backgroundColor = [self colorForPriority:trigger.priority];
        _highlightedPriorityView.backgroundColor = [self colorForPriority:trigger.priority];
    } else {
        _priorityView.backgroundColor = [UIColor greenColor];
        _highlightedPriorityView.backgroundColor = [UIColor greenColor];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _priorityView.frame = kPriorityRect;
    
    CGRect frame = self.contentView.bounds;
    
    self.textLabel.frame = CGRectMake(kTextInsets.left, kTextInsets.top, frame.size.width - kTextInsets.left - kTextInsets.right, kTextLabelHeight);
    self.detailTextLabel.frame = CGRectMake(kDetailTextInsets.left, frame.size.height - kDetailTextInsets.bottom - kTextLabelHeight, frame.size.width - kTextInsets.left - kTextInsets.right, kTextLabelHeight);
}

- (UIColor*)colorForPriority:(ZabbixTriggerPriority)priority
{
    switch (priority) {
        case ZabbixTriggerPriorityNotClassified: return [UIColor grayColor];
        case ZabbixTriggerPriorityInformation:   return [UIColor blueColor];
        case ZabbixTriggerPriorityWarning:       return [UIColor yellowColor];
        case ZabbixTriggerPriorityAverage:       return [UIColor orangeColor];
        case ZabbixTriggerPriorityHigh:          return [UIColor purpleColor];
        case ZabbixTriggerPriorityDisaster:      return [UIColor redColor];
        default: return [UIColor greenColor];
    }
}

@end
