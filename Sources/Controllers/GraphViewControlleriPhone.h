//
//  GraphViewController.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/14/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderMenu.h"
#import "BaseViewController.h"

@class ZabbixGraph;

@interface GraphViewControlleriPhone : BaseViewController <HeaderMenuDataSource, HeaderMenuDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property(strong, nonatomic) ZabbixGraph *graph;

- (id)initWithGraph:(ZabbixGraph*)graph;

- (void)onBack:(id)sender;

- (void)onPreviousDate:(id)sender;

- (void)onNextDate:(id)sender;

- (void)onShare:(id)sender;

@end
