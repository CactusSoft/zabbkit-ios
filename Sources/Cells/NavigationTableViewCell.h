//
//  NavigationTableViewCell.h
//  ZabbKit
//
//  Created by Andrey Kosykhin on 30.01.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+MoreColors.h"
#import "NavigationTableController_iPhone.h"

@interface NavigationTableViewCell : UITableViewCell

- (void)updateWithType:(ZabbKitPaneType)paneType;

@end
