//
//  DataTableViewCell.h
//  Zabbkit
//
//  Created by Alexey Dozortsev on 19.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZabbixItem;

@interface DataTableViewCell : UITableViewCell

- (void) updateWithItem:(ZabbixItem*)item;

@end
