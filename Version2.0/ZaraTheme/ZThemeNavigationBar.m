//
//  ZThemeNavigationBar.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCWebViewController.h>
#import <SimiCartBundle/SCMoreViewController.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SCProfileViewController.h>
#import <SimiCartBundle/SCOrderHistoryViewController.h>
#import <SimiCartBundle/SCLoginViewController.h>

#import "ZThemeWorker.h"
#import "ZThemeNavigationBar.h"

@implementation ZThemeNavigationBar

@synthesize countryStateController;

#pragma mark Init Base & Reference
+ (instancetype)sharedInstance{
    static ZThemeNavigationBar *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZThemeNavigationBar alloc] init];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidChangeCart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"PushLoginNormal" object:nil];
    }
    return self;
}

- (NSMutableArray *)leftButtonItems{
    if (_leftButtonItems == nil) {
        _leftButtonItems = [[NSMutableArray alloc] init];
        
        UIButton *listButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [listButton setImage:[UIImage imageNamed:@"Ztheme_icon_menu.png"] forState:UIControlStateNormal];
        [listButton addTarget:self action:@selector(didSelectListBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [listButton setAdjustsImageWhenHighlighted:YES];
        [listButton setAdjustsImageWhenDisabled:YES];
        _listItem = [[UIBarButtonItem alloc] initWithCustomView:listButton];
        
        [_leftButtonItems addObjectsFromArray:@[_listItem]];
    }
    return _leftButtonItems;
}

- (ZThemeLeftMenu*)zThemeLeftMenu
{
    if (_zThemeLeftMenu == nil) {
        _zThemeLeftMenu = [[ZThemeLeftMenu alloc]initWithFrame:CGRectMake(-275, 0, 275, 60)];
        _zThemeLeftMenu.delegate = self;
        [self getStores];
    }
    return _zThemeLeftMenu;
}

- (void)getStores{
    _storeCollection = [[SimiStoreModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:_storeCollection];
    [_storeCollection getStoreCollection];
}

- (ZThemeCartViewController *)cartController
{
    if (_cartController == nil) {
        _cartController = [[ZThemeCartViewController alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:_cartController selector:@selector(didReceiveNotification:) name:@"AddToCart" object:nil];
    }
    return _cartController;
}

- (NSMutableArray *)rightButtonItems{
    if (_rightButtonItems == nil) {
        _rightButtonItems = [[NSMutableArray alloc] init];
        
        UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [cartButton setImage:[UIImage imageNamed:@"ztheme_ic_cart.png"] forState:UIControlStateNormal];
        [cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [_cartBadge setTintColor:THEME_COLOR];
        
        _cartItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
        if (_cartBadge == nil) {
            _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:cartButton];
            _cartBadge.shouldHideBadgeAtZero = YES;
            _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
            _cartBadge.badgeMinSize = 3;
            _cartBadge.badgePadding = 3;
            _cartBadge.badgeOriginX = cartButton.frame.size.width - 10;
            _cartBadge.badgeOriginY = cartButton.frame.origin.y - 3;
            _cartBadge.badgeFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            [_cartBadge setTintColor:THEME_COLOR];
            _cartBadge.badgeBGColor = [UIColor whiteColor];
            _cartBadge.badgeTextColor = THEME_COLOR;
        }
        [_rightButtonItems addObjectsFromArray:@[_cartItem]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeNavigationBar_ReturnRightButtonItems" object:_rightButtonItems];
    return _rightButtonItems;
}

#pragma mark Touch Action

- (void)didSelectListBarItem:(id)sender
{
    if (!self.isShowingLeftMenu) {
        [_zThemeLeftMenu didClickShow];
        self.isShowingLeftMenu = YES;
    }
}

- (void)didSelectCartBarItem:(id)sender
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
        if ([viewControllerTemp isKindOfClass:[ZThemeCartViewController class]]) {
            [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
            return;
        }
    }
    if (![viewController isKindOfClass:[ZThemeCartViewController class]] && ![viewController isKindOfClass:[ZThemeOrderViewController class]]) {
        [(UINavigationController *)currentVC pushViewController:[ZThemeCartViewController sharedInstance] animated:YES];
        return;
    }
    
    if ([viewController isKindOfClass:[ZThemeOrderViewController class]]) {
        [(UINavigationController *)currentVC popViewControllerAnimated:YES];
    }
    
}

#pragma mark Notification Action

- (void)didReceiveNotification:(NSNotification *)noti{
    
    if ([noti.name isEqualToString:@"DidChangeCart"]) {
        _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
    } else if([noti.name isEqualToString:@"PushLoginNormal"])
    {
        [self backToHomeWhenLogin];
    }else
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if ([noti.name isEqualToString:@"DidGetStoreCollection"]) {
                [countryStateController.tableView reloadData];
                [self.zThemeLeftMenu cusSetCells:nil];
            }else if ([noti.name isEqualToString:@"DidGetStore"])
            {
                [[[SimiGlobalVar sharedInstance] store] saveToLocal];
                [self removeObserverForNotification:noti];
                [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] switchLanguage];
            }
        }
    }
}

- (void)backToHomeWhenLogin
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
    
}

#pragma mark Left Menu Delegate
-(void)menu:(ZThemeLeftMenu *)menu didClickShowButonWithShow:(BOOL)show
{
    UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (show) {
        CGFloat size = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
        ILTranslucentView *view = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        view.backgroundColor = [UIColor clearColor];
        view.translucentTintColor = [UIColor blackColor];
        view.translucentStyle = UIBarStyleDefault;
        view.translucentAlpha = 0.5;
        view.simiObjectIdentifier = ZTHEME_TRANSLUCENTVIEW;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.zThemeLeftMenu action:@selector(didClickHide)];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.zThemeLeftMenu action:@selector(didClickHide)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        singleTap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:singleTap];
        [view addGestureRecognizer:swipe];
        [navi.view addSubview:view];
        [navi.view bringSubviewToFront:self.zThemeLeftMenu];
    }else{
        self.isShowingLeftMenu = NO;
        for (UIView * view in navi.view.subviews ) {
            if ([(NSString*)view.simiObjectIdentifier isEqualToString:ZTHEME_TRANSLUCENTVIEW]) {
                [view removeFromSuperview];
            }
        }
    }
}


