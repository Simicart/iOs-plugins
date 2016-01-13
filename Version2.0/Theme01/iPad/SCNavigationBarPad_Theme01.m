//
//  SCNavigationBar_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/13/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCCountryStateViewController.h>
#import <SimiCartBundle/SCProfileViewController.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SCOrderHistoryViewController.h>
#import <SimiCartBundle/SCWebViewController.h>

#import "SCHomeViewController_Theme01.h"
#import "SCNavigationBarPad_Theme01.h"
#import "SCLoginViewController_Theme01.h"

#define TRANSLUCENT_VIEW 123
@class SimiThemeWorker;
@implementation SCNavigationBarPad_Theme01
{
    SCCountryStateViewController *countryStateController;
}
@synthesize popController;

+ (instancetype)sharedInstance{
    static SCNavigationBarPad_Theme01 *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCNavigationBarPad_Theme01 alloc] init];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidChangeCart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"PushLoginNormal" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCCartViewControllerPad_Theme01-ViewWillDisappear" object:nil];
        _isShowSearchBar = NO;
    }
    return self;
}

- (NSMutableArray *)leftButtonItems{
    if (_leftButtonItems == nil) {
        _leftButtonItems = [[NSMutableArray alloc] init];

        UIButton *listButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [listButton setImage:[UIImage imageNamed:@"theme1_icon_menu"] forState:UIControlStateNormal];
        [listButton addTarget:self action:@selector(didSelectListBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [listButton setAdjustsImageWhenHighlighted:YES];
        [listButton setAdjustsImageWhenDisabled:YES];
        _listItem = [[UIBarButtonItem alloc] initWithCustomView:listButton];
        
        [_leftButtonItems addObjectsFromArray:@[_listItem]];
    }
    return _leftButtonItems;
}

- (SCListMenuPad_Theme01*)listMenuView
{
    if (_listMenuView == nil) {
        _listMenuView = [[SCListMenuPad_Theme01 alloc]initWithFrame:CGRectMake(-375, 0, 375, 1)];
        [self getStores];
    }
    _listMenuView.delegate = self;
    return _listMenuView;
}

- (NSMutableArray *)rightButtonItems{
    _rightButtonItems = [[NSMutableArray alloc] init];
    if (_cartButton == nil) {
        _cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_cartButton setImage:[UIImage imageNamed:@"theme1_icon_cart"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _cartItem = [[UIBarButtonItem alloc] initWithCustomView:_cartButton];
    if (_cartBadge == nil) {
        _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:_cartButton];
        _cartBadge.shouldHideBadgeAtZero = YES;
        _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
        _cartBadge.badgeMinSize = 4;
        _cartBadge.badgePadding = 4;
        _cartBadge.badgeOriginX = _cartButton.frame.size.width - 10;
        _cartBadge.badgeOriginY = _cartButton.frame.origin.y - 3;
        _cartBadge.badgeFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [_cartBadge setTintColor:THEME_COLOR];
        _cartBadge.badgeBGColor = [UIColor whiteColor];
        _cartBadge.badgeTextColor = THEME_COLOR;
    }

    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.width = 40;
    
    if (!_isShowSearchBar) {
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [searchButton setImage:[UIImage imageNamed:@"theme01_searchbutton"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(didSelectSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        _searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        if (![viewController isKindOfClass:[SCCartViewControllerPad_Theme01 class]] && ![viewController isKindOfClass:[SCOrderViewControllerPad_Theme01 class]]) {
            [_rightButtonItems addObjectsFromArray:@[_cartItem, itemSpace, _searchItem]];
        }else
        {
            [_rightButtonItems addObjectsFromArray:@[itemSpace, _searchItem]];
        }
    }else
    {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 375, 45)];
        _searchBar.placeholder = SCLocalizedString(@"Search");
        _searchBar.delegate = self;
        _searchBar.text = _currentKeySearch;
        _searchItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        if (![viewController isKindOfClass:[SCCartViewControllerPad_Theme01 class]] && ![viewController isKindOfClass:[SCOrderViewControllerPad_Theme01 class]]) {
            [_rightButtonItems addObjectsFromArray:@[_cartItem, itemSpace, _searchItem]];
        }else
        {
            [_rightButtonItems addObjectsFromArray:@[itemSpace, _searchItem]];
        }
    }
    return _rightButtonItems;
}

- (SCCartViewControllerPad_Theme01 *)cartViewController
{
    if (_cartViewController == nil) {
        _cartViewController = [[SCCartViewControllerPad_Theme01 alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:_cartViewController selector:@selector(didReceiveNotification:) name:@"AddToCart" object:nil];
    }
    return _cartViewController;
}


- (void)didSelectListBarItem:(id)sender
{
    if (_searchBar != nil) {
        [_searchBar resignFirstResponder];
    }
    [_listMenuView didClickShow];
}

- (void)didSelectCartBarItem:(id)sender
{
    if (_searchBar != nil) {
        [_searchBar resignFirstResponder];
    }
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
        if ([viewControllerTemp isKindOfClass:[SCCartViewControllerPad_Theme01 class]]) {
            [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
            return;
        }
    }
    if (![viewController isKindOfClass:[SCCartViewControllerPad_Theme01 class]] && ![viewController isKindOfClass:[SCOrderViewControllerPad_Theme01 class]]) {
        [(UINavigationController *)currentVC pushViewController:[SCCartViewControllerPad_Theme01 sharedInstance] animated:YES];
    }
}


- (void)didSelectSearchButton:(id)sender
{
    _isShowSearchBar = YES;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [viewPad reloadRightBarItem];
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
    [viewPad reloadRightBarItem];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _currentKeySearch = _searchBar.text;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SCGridViewControllerPad_Theme01* searchController = [[SCGridViewControllerPad_Theme01 alloc]init];
    searchController.scCollectionGetProductType = SCCollectionGetProductTypeFromSearch;
    searchController.isSearch = YES;
    
    UIViewController *viewPad = [[(UINavigationController*)currentVC viewControllers]lastObject];
    if ([viewPad isKindOfClass:[SCGridViewControllerPad_Theme01 class]]) {
        SCGridViewControllerPad_Theme01 *viewController = (SCGridViewControllerPad_Theme01*)viewPad;
        if (!viewController.isSearch) {
            [(UINavigationController *)currentVC pushViewController:searchController animated:YES];
            [searchController searchProductWithKey:searchBar.text];
        }else
        {
            [viewController searchProductWithKey:searchBar.text];
        }
    }else
    {
        [(UINavigationController *)currentVC pushViewController:searchController animated:YES];
        [searchController searchProductWithKey:searchBar.text];
    }
    
    
    [searchBar resignFirstResponder];
    _isShowSearchBar = NO;
    SimiViewController *viewControllerTemp = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [viewControllerTemp reloadRightBarItem];
}

#pragma mark SCListMenu Delegate
- (void)backToHomeWhenLogin
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    if (![viewController isKindOfClass:[SCCartViewControllerPad_Theme01 class]]) {
        [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
    }
}
- (void)getOutToCartWhenDidLogout
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
}

-(void)menu:(SCListMenuPad_Theme01 *)menu didClickShowButonWithShow:(BOOL)show
{
    UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (show) {
        CGFloat size = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
        ILTranslucentView *view = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        view.backgroundColor = [UIColor clearColor];
        view.translucentTintColor = [UIColor blackColor];
        view.translucentStyle = UIBarStyleDefault;
        view.translucentAlpha = 0.5;
        view.tag = TRANSLUCENT_VIEW;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.listMenuView action:@selector(didClickHide)];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.listMenuView action:@selector(didClickHide)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        singleTap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:singleTap];
        [view addGestureRecognizer:swipe];
        [navi.view addSubview:view];
        [navi.view bringSubviewToFront:self.listMenuView];
    }else{
        for (UIView * view in navi.view.subviews ) {
            if (view.tag == TRANSLUCENT_VIEW) {
                [view removeFromSuperview];
            }
        }
    }
}

- (void)menu:(SCListMenuPad_Theme01 *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath *)indexPath{
    UIViewController *currentVC = (SimiViewController*)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCListMenu_DidSelectRow" object:self userInfo:@{@"simirow":row, @"indexPath":indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    SimiTable *cells = menu.cells;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    
    if ([section.identifier isEqualToString:THEME01_LISTMENU_SECTION_MYACCOUNT]) {
        UINavigationController *navi;
        SCLoginViewController_Theme01 *loginController = [[SCLoginViewController_Theme01 alloc] init];
        loginController.isInPopover = YES;
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_PROFILE]) {
            if ([[SimiGlobalVar sharedInstance] isLogin]) {
                SCProfileViewController *profileController = [[SCProfileViewController alloc] init];
                navi = [[UINavigationController alloc]initWithRootViewController:profileController];
                
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                profileController.isInPopover = YES;
                profileController.popover = popController;
            }else
            {
                navi = [[UINavigationController alloc]initWithRootViewController:loginController];
                
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                loginController.scLoginWhenClick = SCLoginWhenClickProfile;
                loginController.popover = popController;
            }
        }else if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_ADDRESS])
        {
            if ([[SimiGlobalVar sharedInstance] isLogin]) {
                SCAddressViewController *addressController = [[SCAddressViewController alloc] init];
                navi = [[UINavigationController alloc]initWithRootViewController:addressController];
                
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                addressController.enableEditing = YES;
                addressController.isInPopover = YES;
                addressController.popover = popController;
            }else
            {
                navi = [[UINavigationController alloc]initWithRootViewController:loginController];
                
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                loginController.isInPopover = YES;
                loginController.scLoginWhenClick = SCLoginWhenClickAddressBook;
                loginController.popover = popController;
            }
        }else if([row.identifier isEqualToString:THEME01_LISTMENU_ROW_ORDERHISTORY])
        {
            if ([[SimiGlobalVar sharedInstance] isLogin]) {
                SCOrderHistoryViewController *orderController = [[SCOrderHistoryViewController alloc] init];
                navi = [[UINavigationController alloc]initWithRootViewController:orderController];
                
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                orderController.isInPopover = YES;
                orderController.popover = popController;
            }else
            {
                navi = [[UINavigationController alloc]initWithRootViewController:loginController];
                
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                loginController.isInPopover = YES;
                loginController.scLoginWhenClick = SCLoginWhenClickOrderHistory;
                loginController.popover = popController;
            }
        }
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = [UIColor whiteColor];
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        popController.delegate =  self;
        [viewPad hiddenScreenWhenShowPopOver];
        [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
    }else if ([section.identifier isEqualToString:THEME01_LISTMENU_SECTION_MORE])
    {
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_SIGNIN]) {
            if ([[SimiGlobalVar sharedInstance] isLogin]) {
                SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:nil];
                [customer logout];
                return;
            }else
            {
                SCLoginViewController_Theme01 *loginController = [[SCLoginViewController_Theme01 alloc] init];
                popController = nil;
                popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:loginController]];
                loginController.delegate = self;
                loginController.isInPopover = YES;
                loginController.scLoginWhenClick = SCLoginWhenClickSignIn;
                loginController.popover = popController;
            }
            [viewPad hiddenScreenWhenShowPopOver];
            popController.delegate = self;
            [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        }else if([row.identifier isEqualToString:THEME01_LISTMENU_ROW_CMS])
        {
            SCWebViewController *webViewController = [[SCWebViewController alloc] init];
            webViewController.title = row.title;
            webViewController.content = [row.data valueForKey:@"content"];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
        }
    }
}

