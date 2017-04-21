//
//  HeaderMenu.m
//  Zabbkit
//
//  Created by Anna on 30.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HeaderMenu;

#pragma mark dataSource
@protocol HeaderMenuDataSource <NSObject>

- (NSUInteger)numberOfTabsForHeaderMenu:(HeaderMenu *)headerMenu;

@optional

- (NSString *)headerMenu:(HeaderMenu *)headerMenu titleForItemAtIndex:(NSUInteger)index;

- (UIView *)headerMenu:(HeaderMenu *)headerMenu viewForItemAtIndex:(NSUInteger)index;

@end

#pragma mark delegate
@protocol HeaderMenuDelegate <NSObject>

@optional

- (void)headerMenu:(HeaderMenu *)headerMenu didSelectItemAtIndex:(NSUInteger)index;

@end

@interface HeaderMenu : UIScrollView
@property (nonatomic, weak) id <HeaderMenuDataSource> menuDataSource;
@property (nonatomic, weak) id <HeaderMenuDelegate> menuDelegate;

@property (nonatomic, strong) UIColor* indicatorColor;
@property (nonatomic, strong) UIColor* defaultTextColor;
@property (nonatomic, strong) UIColor* selectedTextColor;
@property (nonatomic, strong) UIFont* textFont;

@property (nonatomic, assign) CGFloat tabWidth;
@property (nonatomic, assign) CGFloat tabHeight;
@property (nonatomic, assign) CGFloat tabOffset;

@property (nonatomic, assign) NSUInteger activeTabIndex;

- (void)reloadData;

@end
