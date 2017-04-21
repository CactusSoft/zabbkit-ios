//
//  HeaderMenu.m
//  Zabbkit
//
//  Created by Anna on 30.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "HeaderMenu.h"

#define kDefaultTabHeight 44.0
#define kDefaultTabOffset 140.0 // Offset of the second and further tabs' from left
#define kDefaultTabWidth 128.0

#define kDefaultIndicatorColor [UIColor colorWithRed:178.0/255.0 green:203.0/255.0 blue:57.0/255.0 alpha:0.75]
#define kDefaultTabsViewBackgroundColor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75]

@class TabElementView;

#pragma mark - TabElementView

@interface TabElementView : UIView
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor* defaultTextColor;
@property (nonatomic, strong) UIColor* selectedTextColor;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TabElementView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.label = [[UILabel alloc] initWithFrame:self.frame];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];

    if (self.selected) {
        [bezierPath setLineWidth:5.0];
        self.label.textColor = self.selectedTextColor;
    } else {
        [bezierPath setLineWidth:1.0];
        self.label.textColor = self.defaultTextColor;
    }
    
    [bezierPath moveToPoint:CGPointMake(0.0, rect.size.height - 1.0)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height - 1.0)];
    [self.indicatorColor setStroke];
    [bezierPath stroke];

    self.label.font = self.font;
}

@end

#pragma mark - HeaderMenu

@interface HeaderMenu () {
    NSInteger _tabCount;
    NSMutableArray *_tabs;
}

- (void)defaultSettings;
- (TabElementView *)tabViewAtIndex:(NSUInteger)index;
- (void)handleTapGesture:(id)sender;

@end

@implementation HeaderMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSettings];
    }
    return self;
}

#pragma mark - Private Methods

- (void)defaultSettings
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = kDefaultTabsViewBackgroundColor;
    self.indicatorColor = kDefaultIndicatorColor;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.tabHeight = kDefaultTabHeight;
    self.tabWidth = kDefaultTabWidth;
    self.tabOffset = kDefaultTabOffset;
}

- (void)reloadData
{
    for (UIView* tab in _tabs) {
        [tab removeFromSuperview];
    }
    [_tabs removeAllObjects];

    _tabCount = [self.menuDataSource numberOfTabsForHeaderMenu:self];
    
    // Populate arrays with [NSNull null];
    _tabs = [NSMutableArray arrayWithCapacity:_tabCount];
    for (int i = 0; i < _tabCount; i++) {
        [_tabs addObject:[NSNull null]];
    }
    
    CGFloat contentSizeWidth = 0;
    for (int i = 0; i < _tabCount; i++) {
        
        UIView *tabView = [self tabViewAtIndex:i];
        
        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        frame.size.width = self.tabWidth;
        tabView.frame = frame;
        
        [self addSubview:tabView];
        
        contentSizeWidth += tabView.frame.size.width;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];
    }
    
    self.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight);
}

- (TabElementView *)tabViewAtIndex:(NSUInteger)index {
    
    if (index >= _tabCount) {
        return nil;
    }
    
    TabElementView *tabView = [[TabElementView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tabWidth, self.tabHeight)];
    [tabView setClipsToBounds:YES];

    if ([[_tabs objectAtIndex:index] isEqual:[NSNull null]]) {
        
        if ([self.menuDataSource respondsToSelector:@selector(headerMenu:titleForItemAtIndex:)]) {
            
            NSString *titleForItem = [self.menuDataSource headerMenu:self titleForItemAtIndex:index];
            tabView.indicatorColor = self.indicatorColor;
            tabView.defaultTextColor = self.defaultTextColor;
            tabView.selectedTextColor = self.selectedTextColor;
            tabView.font = self.textFont;
            tabView.label.text = titleForItem;
            
        } else if ([self.menuDataSource respondsToSelector:@selector(headerMenu:viewForItemAtIndex:)])
        {
            UIView *viewForItem = [self.menuDataSource headerMenu:self viewForItemAtIndex:index];
            viewForItem.center = tabView.center;
            [tabView addSubview:viewForItem];
        }
        
        // Replace the null object with tabView
        [_tabs replaceObjectAtIndex:index withObject:tabView];
    }
    
    return [_tabs objectAtIndex:index];
}

#pragma mark - Actions

- (void)handleTapGesture:(id)sender {
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    UIView *tabView = tapGestureRecognizer.view;
    self.activeTabIndex = [_tabs indexOfObject:tabView];
}


#pragma mark - Setter/Getter

- (void)setActiveTabIndex:(NSUInteger)activeTabIndex {
    TabElementView *activeTabView;
    
    activeTabView = [self tabViewAtIndex:self.activeTabIndex];
    activeTabView.selected = NO;
    
    activeTabView = [self tabViewAtIndex:activeTabIndex];
    activeTabView.selected = YES;
    
    _activeTabIndex = activeTabIndex;
    
    if ([self.menuDelegate respondsToSelector:@selector(headerMenu:didSelectItemAtIndex:)]) {
        [self.menuDelegate headerMenu:self didSelectItemAtIndex:self.activeTabIndex];
    }
    
    [self scrollToActiveItem];
}

- (void)scrollToActiveItem
{
    UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
    CGRect frame = tabView.frame;
    frame.origin.x -= self.tabOffset;
    frame.size.width = self.frame.size.width;
    [self scrollRectToVisible:frame animated:YES];
}

@end