- (void)didClickStoreButton
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    _currentStore = [[SimiGlobalVar sharedInstance]store];
    countryStateController = [[SCCountryStateViewController alloc] init];
    [countryStateController setDataType:@"store"];
   
    [countryStateController setFixedData: _storeCollection];
    countryStateController.navigationItem.title = SCLocalizedString(@"Store");
    [countryStateController setSelectedName:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_name"]];
    [countryStateController setSelectedId:[[_currentStore valueForKey:@"store_config"] valueForKey:@"store_id"]];
    countryStateController.delegate = self;
    
    popController = nil;
    popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:countryStateController]];
    popController.delegate = self;
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [viewPad hiddenScreenWhenShowPopOver];
     [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
    
}

- (void)didClickHomeButton
{
    [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] setSelectedIndex:0];
     UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    [viewController.navigationController popToRootViewControllerAnimated:NO];
    
}

- (void)didClickCategoryButton
{
    [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] setSelectedIndex:0];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    
    SCGridViewControllerPad_Theme01 *gridViewController = [[SCGridViewControllerPad_Theme01 alloc]init];
    gridViewController.scCollectionGetProductType = SCCollectionGetProductTypeFromCategory;
    gridViewController.isCategory = YES;
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
    [(UINavigationController *)currentVC pushViewController:gridViewController animated:YES];
}

