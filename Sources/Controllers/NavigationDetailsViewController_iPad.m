//
//  NavigationDetailsViewController.m
//  Zabbkit
//
//  Created by Anna on 10.10.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NavigationDetailsViewController_iPad.h"

@interface NavigationDetailsViewController_iPad ()

@end

@implementation NavigationDetailsViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationPaneBarButtonItem:(UIBarButtonItem *)navigationPaneBarButtonItem
{
    UIViewController* vc = self.viewControllers.lastObject;

    if (navigationPaneBarButtonItem != _navigationPaneBarButtonItem) {
        if (navigationPaneBarButtonItem){
            vc.navigationItem.leftBarButtonItem = navigationPaneBarButtonItem;
        }
        else{
            vc.navigationItem.leftBarButtonItem = nil;
        }
        
        _navigationPaneBarButtonItem = navigationPaneBarButtonItem;
    }
}

@end
