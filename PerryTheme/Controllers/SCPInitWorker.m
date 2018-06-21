//
//  SCPInitWorker.m
//  SimiCartPluginFW
//
//  Created by Liam on 4/18/18.
//  Copyright © 2018 Trueplus. All rights reserved.
//

#import <SimiCartBundle/InitWorker.h>
#import "SCPInitWorker.h"
#import "SCPGlobalVars.h"
#import "SCPNavigationBar.h"
#import "SCPHomeViewController.h"
#import "SCPCategoryViewController.h"
#import "SCPSearchViewController.h"
#import "SCPLeftMenuViewController.h"
#import "SCPPadOrderViewController.h"
#import "SCPPadProductViewController.h"
#import "SCPPadThankYouPageViewController.h"
#import <SimiCartBundle/SimiOrderHistoryModel.h>
#import "SCPOrderDetailViewController.h"

@implementation SCPInitWorker{
    SCPLeftMenuViewController *leftMenuViewController;
}

- (id)init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedRootController:) name:Simi_InitializedRootController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginConfigureNavigationBar:) name:Simi_BeginConfigureNavigationBar object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedMenu:) name:Simi_MainViewController_InitializedMenu object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initializedMenuSize:) name:Simi_MainViewController_InitializedMenuSize object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openProduct:) name:SIMI_SHOWPRODUCTDETAIL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openOrderReview:) name:SIMI_SHOWORDERREVIEWSCREEN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openThankyouPage:) name:SIMI_SHOWTHANKYOUPAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openOrderDetail:) name:SIMI_SHOWORDERHISTORYDETAILSCREEN object:nil];
        if (SCP_GLOBALVARS.wishlistPluginAllow) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWishlist:) name:SCCartController_CompletedChangeCustomerState object:nil];
        }
        GLOBALVAR.isUseDiscountMinus = YES;
    }
    return self;
}
- (void)openOrderDetail:(NSNotification *)noti{
    UINavigationController *navi = [noti.userInfo objectForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    SimiOrderHistoryModel *orderHistoryModel = [noti.userInfo valueForKey:KEYEVENT.ORDERHISTORYDETAILVIEWCONTROLLER.order_history_model];
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
    NSString *orderId = [noti.userInfo valueForKey:KEYEVENT.ORDERHISTORYDETAILVIEWCONTROLLER.order_id];
    if (PADDEVICE) {
        SCPOrderDetailViewController *orderDetailViewController = [SCPOrderDetailViewController new];
        orderDetailViewController.orderId = orderId;
        orderDetailViewController.order = orderHistoryModel;
        UINavigationController *orderNavi = [[UINavigationController alloc]initWithRootViewController:orderDetailViewController];
        orderNavi.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = orderNavi.popoverPresentationController;
        popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        popover.sourceView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
        popover.permittedArrowDirections = 0;
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:orderNavi animated:YES completion:nil];
    }else{
        SCPOrderDetailViewController *orderDetailViewController = [SCPOrderDetailViewController new];
        orderDetailViewController.orderId = orderId;
        orderDetailViewController.order = orderHistoryModel;
        [navi pushViewController:orderDetailViewController animated:YES];
    }
}
- (void)openOrderReview:(NSNotification *)noti{
    SCPOrderViewController *orderViewController = [SCPOrderViewController new];
    if(PADDEVICE){
        orderViewController = [SCPPadOrderViewController new];
    }
    orderViewController.billingAddress = [noti.userInfo objectForKey:KEYEVENT.ORDERVIEWCONTROLLER.billing_address];
    orderViewController.shippingAddress = [noti.userInfo objectForKey:KEYEVENT.ORDERVIEWCONTROLLER.shipping_address];
    orderViewController.cart = GLOBALVAR.cart;
    orderViewController.checkOutType = [[noti.userInfo valueForKey:KEYEVENT.ORDERVIEWCONTROLLER.checkOut_type]integerValue];
    if (orderViewController.checkOutType == CheckOutTypeNewCustomer) {
        orderViewController.addressNewCustomerModel = [noti.userInfo objectForKey:KEYEVENT.ORDERVIEWCONTROLLER.billing_address];
    }
    UINavigationController *navi = [noti.userInfo objectForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    [navi pushViewController:orderViewController animated:YES];
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
}
- (void)openThankyouPage:(NSNotification *)noti{
    SCAppController *appController = noti.object;
    UINavigationController *navi = [noti.userInfo objectForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    SimiOrderModel *orderModel = [noti.userInfo objectForKey:KEYEVENT.THANKYOUPAGEVIEWCONTROLLER.order_model];
    
    SCPThankYouPageViewController *thankVC = [[SCPThankYouPageViewController alloc] init];
    thankVC.order = orderModel;
    if([noti.userInfo objectForKey:KEYEVENT.THANKYOUPAGEVIEWCONTROLLER.checkout_type]){
        CheckOutType checkoutType = [[noti.userInfo objectForKey:KEYEVENT.THANKYOUPAGEVIEWCONTROLLER.checkout_type] integerValue];
        if(checkoutType == CheckOutTypeGuest){
            thankVC.isGuest = YES;
        }
    }
    appController.isDiscontinue = YES;
    if (PHONEDEVICE) {
        [navi pushViewController:thankVC animated:YES];
    }else{
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:thankVC];
        navi.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = navi.popoverPresentationController;
        popover.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        popover.sourceView = navi.view;
        popover.permittedArrowDirections = 0;
        [navi presentViewController:navi animated:YES completion:nil];
    }
}
- (void)initializedMenu:(NSNotification *)noti{
    SCMainViewController *mainVC = noti.object;
    mainVC.isDiscontinue = YES;
    leftMenuViewController = [SCPLeftMenuViewController new];
    float width = 3*SCREEN_WIDTH/4;
    if(PADDEVICE){
        width = 328;
    }
    [mainVC setLeftViewEnabledWithWidth:width
                    presentationStyle:LGSideMenuPresentationStyleSlideAbove
                 alwaysVisibleOptions:LGSideMenuAlwaysVisibleOnNone];
    mainVC.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnAll;
    [mainVC.leftView addSubview:leftMenuViewController.view];
}

- (void)initializedMenuSize:(NSNotification*)noti{
    NSValue *sizeValue = [noti.userInfo valueForKey:@"size"];
    CGSize size = sizeValue.CGSizeValue;
    leftMenuViewController.view.frame = CGRectMake(0.f , 0.f, size.width, size.height);
}

- (void)initializedRootController:(NSNotification *)noti{
//    if([GLOBALVAR.storeView.data objectForKey:@"perry_theme"]){
    if(YES){
        [self setupThemeColors];
        InitWorker *initWorker = noti.object;
        initWorker.isDiscontinue = YES;
        //Init the root view
        [[UINavigationBar appearance] setBarTintColor:SCP_MENU_BACKGROUND_COLOR];
        [[UINavigationBar appearance] setTintColor:SCP_TITLE_COLOR];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:SCP_TITLE_COLOR, NSForegroundColorAttributeName, nil]];
        [[UITabBar appearance] setBarTintColor:SCP_MENU_BACKGROUND_COLOR];
        
        NSMutableArray *navigationControllers = [NSMutableArray new];
        UINavigationController *homeNavi = [[UINavigationController alloc] init];
        homeNavi.viewControllers = @[[SCPHomeViewController new]];
        homeNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Home") image:[[[UIImage imageNamed:@"scp_ic_home_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_home_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        homeNavi.sortOrder = 10;
        [navigationControllers addObject:homeNavi];
        SCP_GLOBALVARS.shouldSelectNavigationController = homeNavi;
        
        UINavigationController *categoryNavi = [[UINavigationController alloc] init];
        categoryNavi.viewControllers = @[[SCPCategoryViewController new]];
        categoryNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Category") image:[[[UIImage imageNamed:@"scp_ic_category_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_category_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        categoryNavi.sortOrder = 20;
        [navigationControllers addObject:categoryNavi];
        
        UINavigationController *searchNavi = [[UINavigationController alloc] init];
        searchNavi.viewControllers = @[[SCPSearchViewController new]];
        searchNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Search") image:[[[UIImage imageNamed:@"scp_ic_search_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_search_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        searchNavi.sortOrder = 30;
        [navigationControllers addObject:searchNavi];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCP_EndCreateTabbarItems" object:navigationControllers];
        [navigationControllers sortUsingComparator:^NSComparisonResult(UINavigationController *firstNavi, UINavigationController *secondNavi) {
            if (secondNavi.sortOrder < firstNavi.sortOrder) {
                return NSOrderedDescending;
            }
            return NSOrderedAscending;
        }];
    
        UINavigationController *wishlistNavi = [[UINavigationController alloc] init];
        wishlistNavi.viewControllers = @[[SCPSearchViewController new]];
        wishlistNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Wishlist") image:[[[UIImage imageNamed:@"scp_ic_wishlist_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_wishlist_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        wishlistNavi.sortOrder = 40;
        [navigationControllers addObject:wishlistNavi];
    
        UINavigationController *storeLocatorNavi = [[UINavigationController alloc] init];
        storeLocatorNavi.viewControllers = @[[SCPSearchViewController new]];
        storeLocatorNavi.tabBarItem = [[UITabBarItem alloc]initWithTitle:SCLocalizedString(@"Stores") image:[[[UIImage imageNamed:@"scp_ic_storelocator_tabbar"]imageWithColor:SCP_ICON_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[[UIImage imageNamed:@"scp_ic_storelocator_tabbar"]imageWithColor:SCP_ICON_HIGHLIGHT_COLOR]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        storeLocatorNavi.sortOrder = 50;
        [navigationControllers addObject:storeLocatorNavi];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCP_EndCreateTabbarItems" object:navigationControllers];
        [navigationControllers sortUsingComparator:^NSComparisonResult(UINavigationController *firstNavi, UINavigationController *secondNavi) {
            if (secondNavi.sortOrder < firstNavi.sortOrder) {
                return NSOrderedDescending;
            }
            return NSOrderedAscending;
        }];
        for (UINavigationController *navigationController in navigationControllers) {
            SCPNavigationBar *navigationBar = [SCPNavigationBar new];
            navigationController.simiObjectIdentifier = navigationBar;
        }
        SCPNavigationBar *navigationBar = (SCPNavigationBar*)homeNavi.simiObjectIdentifier;
        navigationBar.cartController = [SCCartController new];
        [SCAppController sharedInstance].navigationBarPhone = navigationBar;
        if(PADDEVICE){
            [SCAppController sharedInstance].navigationBarPad = navigationBar;
        }
        initWorker.rootController.viewControllers = navigationControllers;
        initWorker.rootController.delegate = self;
        [SCPGlobalVars sharedInstance].rootController = initWorker.rootController;
        for (UITabBarItem *tabbarItem in initWorker.rootController.tabBar.items) {
            [tabbarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SCP_ICON_COLOR} forState:UIControlStateNormal];
            [tabbarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SCP_ICON_HIGHLIGHT_COLOR} forState:UIControlStateHighlighted];
        }
        GLOBALVAR.usePriceInLine = YES;
        [self checkPluginsWishlistAllow];
        if (GLOBALVAR.isLogin && SCP_GLOBALVARS.wishlistPluginAllow) {
            [self updateWishlist:nil];
        }
    }
}