#pragma mark GetStoreView
- (void)getStores{
    _storeCollection = [[SimiStoreModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:_storeCollection];
    [_storeCollection getStoreCollection];
}

-(void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidChangeCart"]) {
        _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
    } else if([noti.name isEqualToString:@"PushLoginNormal"])
    {
        SCLoginViewController_Theme01 *loginViewController = (SCLoginViewController_Theme01*)noti.object;
        UINavigationController *navi;
        popController = nil;
        switch (loginViewController.scLoginWhenClick) {
            case SCLoginWhenClickAddressBook:
            {
                SCAddressViewController *addressController = [[SCAddressViewController alloc] init];
                navi = [[UINavigationController alloc]initWithRootViewController:addressController];
                
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                addressController.enableEditing = YES;
                addressController.isInPopover = YES;
                addressController.popover = popController;
            }
                break;
            case SCLoginWhenClickProfile:
            {
                SCProfileViewController *profileController = [[SCProfileViewController alloc] init];
                navi = [[UINavigationController alloc]initWithRootViewController:profileController];
                
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                profileController.isInPopover = YES;
                profileController.popover = popController;
            }
                break;
            case SCLoginWhenClickOrderHistory:
            {
                SCOrderHistoryViewController *orderController = [[SCOrderHistoryViewController alloc] init];
                navi = [[UINavigationController alloc]initWithRootViewController:orderController];
                
                popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                orderController.isInPopover = YES;
                orderController.popover = popController;
            }
                break;
            default:
                break;
        }
        if (popController) {
            navi.navigationBar.tintColor = THEME_COLOR;
            if (SIMI_SYSTEM_IOS >= 8) {
                navi.navigationBar.tintColor = [UIColor whiteColor];
            }
            navi.navigationBar.barTintColor = THEME_COLOR;
            popController.delegate =  self;
            UIViewController *currentVC = (SimiViewController*)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            [popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        }
    }else if([noti.name isEqualToString:@"SCCartViewControllerPad_Theme01-ViewWillDisappear"])
    {
        [_searchBar resignFirstResponder];
    }else
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if ([noti.name isEqualToString:@"DidGetStoreCollection"]) {
                [countryStateController.tableView reloadData];
                //  Liam ADD 150417
                if (_storeCollection.count == 1) {
                    NSDictionary *store = [_storeCollection objectAtIndex:0];
                    _storeModel = [SimiStoreModel new];
                    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetStoreView:) name:@"DidGetStore" object:_storeModel];
                    [_storeModel getStoreWithStoreId:[store valueForKey:@"store_id"]];
                }
                //  End
            }else if ([noti.name isEqualToString:@"DidGetStore"])
            {
                [[[SimiGlobalVar sharedInstance] store] saveToLocal];
                [self removeObserverForNotification:noti];
                [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] switchLanguage];
            }
        }
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

#pragma mark popOver Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [viewPad showScreenWhenHiddenPopOver];
}

#pragma mark Login Delegate
- (void)didFinishLoginSuccess
{
    [popController dismissPopoverAnimated:YES];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    [viewPad showScreenWhenHiddenPopOver];
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
@end
