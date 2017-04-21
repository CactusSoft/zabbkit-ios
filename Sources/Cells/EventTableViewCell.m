//
//  EventTableViewCell.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 04.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "EventTableViewCell.h"
#import "ZabbixTrigger.h"
#import "ZabbixEvent.h"
#import "UIView+Separator.h"
#import "NSString+AdditionsMethods.h"
#import "UILabel+SH_UILabel.h"
#import "UIImage+Color.h"

static CGRect const kPriorityRect = {{24.0f, 13.0f}, {4.0f, 40.0f}};
static UIEdgeInsets const kDescriptionInsets = {13.0f, 34.0f, 31.0f, 18.0f};
static CGRect const kDateRectBottom = {{34.0f, 28.0f}, {250.0f, 16.0f}};
static CGRect const kDurationRectBottom = {{100.0f, 28.0f}, {83.0f, 16.0}};
static CGFloat const kDescriptionFontSize = 17;
static CGFloat const kTimeFontSize = 14;
static NSString *const kDescriptionFontName = @"Helvetica";
static NSString *const kTimeFontName = @"Helvetica";

@interface EventTableViewCell () {
    UIView*  _priorityView;
    UILabel* _descriptionLabel;
    UILabel* _timeCreatedLabel;
    UILabel* _durationLabel;
}

- (UIColor*)colorForPriority:(ZabbixTriggerPriority)priority;

@end


@implementation EventTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
        
        _priorityView = [[UIView alloc] initWithFrame:kPriorityRect];
        _priorityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_priorityView];
        
        _descriptionLabel = [UILabel sh_labelWithFont:[UIFont fontWithName:kDescriptionFontName size:kDescriptionFontSize] textColor:[UIColor whiteColor]];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        _descriptionLabel.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:_descriptionLabel];
        
        _timeCreatedLabel = [UILabel sh_labelWithFont:[UIFont fontWithName:kTimeFontName size:kTimeFontSize] textColor:[UIColor colorWithWhite:119.0/255.0 alpha:1.0f]];
        _timeCreatedLabel.numberOfLines = 1;
        _timeCreatedLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        _descriptionLabel.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:_timeCreatedLabel];
        
        _durationLabel = [UILabel sh_labelWithFont:[UIFont fontWithName:kTimeFontName size:kTimeFontSize] textColor:[UIColor colorWithWhite:119.0/255.0 alpha:1.0f]];
        _durationLabel.numberOfLines = 1;
        _durationLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        _durationLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:_durationLabel];
        
        if ([_durationLabel respondsToSelector:@selector(setMinimumFontSize:)]) {
            [_durationLabel setMinimumFontSize:8];
            [_timeCreatedLabel setMinimumFontSize:8];
        }
        
        if ([_durationLabel respondsToSelector:@selector(setMinimumScaleFactor:)]) {
            [_durationLabel setMinimumScaleFactor:0.5];
            [_timeCreatedLabel setMinimumScaleFactor:0.5];
        }
        
        UIImage* colorImage = [UIImage imageWithColor:[UIColor colorWithWhite:106.0f/255.0f alpha:1.0f]];
        [self.contentView addBottomSeparatorLeft:16.0f right:16.0f height:1.0f image:colorImage highlightedImage:colorImage];
    }
    return self;
}

- (void)updateWithTrigger:(ZabbixTrigger*)trigger event:(ZabbixEvent*)event
{
    NSString* clock = [NSString stringDateFromTimeStamp:event.clock withDateFormat:@"dd MMM yyyy 'at' h:mm a"];
    _timeCreatedLabel.text = clock;
    _durationLabel.text = [NSString stringTimeFormatted:event.duration];
    _descriptionLabel.text = trigger.triggerDescription;
    if (event.value == 1) {
        _priorityView.backgroundColor = [self colorForPriority:trigger.priority];
    } else {
        _priorityView.backgroundColor = [UIColor greenColor];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    
    _priorityView.frame = kPriorityRect;
    
    _descriptionLabel.frame = CGRectMake(kDescriptionInsets.left,
                                         kDescriptionInsets.top,
                                         contentRect.size.width - kDescriptionInsets.left - kDescriptionInsets.right,
                                         contentRect.size.height - kDescriptionInsets.top - kDescriptionInsets.bottom);
    
    _timeCreatedLabel.frame = CGRectMake(kDateRectBottom.origin.x,
                                         contentRect.size.height - kDateRectBottom.origin.y,
                                         kDateRectBottom.size.width,
                                         kDateRectBottom.size.height);
    
    _durationLabel.frame = CGRectMake(contentRect.size.width - kDurationRectBottom.origin.x,
                                      contentRect.size.height - kDurationRectBottom.origin.y,
                                      kDurationRectBottom.size.width,
                                      kDurationRectBottom.size.height);
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

+ (CGFloat)heightForEvent:(ZabbixEvent*)event trigger:(ZabbixTrigger*)trigger withWidth:(CGFloat)width
{
    CGFloat descriptionWidth = width - kDescriptionInsets.left - kDescriptionInsets.right;
    NSString* description = trigger.triggerDescription;
    if (description.length == 0) {
        description = NSLocalizedString(@"empty", nil);
    }
    CGSize maximumSize = CGSizeMake(descriptionWidth, CGFLOAT_MAX);
    static UIFont* font = nil;
    if (font == nil) {
        font = [UIFont fontWithName:kDescriptionFontName size:kDescriptionFontSize];
    }
    CGSize size = [description sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height;
    height += kDescriptionInsets.top + kDescriptionInsets.bottom;
    return height;
}

@end
