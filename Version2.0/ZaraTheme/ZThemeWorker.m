//
//  ZThemeWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZThemeWorker.h"

#import <SimiCartBundle/SCOrderViewController.h>

#import "ZThemeProductListViewController.h"
#import "ZThemeProductListViewControllerPad.h"
#import "ZThemeProductViewController.h"
#import "ZThemeProductViewControllerPad.h"
#import "ZThemeCategoryViewController.h"

@implementation ZThemeWorker

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

+ (ZThemeWorker *)sharedInstance{
    static ZThemeWorker *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZThemeWorker alloc] init];
    });
    return _sharedInstance;
}

- (void)didReceiveNotification:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"InitializedRootController"]) {
        self.rootController = noti.object;
        self.rootController.tabBar.hidden = YES;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            _navigationBar = [ZThemeNavigationBar sharedInstance];
            [_navigationBar cartController];
            [[SimiGlobalVar sharedInstance] addObserver:[_navigationBar cartController] forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
            SimiNavigationController *homeNavi = [[SimiNavigationController alloc] init];
            ZThemeHomeViewController *homeController = [[ZThemeHomeViewController alloc] init];
            [homeNavi setViewControllers:@[homeController]];
            [homeNavi.navigationBar setBarTintColor:THEME_COLOR];
            self.rootController.viewControllers = @[homeNavi];
        }else
        {
            _navigationBarPad = [ZThemeNavigationBarPad sharedInstance];
            [_navigationBarPad cartViewController];
            [[SimiGlobalVar sharedInstance] addObserver:[_navigationBarPad cartViewController] forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
            SimiNavigationController *homeNavi = [[SimiNavigationController alloc] init];
            ZThemeHomeViewControllerPad *homeController = [[ZThemeHomeViewControllerPad alloc] init];
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
                ZThemeCategoryViewController* nextController = [ZThemeCategoryViewController new];
                nextController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.navigationItem.title = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"];
                [recentNaviCon pushViewController:nextController animated:YES];
            }else
            {
                ZThemeProductListViewController *nextController = [[ZThemeProductListViewController alloc]init];
                nextController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromCategory;
                nextController.navigationItem.title = [[[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"] uppercaseString];
                [recentNaviCon pushViewController:nextController animated:YES];
            }
        }else if([stringNotiType isEqualToString:@"1"])
        {
            ZThemeProductViewController *nextController = [ZThemeProductViewController new];
            nextController.firstProductID = [[noti.object valueForKey:@"aps"] valueForKey:@"productID"];
            nextController.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[nextController.firstProductID]];
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
            ZThemeProductViewControllerPad *nextController = [ZThemeProductViewControllerPad new];
            nextController.firstProductID = [[noti.object valueForKey:@"aps"] valueForKey:@"productID"];
            nextController.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[nextController.firstProductID]];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"2"])
        {
            ZThemeProductListViewControllerPad *gridViewController = [[ZThemeProductListViewControllerPad alloc]init];
            gridViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromCategory;
            gridViewController.isCategory = YES;
            gridViewController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
            gridViewController.categoryName = [[[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"] uppercaseString];
            gridViewController.navigationItem.title = gridViewController.categoryName;
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
