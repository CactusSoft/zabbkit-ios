//
//  EditServerViewControlleriPhoneViewController.h
//  Shtirlits
//
//  Created by bartle on 12/27/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class ZabbixServer;

@interface EditServerViewController_iPhone : BaseViewController

@property(nonatomic, strong) UITextField *nameTextField;
@property(nonatomic, strong) UITextField *urlTextField;
@property(nonatomic, strong) UISwitch *trustCerteficateSwitch;
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) ZabbixServer *server;

@end
