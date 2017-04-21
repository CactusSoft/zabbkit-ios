//
//  NavigationBarButtonItem.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 18.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NavigationBarButtonItemTypeBack,
    NavigationBarButtonItemTypeLeft,
    NavigationBarButtonItemTypeRight
} NavigationBarButtonItemType;

@interface NavigationBarButtonItem : UIBarButtonItem {
    UIButton *actionButton_;
}
@property(nonatomic, strong) UIButton *actionButton;

- (void)setTypeButton:(NavigationBarButtonItemType)typeButton;

@end
