//
//  SCNavigationBar_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/13/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCWebViewController.h>
#import <SimiCartBundle/SCMoreViewController.h>
#import <SimiCartBundle/SimiNavigationController.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SCAddressViewController.h>
#import <SimiCartBundle/SCProfileViewController.h>
#import <SimiCartBundle/SCOrderHistoryViewController.h>

#import "SCHomeViewController_Theme01.h"
#import "SCCategoryViewController_Theme01.h"
#import "SCGridViewController_Theme01.h"
#import "SCLoginViewController_Theme01.h"
#import "SCOrderViewController_Theme01.h"
#import "SCCartViewController_Theme01.h"
#import "SCNavigationBar_Theme01.h"
#import "SimiThemeWorker.h"

#define TRANSLUCENT_VIEW 123

@implementation SCNavigationBar_Theme01

@synthesize countryStateController;

+ (instancetype)sharedInstance{
    static SCNavigationBar_Theme01 *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCNavigationBar_Theme01 alloc] init];
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
        [listButton setImage:[UIImage imageNamed:@"theme1_icon_menu.png"] forState:UIControlStateNormal];
        [listButton addTarget:self action:@selector(didSelectListBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [listButton setAdjustsImageWhenHighlighted:YES];
        [listButton setAdjustsImageWhenDisabled:YES];
        _listItem = [[UIBarButtonItem alloc] initWithCustomView:listButton];
        
        [_leftButtonItems addObjectsFromArray:@[_listItem]];
    }
    return _leftButtonItems;
}

- (SCListMenu_Theme01*)listMenuView
{
    if (_listMenuView == nil) {
        _listMenuView = [[SCListMenu_Theme01 alloc]initWithFrame:CGRectMake(-275, 0, 275, 60)];
        _listMenuView.delegate = self;
        [self getStores];
    }
    return _listMenuView;
}

- (UIView*)virtualHomeView
{
    if (_virtualHomeView == nil) {
        _virtualHomeView = [[SCVirtualHomeView_Theme01 alloc]initWithFrame:CGRectMake(30, 20, 48, 48)];
        UIImage *virtualHome = [UIImage imageNamed:@"theme01_virtual_home"];
        UIImageView *virtualHomeImage = [[UIImageView alloc]init];
        virtualHomeImage.image = virtualHome;
        virtualHomeImage.frame = CGRectMake(7, 7, 34, 34);
        UIButton *btlVirtualHome = [[UIButton alloc]initWithFrame:_virtualHomeView.bounds];
        [btlVirtualHome addTarget:self action:@selector(didSelectVirtualHome) forControlEvents:UIControlEventTouchUpInside];
        [btlVirtualHome addTarget:self action:@selector(touchEnd) forControlEvents:UIControlEventTouchDown];
        [_virtualHomeView addSubview:virtualHomeImage];
        [_virtualHomeView addSubview:btlVirtualHome];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
        [panRecognizer setDelegate:self];
        panRecognizer.maximumNumberOfTouches = 2;
        panRecognizer.minimumNumberOfTouches = 1;
        _virtualHomeView.gestureRecognizers = @[panRecognizer];
    }
    return _virtualHomeView;
}

-(void)touchEnd
{
    [_virtualHomeView.superview bringSubviewToFront:_virtualHomeView];
    
    _virtualHomeView.lastLocation = _virtualHomeView.center;
    
    NSLog(@"Last point %f,%f",_virtualHomeView.lastLocation.x,_virtualHomeView.lastLocation.y);
}


- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer
{
    CGPoint translation = [uiPanGestureRecognizer translationInView:_virtualHomeView.superview];
//    if(_virtualHomeView.center.x>=_virtualHomeView.bounds.size.width/2
//       && _virtualHomeView.center.y>=_virtualHomeView.bounds.size.height/2
//       && _virtualHomeView.center.x+_virtualHomeView.bounds.size.width/2<=[[UIScreen mainScreen] bounds].size.width
//       && _virtualHomeView.center.y+_virtualHomeView.bounds.size.height/2<=[[UIScreen mainScreen] bounds].size.height)
        _virtualHomeView.center = CGPointMake(_virtualHomeView.lastLocation.x + translation.x,
                                          _virtualHomeView.lastLocation.y + translation.y);
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Promote the touched view
    [_virtualHomeView.superview bringSubviewToFront:_virtualHomeView];
    
    _virtualHomeView.center = _virtualHomeView.lastLocation;
}


- (SCCartViewController_Theme01 *)cartController
{
    if (_cartController == nil) {
        _cartController = [[SCCartViewController_Theme01 alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:_cartController selector:@selector(didReceiveNotification:) name:@"AddToCart" object:nil];
    }
    return _cartController;
}

- (NSMutableArray *)rightButtonItems{
    if (_rightButtonItems == nil) {
        _rightButtonItems = [[NSMutableArray alloc] init];
        
        UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [cartButton setImage:[UIImage imageNamed:@"theme1_icon_cart.png"] forState:UIControlStateNormal];
        [cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [_cartBadge setTintColor:THEME_COLOR];
        
        _cartItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
        if (_cartBadge == nil) {
            _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:cartButton];
            _cartBadge.shouldHideBadgeAtZero = YES;
            _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
            _cartBadge.badgeMinSize = 4;
            _cartBadge.badgePadding = 4;
            _cartBadge.badgeOriginX = cartButton.frame.size.width - 10;
            _cartBadge.badgeOriginY = cartButton.frame.origin.y - 3;
            _cartBadge.badgeFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            [_cartBadge setTintColor:THEME_COLOR];
            _cartBadge.badgeBGColor = [UIColor whiteColor];
            _cartBadge.badgeTextColor = THEME_COLOR;
        }
        [_rightButtonItems addObjectsFromArray:@[_cartItem]];
    }
    return _rightButtonItems;
}

- (void)didSelectVirtualHome
{
    [_listMenuView didClickShow];
}


- (void)didSelectListBarItem:(id)sender
{
    [_listMenuView didClickShow];
}

- (void)didSelectSearchBarItem:(id)sender
{
    
}
- (void)didSelectCartBarItem:(id)sender
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
        if ([viewControllerTemp isKindOfClass:[SCCartViewController_Theme01 class]]) {
            [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
            return;
        }
    }
    if (![viewController isKindOfClass:[SCCartViewController_Theme01 class]] && ![viewController isKindOfClass:[SCOrderViewController_Theme01 class]]) {
        [(UINavigationController *)currentVC pushViewController:[SCCartViewController_Theme01 sharedInstance] animated:YES];
    }
}

