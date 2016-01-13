//
//  SimiThemeWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/13/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiThemeWorker.h"
#import <SimiCartBundle/SCOrderViewController.h>

@implementation SimiThemeWorker
- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedRootController" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillSwitchLanguage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderWithNewCustomer:) name:@"DidPlaceOrder-After" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromServer:) name:@"DidRecieveNotificationFromServer" object:nil];
    }
    return self;
}

+ (SimiThemeWorker *)sharedInstance{
    static SimiThemeWorker *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SimiThemeWorker alloc] init];
    });
    return _sharedInstance;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"InitializedRootController"]) {
        self.rootController = noti.object;
        self.rootController.tabBar.hidden = YES;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            _navigationBar = [SCNavigationBar_Theme01 sharedInstance];
            [_navigationBar cartController];
            [[SimiGlobalVar sharedInstance] addObserver:[_navigationBar cartController] forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
            SimiNavigationController *homeNavi = [[SimiNavigationController alloc] init];
            SCHomeViewController_Theme01 *homeController = [[SCHomeViewController_Theme01 alloc] init];
            [homeNavi setViewControllers:@[homeController]];
            [homeNavi.navigationBar setBarTintColor:THEME_COLOR];
            [homeNavi setTitle:SCLocalizedString(@"Home")];
            
            self.rootController.viewControllers = @[homeNavi];
        }else
        {
            _navigationBarPad = [SCNavigationBarPad_Theme01 sharedInstance];
            [_navigationBarPad cartViewController];
            [[SimiGlobalVar sharedInstance] addObserver:[_navigationBarPad cartViewController] forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
            
            SimiNavigationController *homeNavi = [[SimiNavigationController alloc] init];
            SCHomeViewControllerPad_Theme01 *homeController = [[SCHomeViewControllerPad_Theme01 alloc] init];
            [homeNavi setViewControllers:@[homeController]];
            [homeNavi.navigationBar setBarTintColor:THEME_COLOR];
            [homeNavi setTitle:SCLocalizedString(@"Home")];
            self.rootController.viewControllers = @[homeNavi];
        }
        
        if (SIMI_SYSTEM_IOS >= 7) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [[UINavigationBar appearance] setBarTintColor:THEME_COLOR];
            [[UIActivityIndicatorView appearance] setColor:THEME_COLOR];
            [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        }
    }
}

- (void)didPlaceOrderWithNewCustomer:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidPlaceOrder-After"]) {
        SCOrderViewController *orderViewController = [noti.userInfo valueForKey:@"controller"];
        if (orderViewController.isNewCustomer) {
            SimiCustomerModel *customer = [[SimiCustomerModel alloc]init];
            NSString *stringUserEmail = [orderViewController.addressNewCustomerModel valueForKey:@"email"];
            NSString *stringPassWord = [orderViewController.addressNewCustomerModel valueForKey:@"customer_password"];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:customer];
            [customer loginWithUserMail:stringUserEmail password:stringPassWord];
        }
    }
}

- (void)didLogin:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushLoginNormal" object:nil];
    }
}

#pragma mark Did Receive Notification From Server
- (void)didReceiveNotificationFromServer:(NSNotification*)noti
{
    UINavigationController *recentNaviCon = (UINavigationController *)self.rootController.selectedViewController;
    NSString *stringNotiType = [[noti.object valueForKey:@"aps"] valueForKey:@"type"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([stringNotiType isEqualToString:@"2"]) {
            if ([[[noti.object valueForKey:@"aps"] valueForKey:@"has_child"]boolValue]) {
                SCCategoryViewController* nextController = [SCCategoryViewController new];
                nextController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.navigationItem.title = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"];
                [recentNaviCon pushViewController:nextController animated:YES];
            }else
            {
                SCGridViewController_Theme01 *nextController = [[SCGridViewController_Theme01 alloc]init];
                nextController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
                nextController.navigationItem.title = [[[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"] uppercaseString];
                [recentNaviCon pushViewController:nextController animated:YES];
            }
        }else if([stringNotiType isEqualToString:@"1"])
        {
            SCProductViewController_Theme01 *nextController = [SCProductViewController_Theme01 new];
            [nextController setProductId:[[noti.object valueForKey:@"aps"] valueForKey:@"productID"]];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"3"])
        {
            SCWebViewController *nextController = [[SCWebViewController alloc] init];
            [nextController setUrlPath:[[noti.object valueForKey:@"aps"] valueForKey:@"url"]];
            nextController.title = [[noti.object valueForKey:@"aps"] valueForKey:@"title"];
            [recentNaviCon pushViewController:nextController animated:YES];
        }
    }else
    {
        if ([stringNotiType isEqualToString:@"1"])
        {
            SCProductViewControllerPad_Theme01 *nextController = [SCProductViewControllerPad_Theme01 new];
            nextController.productId = [[noti.object valueForKey:@"aps"] valueForKey:@"productID"];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"2"])
        {
            SCGridViewControllerPad_Theme01 *gridViewController = [[SCGridViewControllerPad_Theme01 alloc]init];
            gridViewController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
            gridViewController.isCategory = YES;
            gridViewController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
            [recentNaviCon pushViewController:gridViewController animated:YES];
        }else if([stringNotiType isEqualToString:@"3"])
        {
            SCWebViewController *nextController = [[SCWebViewController alloc] init];
            [nextController setUrlPath:[[noti.object valueForKey:@"aps"] valueForKey:@"url"]];
            nextController.title = [[noti.object valueForKey:@"aps"] valueForKey:@"title"];
            [recentNaviCon pushViewController:nextController animated:YES];
        }
    }
}
@end
