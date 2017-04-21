//
//  ServerListViewControlleriPhone.m
//  Shtirlits
//
//  Created by bartle on 12/27/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ServerListViewController_iPhone.h"
#import "RootViewController_iPhone.h"
#import "EditServerViewController_iPhone.h"
#import "LoginView.h"
#import "UIView+Separator.h"
#import "ZabbixServer.h"
#import "ZabbKitApplicationSettings.h"
#import "LoggedUser.h"
#import "ServerTableViewCell.h"
#import "UIButton+BarButton.h"
#import "UIImage+Color.h"

static const NSInteger kIncorrectLoginCode = -32602;

@interface ServerListViewController_iPhone () <UITableViewDataSource, UITableViewDelegate, LoggedUserDelegate> {
    UITableView* _tableView;
    NSMutableArray* _items;
    ZabbixServer* _previousServer;
    ZabbixServer* _selectedServer;
    BOOL _isFailedLogin;
    UIAlertView* _loginAV;
}

@end


@implementation ServerListViewController_iPhone

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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = NSLocalizedString(@"Server List", nil);

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    _items = [[ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray mutableCopy];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.clipsToBounds = YES;
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addServerButtonDidPressed:)];
    [addBarButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    addBarButton.tintColor = [UIColor colorWithWhite:180.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem = addBarButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray = _items;
}

#pragma mark - Actions

- (void)addServerButtonDidPressed:(id)sender
{
    EditServerViewController_iPhone* editVC = [[EditServerViewController_iPhone alloc] init];
    editVC.items = _items;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)editServer:(id)sender
{
    UIButton* button = (UIButton *)sender;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    [self tableView:_tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    static NSString* serverCellIdentifier = @"ServerListCell";
    static NSString* defailtCellIdentifier = @"DefaultCell";

    if (indexPath.row < _items.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:serverCellIdentifier];
        if (cell == nil) {
            cell = [[ServerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serverCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            cell.userInteractionEnabled = YES;
            
            UIButton *editServerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [editServerButton setFrame:CGRectMake(0, 0, 30.0f, cell.bounds.size.height)];
            [editServerButton setImage:[UIImage imageNamed:kImgLoginRightArrow] forState:UIControlStateNormal];
            [editServerButton addTarget:self action:@selector(editServer:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = editServerButton;
        }
        
        ZabbixServer *server = [_items objectAtIndex:indexPath.row];
        cell.textLabel.text = server.name;
        cell.detailTextLabel.text = server.url;
        cell.accessoryView.tag = indexPath.row;
        
        if ([[LoggedUser sharedUser].currentServer isEqualToServer:server] && !_isFailedLogin) [tableView selectRowAtIndexPath:indexPath
                                                                                                                      animated:NO
                                                                                                                scrollPosition:UITableViewScrollPositionNone];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:defailtCellIdentifier];
        if (cell == nil) {
            cell = [[ServerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defailtCellIdentifier];
            cell.userInteractionEnabled = NO;
            cell.accessoryView = nil;
            cell.textLabel.text = NSLocalizedString(@"No servers", nil);
        }
        
        if (_items.count > 0) {
            cell.contentView.hidden = YES;
        } else {
            cell.contentView.hidden = NO;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < _items.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_items.count) {
            [_items removeObjectAtIndex:indexPath.row];
            [[ZabbKitApplicationSettings sharedApplicationSettings] setGraphFavorites:nil forServer:[LoggedUser sharedUser].currentServer];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    EditServerViewController_iPhone* editVC = [EditServerViewController_iPhone new];
    editVC.server = [_items objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _items.count) {
        _selectedServer = [_items objectAtIndex:indexPath.row];
        _previousServer = [LoggedUser sharedUser].currentServer;
        
        if ([_owner isKindOfClass:RootViewController_iPhone.class]) {
            //self pushed from root vc
            self.owner.loginView.uRLTextField.text = _selectedServer.url;
            [LoggedUser sharedUser].currentServer = _selectedServer;
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            if ([_selectedServer isEqualToServer:_previousServer] && !_isFailedLogin) {
                //go to overview VC
                if (_completion) _completion();
            } else {
                //new server selected. try login...
                _loginAV =[[UIAlertView alloc] initWithTitle:@"Login"
                                                             message:@"Enter Username & Password"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Login", nil];
                _loginAV.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                UITextField *username = [_loginAV textFieldAtIndex:0];
                username.text = [[LoggedUser sharedUser] nameUser];
                [_loginAV show];
            }
        }
    }
}

- (void)processFieldEntriesUsername:(NSString *)username password:(NSString *)password {

    NSString *noUsernameText = @"username";
    NSString *noPasswordText = @"password";
    NSString *errorText = @"No ";
    NSString *errorTextJoin = @" or ";
    NSString *errorTextEnding = @" entered";
    BOOL textError = NO;
    
    // Messaging nil will return 0, so these checks implicitly check for nil text.
    if (username.length == 0 || password.length == 0) {
        textError = YES;
    }
    
    if ([username length] == 0) {
        textError = YES;
        errorText = [errorText stringByAppendingString:noUsernameText];
    }
    
    if ([password length] == 0) {
        textError = YES;
        if ([username length] == 0) {
            errorText = [errorText stringByAppendingString:errorTextJoin];
        }
        errorText = [errorText stringByAppendingString:noPasswordText];
    }
    
    if (textError) {
        errorText = [errorText stringByAppendingString:errorTextEnding];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        [_tableView reloadData];
        return;
    }
    
    //Everything looks good; try to log in.
    
    [LoggedUser sharedUser].currentServer = _selectedServer;
    
    [self requestLoginWithUsername:username
                         urlString:[LoggedUser sharedUser].currentServer.url
                          password:password];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_loginAV == alertView) {
        if (buttonIndex == 1){
            UITextField *usernameTF = [alertView textFieldAtIndex:0];
            UITextField *passwordTF = [alertView textFieldAtIndex:1];
            [self processFieldEntriesUsername:usernameTF.text password:passwordTF.text];
        } else {
            //cancel to login
            [_tableView reloadData];
        }
    }
}

#pragma mark - Login User
- (void)requestLoginWithUsername:(NSString *)username urlString:(NSString *)url password:(NSString *)password
{
    [LoggedUser sharedUser].delegate = self;
    [[LoggedUser sharedUser] startLogin:username
                              urlString:url
                           userPassword:password];
}

#pragma mark LoggedUserDelegate
- (void)didSuccessfullyLogin{
    //go to overview VC
    if (_completion) _completion();
}

- (void)didFailLoginWithError:(NSError *)error
{
    if (error.code == -1012) {
        [self showCertificateError];
    } else {
        [self showErrorMessage:[error localizedDescription] withTitle:NSLocalizedString(@"Error", nil)];
        if (error.code == kIncorrectLoginCode){
            _isFailedLogin = YES;
            [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
        }
    }
}

- (void)showCertificateError
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Attention!", nil)
                          message:NSLocalizedString(@"The server's SSL certificate is untrusted. Would you like to continue?", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
    [alert show];
}

- (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
    [alert show];
}

@end
