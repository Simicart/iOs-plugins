//
//  ZThemeNavigationBar.m
//  SimiCartPluginFW
//
//  Created by Cody on 5/12/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import "ZThemeNavigationBarPad.h"

#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCProfileViewController.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SCOrderHistoryViewController.h>
#import <SimiCartBundle/SCCountryStateViewController.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>

#import "SimiViewController+ZTheme.h"
#import "ZThemeWorker.h"
#import "ZThemeCategoryViewControllerPad.h"
#import "ZThemeProductListViewControllerPad.h"
#import "ZThemeOrderViewController.h"
#import "ZThemeProductViewControllerPad.h"

@implementation ZThemeNavigationBarPad

@synthesize countryStateController, popController;

+ (instancetype)sharedInstance{
    static ZThemeNavigationBarPad *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ZThemeNavigationBarPad alloc] init];
    });
    return _sharedInstance;
}


- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidChangeCart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"PushLoginNormal" object:nil];
        _isShowSearchBar = NO;
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
        _zThemeLeftMenu = [[ZThemeLeftMenuPad alloc]initWithFrame:CGRectMake(-450, 0, 450, 120)];
        [_zThemeLeftMenu.btnLogin.titleLabel setFont:[UIFont fontWithName:ZTHEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE_REGULAR+4]];
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
    _rightButtonItems = [[NSMutableArray alloc] init];
    if (_cartButton == nil) {
        _cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_cartButton setImage:[UIImage imageNamed:@"ztheme_ic_cart.png"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.alpha = 1;
    }
    
    _cartItem = [[UIBarButtonItem alloc] initWithCustomView:_cartButton];
    if (_cartBadge == nil) {
        _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:_cartButton];
        _cartBadge.shouldHideBadgeAtZero = YES;
        _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
        _cartBadge.badgeMinSize = 4;
        _cartBadge.badgePadding = 4;
        _cartBadge.badgeOriginX = _cartButton.frame.size.width - 15;
        _cartBadge.badgeOriginY = _cartButton.frame.origin.y;
        _cartBadge.badgeFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [_cartBadge setTintColor:THEME_COLOR];
        _cartBadge.badgeBGColor = [UIColor whiteColor];
        _cartBadge.badgeTextColor = THEME_COLOR;
    }
    
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.width = 10;
    
    if (!_isShowSearchBar) {
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        
        [searchButton setImage:[[UIImage imageNamed:@"ztheme_ic_search.png"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(didSelectSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        _searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        [_rightButtonItems addObjectsFromArray:@[_cartItem, itemSpace, _searchItem]];
        
    }else
    {
        if (_searchBar ==nil) {
            _searchBar = [UISearchBar new];
            _searchBar.placeholder = SCLocalizedString(@"Search");
            _searchBar.delegate = self;
        }
        _searchBar.frame = CGRectMake(375, 0, 0, 45);
        [UIView animateWithDuration:0.2 animations:^{
            _searchBar.frame = CGRectMake(0, 0, 375, 45);
        }];
        
        _searchBar.tintColor = THEME_COLOR;
        _searchItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
        [_rightButtonItems addObjectsFromArray:@[itemSpace, _searchItem]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeNavigationBarPad_ReturnRightButtonItems" object:_rightButtonItems];
    return _rightButtonItems;
}


- (void)didSelectListBarItem:(id)sender
{
    if (!self.isShowingLeftMenu) {
        [_zThemeLeftMenu didClickShow];
        self.isShowingLeftMenu = YES;
    }
}


- (void)didSelectSearchButton:(id)sender
{
    _isShowSearchBar = YES;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    viewPad.navigationItem.leftItemsSupplementBackButton = NO;
    [viewPad zThemeReloadRightBarItemPad];
}


- (void)didSelectCartBarItem:(id)sender
{
     if (_searchBar != nil) {
     [_searchBar resignFirstResponder];
     }
     UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
     UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
     if (![viewController isKindOfClass:[ZThemeCartViewControllerPad class]] && ![viewController isKindOfClass:[ZThemeOrderViewController class]]) {
         if ([[(UINavigationController *) currentVC viewControllers] containsObject:[ZThemeCartViewControllerPad sharedInstance]])
             [(UINavigationController *)currentVC popToViewController:[ZThemeCartViewControllerPad sharedInstance] animated:YES];
         else
             [(UINavigationController *)currentVC pushViewController:[ZThemeCartViewControllerPad sharedInstance] animated:YES];
     }
}


#pragma mark Search Bar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _isShowSearchBar = NO;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    viewPad.navigationItem.leftItemsSupplementBackButton = YES;
    [viewPad zThemeReloadRightBarItemPad];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _currentKeySearch = _searchBar.text;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    
    
    [searchBar resignFirstResponder];
    _isShowSearchBar = NO;
    SimiViewController *viewControllerTemp = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [viewControllerTemp zThemeReloadRightBarItemPad];
    
    ZThemeProductListViewControllerPad * nextViewController;
    if ([viewControllerTemp class] == [ZThemeProductListViewControllerPad class])
        nextViewController = (ZThemeProductListViewControllerPad *)viewControllerTemp;
    else
        nextViewController = [[ZThemeProductListViewControllerPad alloc]init];
    
    nextViewController.zCollectionGetProductType = ZThemeCollectioViewGetProductTypeFromSearch;
    nextViewController.keySearchProduct = _currentKeySearch;
    nextViewController.navigationItem.title = [NSString stringWithFormat:@"\"%@\"",_currentKeySearch];
    if (viewControllerTemp != nextViewController)
        [viewControllerTemp.navigationController pushViewController:nextViewController animated:YES];
    else
        [nextViewController initCollectionView];
    [nextViewController.zCollectionView getProducts];
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
        UINavigationController *navi;
        if ([row.identifier isEqualToString:ZTHEME_ROW_PROFILE]) {
            SCProfileViewController *profileController = [[SCProfileViewController alloc] init];
            navi = [[UINavigationController alloc]initWithRootViewController:profileController];
            
            popController = nil;
            popController = [[UIPopoverController alloc] initWithContentViewController:navi];
            profileController.isInPopover = YES;
            profileController.popover = popController;
        }else if ([row.identifier isEqualToString:ZTHEME_ROW_ADDRESSBOOK])
        {
            SCAddressViewController *addressController = [[SCAddressViewController alloc] init];
            navi = [[UINavigationController alloc]initWithRootViewController:addressController];
            
            popController = nil;
            popController = [[UIPopoverController alloc] initWithContentViewController:navi];
            addressController.enableEditing = YES;
            addressController.isInPopover = YES;
            addressController.popover = popController;
        }else if([row.identifier isEqualToString:ZTHEME_ROW_ORDERHISTORY])
        {
            SCOrderHistoryViewController *orderController = [[SCOrderHistoryViewController alloc] init];
            navi = [[UINavigationController alloc]initWithRootViewController:orderController];
            
            popController = nil;
            popController = [[UIPopoverController alloc] initWithContentViewController:navi];
            orderController.isInPopover = YES;
            orderController.popover = popController;
        }
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = [UIColor whiteColor];
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        popController.delegate =  self;
        [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
    }else if ([section.identifier isEqualToString:ZTHEME_SECTION_MORE])
    {
        if([row.identifier isEqualToString:ZTHEME_ROW_CMS])
        {
            SCWebViewController *webViewController = [[SCWebViewController alloc] init];
            webViewController.title = row.title;
            webViewController.content = [row.data valueForKey:@"content"];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
        }
    }
    else if ([section.identifier isEqualToString:ZTHEME_SECTION_MAIN])
    {
        UINavigationController *navi;
        if ([row.identifier isEqualToString:ZTHEME_ROW_STOREVIEW]) {
            _currentStore = [[SimiGlobalVar sharedInstance]store];
            countryStateController = [[SCCountryStateViewController alloc] init];
            [countryStateController setDataType:@"store"];
            
            [countryStateController setFixedData: _storeCollection];
            countryStateController.navigationItem.title = SCLocalizedString(@"Store");
            [countryStateController setSelectedName:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_name"]];
            [countryStateController setSelectedId:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_id"]];
            countryStateController.delegate = self;
            
            navi = [[UINavigationController alloc]initWithRootViewController:countryStateController];
            popController = nil;
            popController = [[UIPopoverController alloc] initWithContentViewController:navi];
            countryStateController.isInPopover = YES;
            countryStateController.popover = popController;
        }else if([row.identifier isEqualToString:ZTHEME_ROW_HOME])
        {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
            return;
        }else if ([row.identifier isEqualToString:ZTHEME_ROW_CATEGORY])
        {
            ZThemeCategoryViewControllerPad *nextController = [[ZThemeCategoryViewControllerPad alloc]init];
            nextController.isInView = NO;
            navi = [[UINavigationController alloc]initWithRootViewController:nextController];
            popController = nil;
            popController = [[UIPopoverController alloc] initWithContentViewController:navi];
            nextController.isInPopover = YES;
            nextController.popover = popController;
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        popController.delegate =  self;
        [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
    }
}



- (void)didTouchSignInButton
{
    if ([[SimiGlobalVar sharedInstance]isLogin]) {
        SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:nil];
        [customer logout];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogin" object:nil];
        UIViewController *currentVC = (SimiViewController*)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        SCLoginViewController * loginController = [SCLoginViewController new];
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:loginController];
        popController = nil;
        popController = [[UIPopoverController alloc] initWithContentViewController:navi];
        loginController.popover = popController;
        navi.navigationBar.barTintColor = THEME_COLOR;
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = [UIColor whiteColor];
        }
        popController.delegate =  self;
        [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
    }
}

- (void)didSelectRecentProductWithProductModel:(NSMutableDictionary*)productModel
{
    ZThemeProductViewControllerPad *zThemeProductViewController = [ZThemeProductViewControllerPad new];
    NSString *productID = [productModel valueForKey:@"product_id"];
    zThemeProductViewController.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[productID]];
    zThemeProductViewController.firstProductID = productID;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
    [(UINavigationController*)currentVC pushViewController:zThemeProductViewController animated:YES];
}


#pragma mark DidGetStoreView
- (void)didGetStoreView:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"])
    {
        [_storeModel saveToLocal];
    }
}

#pragma mark CountryState Delegate
- (void)didSelectCountryWithId:(NSString *)countryId countryCode:(NSString *)countryCode countryName:(NSString *)countryName
{
    if (![countryId isEqualToString:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_id"]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStore" object:_currentStore];
        [_currentStore getStoreWithStoreId:countryId];
    }
}

#pragma mark event Handler

-(void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidChangeCart"]) {
        _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
    } else if([noti.name isEqualToString:@"PushLoginNormal"])
    {
        [popController dismissPopoverAnimated:YES];
        //[self popoverControllerDidDismissPopover:popController];
        popController = nil;
    }else if([noti.name isEqualToString:@"DidLogout"])
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated: YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You have logged out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self removeObserverForNotification:noti];
        }
    }else if([noti.name isEqualToString:@"DidLogin"])
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated: YES];
            [self removeObserverForNotification:noti];
        }
    }
    else
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if ([noti.name isEqualToString:@"DidGetStoreCollection"]) {
                [countryStateController.tableView reloadData];
                if (_storeCollection.count == 1) {
                    NSDictionary *store = [_storeCollection objectAtIndex:0];
                    _storeModel = [SimiStoreModel new];
                    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStoreView:) name:@"DidGetStore" object:_storeModel];
                    [_storeModel getStoreWithStoreId:[store valueForKey:@"store_id"]];
                }
            }else if ([noti.name isEqualToString:@"DidGetStore"])
            {
                [[[SimiGlobalVar sharedInstance] store] saveToLocal];
                [self removeObserverForNotification:noti];
                [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] switchLanguage];
            }
        }
    }
}



- (ZThemeCartViewControllerPad *)cartViewController
{
    if (_cartViewController == nil) {
        _cartViewController = [[ZThemeCartViewControllerPad alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:_cartViewController selector:@selector(didReceiveNotification:) name:@"AddToCart" object:nil];
    }
    return _cartViewController;
}


@end