- (void)menu:(ZThemeLeftMenu *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath *)indexPath{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCListMenu_DidSelectRow" object:self userInfo:@{@"simirow":row, @"indexPath":indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiTable *cells = menu.cells;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    
    if ([section.identifier isEqualToString:ZTHEME_SECTION_MYACCOUNT]) {
        if ([row.identifier isEqualToString:ZTHEME_ROW_PROFILE]) {
            SCProfileViewController *nextController = [[SCProfileViewController alloc]init];
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
            nextController.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBar] rightButtonItems];
        }else if ([row.identifier isEqualToString:ZTHEME_ROW_ADDRESSBOOK])
        {
            SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
            nextController.isGetOrderAddress = NO;
            nextController.enableEditing = YES;
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
            nextController.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBar] rightButtonItems];
        }else if([row.identifier isEqualToString:ZTHEME_ROW_ORDERHISTORY])
        {
            SCOrderHistoryViewController *nextController = [[SCOrderHistoryViewController alloc]init];
            [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
            nextController.navigationItem.rightBarButtonItems = [[[ZThemeWorker sharedInstance]navigationBar] rightButtonItems];
        }
    }else if ([section.identifier isEqualToString:ZTHEME_SECTION_MORE])
    {
        if([row.identifier isEqualToString:ZTHEME_ROW_CMS])
        {
            SCWebViewController *webViewController = [[SCWebViewController alloc] init];
            webViewController.title = row.title;
            webViewController.content = [row.data valueForKey:@"content"];
            [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
        }
    }else if ([section.identifier isEqualToString:ZTHEME_SECTION_MAIN])
    {
        if ([row.identifier isEqualToString:ZTHEME_ROW_STOREVIEW]) {
            _currentStore = [[SimiGlobalVar sharedInstance]store];
            countryStateController = [[SCCountryStateViewController alloc] init];
            [countryStateController setDataType:@"store"];
            
            [countryStateController setFixedData: _storeCollection];
            countryStateController.navigationItem.title = SCLocalizedString(@"Store");
            [countryStateController setSelectedName:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_name"]];
            [countryStateController setSelectedId:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_id"]];
            countryStateController.delegate = self;
            
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController*)currentVC pushViewController:countryStateController animated:YES];
        }else if([row.identifier isEqualToString:ZTHEME_ROW_HOME])
        {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
        }else if ([row.identifier isEqualToString:ZTHEME_ROW_CATEGORY])
        {
            ZThemeCategoryViewController *nextController = [[ZThemeCategoryViewController alloc]init];
            nextController.navigationItem.title = SCLocalizedString(@"Category");
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController*)currentVC pushViewController:nextController animated:YES];
        }
    }
}

- (void)didTouchSignInButton
{
     if ([[SimiGlobalVar sharedInstance]isLogin]) {
         SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:nil];
         [customer logout];
         UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
         [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
     }else{
         UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
         SCLoginViewController *nextController = [[SCLoginViewController alloc]init];
         [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
     }
}

- (void)didSelectRecentProductWithProductModel:(NSMutableDictionary*)productModel
{
    ZThemeProductViewController *zThemeProductViewController = [ZThemeProductViewController new];
    NSString *productID = [productModel valueForKey:@"product_id"];
    zThemeProductViewController.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[productID]];
    zThemeProductViewController.firstProductID = productID;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
    [(UINavigationController*)currentVC pushViewController:zThemeProductViewController animated:YES];
}

#pragma mark Country State Delegates
- (void)didSelectCountryWithId:(NSString *)countryId countryCode:(NSString *)countryCode countryName:(NSString *)countryName{
    if (![countryId isEqualToString:[[[[SimiGlobalVar sharedInstance] store] valueForKey:@"store_config"] valueForKey:@"store_id"]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStore" object:[[SimiGlobalVar sharedInstance] store]];
        [[[SimiGlobalVar sharedInstance] store] getStoreWithStoreId:countryId];
    }
}

@end
