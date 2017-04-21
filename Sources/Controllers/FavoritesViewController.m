//
//  FavoritesViewController.m
//  Zabbkit
//
//  Created by Anna on 17.10.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ZabbKitApplicationSettings.h"
#import "ZabbixGraph.h"
#import "LoggedUser.h"
#import "ServerTableViewCell.h"
#import "GraphViewControlleriPhone.h"

@interface FavoritesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_graphs;
}

@end

@implementation FavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Favorites", nil);
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZabbixServer *server = [LoggedUser sharedUser].currentServer;
    _graphs = [[ZabbKitApplicationSettings sharedApplicationSettings] graphFavoritesForServer:server].mutableCopy;
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ZabbixServer *server = [LoggedUser sharedUser].currentServer;
    [[ZabbKitApplicationSettings sharedApplicationSettings] setGraphFavorites:_graphs forServer:server];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _graphs.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerTableViewCell *cell  = nil;
    static NSString* favoriteCellIdentifier = @"FavoriteCell";
    static NSString* defaultCellIdentifier = @"DefaultCell";
    
    if (indexPath.row < _graphs.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:favoriteCellIdentifier];
        if (cell == nil) {
            cell = [[ServerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:favoriteCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        ZabbixGraph *graph = [_graphs objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",graph.graphName,NSLocalizedString(@"for the last", nil),[graph stringValueForRange:graph.range]];
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
        if (cell == nil) {
            cell = [[ServerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier];
            cell.userInteractionEnabled = NO;
            cell.accessoryView = nil;
            cell.textLabel.text = NSLocalizedString(@"No graphs", nil);
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            [cell sizeToFit];
        }
        
        if (_graphs.count > 0) {
            cell.contentView.hidden = YES;
        } else {
            cell.contentView.hidden = NO;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < _graphs.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_graphs.count) {
            [_graphs removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _graphs.count) {
        return 88;
    }
    return 44;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _graphs.count) {
        ZabbixGraph *graph = [_graphs objectAtIndex:indexPath.row];
        GraphViewControlleriPhone *graphViewController = [[GraphViewControlleriPhone alloc] initWithGraph:graph];
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:graphViewController animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
}



@end