#pragma mark List Menu Delegate
- (void)backToHomeWhenLogin
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
    
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

- (void)menu:(SCListMenu_Theme01 *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath *)indexPath{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCListMenu_DidSelectRow" object:self userInfo:@{@"simirow":row, @"indexPath":indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiTable *cells = menu.cells;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    
    if ([section.identifier isEqualToString:THEME01_LISTMENU_SECTION_MYACCOUNT]) {
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_PROFILE]) {
            if ([[SimiGlobalVar sharedInstance]isLogin]) {
                SCProfileViewController *nextController = [[SCProfileViewController alloc]init];
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
                nextController.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
                [nextController.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance]navigationBar] virtualHomeView]];
            }else
            {
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc]init];
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
                nextController.scLoginWhenClick = SCLoginWhenClickProfile;
            }
        }else if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_ADDRESS])
        {
            if ([[SimiGlobalVar sharedInstance]isLogin]) {
                SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
                nextController.isGetOrderAddress = NO;
                nextController.enableEditing = YES;
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
                nextController.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
                [nextController.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance]navigationBar] virtualHomeView]];
            }else
            {
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc]init];
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
                nextController.scLoginWhenClick = SCLoginWhenClickAddressBook;
            }

        }else if([row.identifier isEqualToString:THEME01_LISTMENU_ROW_ORDERHISTORY])
        {
            if([[SimiGlobalVar sharedInstance]isLogin])
            {
                SCOrderHistoryViewController *nextController = [[SCOrderHistoryViewController alloc]init];
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
                nextController.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
                [nextController.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance]navigationBar] virtualHomeView]];
            }else
            {
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc]init];
                nextController.scLoginWhenClick = SCLoginWhenClickOrderHistory;
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
            }
        }
    }else if ([section.identifier isEqualToString:THEME01_LISTMENU_SECTION_MORE])
    {
        if ([row.identifier isEqualToString:THEME01_LISTMENU_ROW_SIGNIN]) {
            if ([[SimiGlobalVar sharedInstance]isLogin]) {
                SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:nil];
                [customer logout];
            }else
            {
                SCLoginViewController_Theme01 *nextController = [[SCLoginViewController_Theme01 alloc]init];
                [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
                nextController.scLoginWhenClick = SCLoginWhenClickSignIn;
            }
        }else if([row.identifier isEqualToString:THEME01_LISTMENU_ROW_CMS])
        {
            
            SCWebViewController *webViewController = [[SCWebViewController alloc] init];
            webViewController.title = row.title;
            webViewController.content = [row.data valueForKey:@"content"];
            [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
        }
    }
}

- (void)didSearchButtonClicked: (NSString *)searchText
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    SCGridViewController_Theme01 *nextController = [[SCGridViewController_Theme01 alloc]init];
    nextController.scCollectionGetProductType = SCCollectionGetProductTypeFromSearch;
    [nextController searchProductWithKey:searchText];
    nextController.navigationItem.title = [NSString stringWithFormat:@"\"%@\"", searchText];
    [(UINavigationController *)currentVC pushViewController:nextController animated:YES];
}

- (void)getStores{
    _storeCollection = [[SimiStoreModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:_storeCollection];
    [_storeCollection getStoreCollection];
}

- (void)didClickStoreButton
{
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
    countryStateController.navigationItem.rightBarButtonItems = [[[SimiThemeWorker sharedInstance]navigationBar] rightButtonItems];
    [countryStateController.navigationController.view addSubview:[[[SimiThemeWorker sharedInstance]navigationBar] virtualHomeView]];
}
- (void)didClickHomeButton
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
}
- (void)didClickCategoryButton
{
    SCCategoryViewController_Theme01 *nextController = [[SCCategoryViewController_Theme01 alloc]init];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
    [(UINavigationController*)currentVC pushViewController:nextController animated:YES];
}
#pragma mark Receive Notification

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
            }else if ([noti.name isEqualToString:@"DidGetStore"])
            {
                [[[SimiGlobalVar sharedInstance] store] saveToLocal];
                [self removeObserverForNotification:noti];
                [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] switchLanguage];
            }
        }
    }
}

#pragma mark Country State Delegates
- (void)didSelectCountryWithId:(NSString *)countryId countryCode:(NSString *)countryCode countryName:(NSString *)countryName{
    if (![countryId isEqualToString:[[[[SimiGlobalVar sharedInstance] store] valueForKey:@"store_config"] valueForKey:@"store_id"]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStore" object:[[SimiGlobalVar sharedInstance] store]];
        [[[SimiGlobalVar sharedInstance] store] getStoreWithStoreId:countryId];
        [self startLoadingData];
    }
}

@end
