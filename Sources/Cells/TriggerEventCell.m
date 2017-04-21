//
//  TriggerEventCell.m
//  ZabbKit
//
//  Created by Alexey Dozortsev on 18.09.13.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "TriggerEventCell.h"
#import "UIView+Separator.h"
#import "NSString+AdditionsMethods.h"
#import "UIImage+Color.h"
#import "ZabbixTrigger.h"
#import "ZabbixEvent.h"

static CGRect const kPriorityRect = {{24.0f, 8.0f}, {4.0f, 32.0f}};
static CGFloat const kLeftOffset = 32.0;
static CGFloat const kRightOffset = 24.0;
static CGFloat const kLabelHeight = 20.0;
static CGFloat const kLabelOriginY = (48 - kLabelHeight) * 0.5f;

@interface TriggerEventCell () {
    UIView* _priorityView;
}

- (UIColor*)colorForPriority:(ZabbixTriggerPriority)priority;

@end


@implementation TriggerEventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        
        _priorityView = [[UIView alloc] initWithFrame:kPriorityRect];
        [self.contentView addSubview:_priorityView];
        
        UIImage* colorImage = [UIImage imageWithColor:[UIColor colorWithWhite:106.0f/255.0f alpha:1.0f]];
        [self.contentView addBottomSeparatorLeft:16.0f right:16.0f height:1.0f image:colorImage highlightedImage:colorImage];
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _priorityView.frame = kPriorityRect;
    CGSize size = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGRect frame = CGRectMake(self.contentView.bounds.size.width - size.width - kRightOffset, kLabelOriginY, size.width, kLabelHeight);
    self.detailTextLabel.frame = frame;
    self.textLabel.frame = CGRectMake(kLeftOffset, kLabelOriginY, frame.origin.x - kLeftOffset - 5, kLabelHeight);
}


- (void)updateWithTrigger:(ZabbixTrigger*)trigger event:(ZabbixEvent*)event
{
    if (!event.eventid) {
        _priorityView.backgroundColor = [self colorForPriority:ZabbixTriggerPriorityNotClassified];
        self.textLabel.text = @"";
        self.detailTextLabel.text = @"";
    } else {
        if (event.value == 1) {
            _priorityView.backgroundColor = [self colorForPriority:trigger.priority];
        } else {
            _priorityView.backgroundColor = [UIColor greenColor];
        }
        self.textLabel.text = [NSString stringDateFromTimeStamp:event.clock withDateFormat:@"dd MMM yyyy 'at' h:mm a"];
        self.detailTextLabel.text = [NSString stringTimeFormattedShort:event.duration];
    }
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