- (void)setupThemeColors{
    SCP_GLOBALVARS.themeConfig = [[SCPThemeConfigModel alloc] initWithModelData:@{}];
}

- (void)beginConfigureNavigationBar:(NSNotification*)noti{
    SimiViewController *viewController = noti.object;
    viewController.isDiscontinue = YES;
}

- (void)checkPluginsWishlistAllow{
    if (NSClassFromString(@"SCWishlistInitWorker")) {
        for (NSDictionary *pluginInfo in GLOBALVAR.activePlugins) {
            if ([[pluginInfo valueForKey:@"sku"] isEqualToString:@"simi_appwishlist_40"]) {
                SCP_GLOBALVARS.wishlistPluginAllow = YES;
                break;
            }
        }
    }
}

- (void)updateWishlist:(NSNotification*)noti{
    if (GLOBALVAR.isLogin) {
        SCPWishlistModelCollection *wishlistModelCollection = [SCPWishlistModelCollection new];
        [wishlistModelCollection getWishlistItemsWithParams:@{@"offset":@"0",@"limit":@"1000"}];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetWishlistItems:) name:DidGetWishlistItems object:wishlistModelCollection];
    }else{
        [SCP_GLOBALVARS.wishListModelCollection removeAllObjects];
    }
}

- (void)didGetWishlistItems:(NSNotification*)noti{
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:responderKey];
    if (responder.status == SUCCESS) {
        SCP_GLOBALVARS.wishListModelCollection = noti.object;
    }else{
        [SCP_GLOBALVARS.wishListModelCollection removeAllObjects];
    }
}

#pragma mark Tabbar Controller Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    SCP_GLOBALVARS.shouldSelectNavigationController = (UINavigationController*)viewController;
    [SCAppController sharedInstance].navigationBarPhone = (SCPNavigationBar*)viewController.simiObjectIdentifier;
    if(PADDEVICE){
        [SCAppController sharedInstance].navigationBarPad = (SCPNavigationBar*)viewController.simiObjectIdentifier;
    }
    return YES;
}
- (void)openProduct:(NSNotification *)noti{
    UINavigationController *navi = [noti.userInfo objectForKey:KEYEVENT.APPCONTROLLER.navigation_controller];
    NSString *productId = [noti.userInfo objectForKey:KEYEVENT.PRODUCTVIEWCONTROLLER.product_id];
    SCPProductViewController *productVC = [SCPProductViewController new];
    if (PADDEVICE) {
        productVC = [SCPPadProductViewController new];
    }
    productVC.productId = productId;
    [navi pushViewController:productVC animated:YES];
    SCAppController *appController = noti.object;
    appController.isDiscontinue = YES;
}
@end
