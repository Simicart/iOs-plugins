//
//  SCAppWishlist4Theme01.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/4/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlist4Theme01.h"
#import <SimiCartBundle/UIButton+WebCache.h>
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCLoginViewController.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import "SCAppWishlistViewController.h"
#import "SimiGlobalVar+WishlistVar.h"
#import "AppWishlistiPadViewController.h"

#define THEME01_IMAGEVIEW_TAG 1000


#define WISHLISTROW_ID @"wishlistRowTheme01"

@implementation SCAppWishlist4Theme01
{
    SCAppWishlistViewController * wishlistViewController;
    AppWishlistiPadViewController * wishlistiPadViewController;
    SCLoginViewController * loginVC;
    UIPopoverController * wishlistPopOver;
    
}


@synthesize listMenuViewRow, appwishlistCoreWorker, imageView4Theme;

-(id)init
{
    self = [super init];
    if (self) {
        
        self.actived = NO;
        
        imageView4Theme = [[UIImageView alloc]init];
        imageView4Theme.tag = THEME01_IMAGEVIEW_TAG;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCProductViewController_Theme01_controllerViewWillAppear:) name:@"SCProductViewController-ViewWillAppear" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCProductViewControllerPad_Theme01_controllerViewWillAppear:) name:@"SCProductViewControllerPad_Theme01-ViewWillAppear" object:nil];
        
        wishlistViewController = [SCAppWishlistViewController singleton];
        wishlistiPadViewController = [[AppWishlistiPadViewController alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCellToListMenu:) name:@"SCListMenu_Theme01-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuDidSelectRow:) name:@"SCListMenu_DidSelectRow" object:nil];
        
        self.iconImagePath = @"wishlisticon3";
        if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
            self.iconImagePath = @"ztheme_ic_wishlist_iconmenu";
        }
        
        if (listMenuViewRow == nil) {
            listMenuViewRow = [self createRowForLeftView];
        }
        
    }
    return self;
}


-(SimiRow *)createRowForLeftView
{
    UIImage *icon = [SCAppWishlist imageWithName:self.iconImagePath withColor:[UIColor whiteColor]];
    SimiRow *tempRow = [[SimiRow alloc]initWithIdentifier:THEME01_ACCOUNT_CELL height:45];
    tempRow.simiObjectIdentifier = THEME01_SIMIOBJECT_MYWISHLIST;
    tempRow.title = SCLocalizedString(@"My Wishlist");
    tempRow.image = icon;
    tempRow.accessoryType = UITableViewCellAccessoryNone;
    tempRow.identifier = WISHLISTROW_ID;
    return tempRow;
}


#pragma -
#pragma mark Event Observer

-(void)addCellToListMenu:(NSNotification *) noti
{
    NSMutableArray * cell = noti.object;
    SimiSection * tempSect = (SimiSection *)[cell objectAtIndex:1];
    [tempSect addObject:listMenuViewRow];
}

-(void)listMenuDidSelectRow:(NSNotification *) noti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidSelectMyWishlistCellAtIndexPath" object:nil];
    SimiRow * currentRow = (SimiRow *)[noti.userInfo objectForKey:@"simirow"];
    if([currentRow.identifier isEqualToString:WISHLISTROW_ID])
    {
        NSObject * navi = noti.object;
        navi.isDiscontinue = YES;
        [self pushWishlistViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectMyWishlistCellAtIndexPath:) name:@"DidSelectMyWishlistCellAtIndexPath" object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidLogin" object:nil];
    }
}


-(void)didCancelLogin: (NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidLogin" object:nil];
    [self removeObserverForNotification:noti];
}
-(void)didLogin: (NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        [self removeObserverForNotification:noti];
        
        if (wishlistPopOver != nil) {
            [wishlistPopOver dismissPopoverAnimated:YES];
            wishlistPopOver = nil;
        }
        
        if (!loginVC)
            return;
        UINavigationController *currentVC = loginVC.navigationController;
        @try {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [currentVC pushViewController:wishlistiPadViewController animated:YES];
                globalAppWishlistiPadViewController = wishlistiPadViewController;
            }
            else {
                [currentVC popToRootViewControllerAnimated:YES];
                [currentVC pushViewController:wishlistViewController animated:YES];
                [loginVC removeObserverForNotification:noti];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
}
-(void)didSelectMyWishlistCellAtIndexPath: (NSNotification *)noti
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    id theme01Obj = [[NSClassFromString(@"SCProductViewController_Theme01") alloc]init];
    if ([theme01Obj respondsToSelector:@selector(getProduct)]) {
        SCProductViewController *productController = (SCProductViewController *)theme01Obj;
         NSString * productId = (NSString *)noti.object;
        productController.productId = productId;
        [theme01Obj getProduct];
        //[productController getProduct];
        [globalAppWishlistViewController.navigationController pushViewController:productController animated:YES];
        globalAppWishlistViewController.isDiscontinue = YES;
    }
}

-(void)SCProductViewController_Theme01_InitializedProductCell: (NSNotification *)noti
{
    NSIndexPath * a = [noti.userInfo objectForKey:@"indexPath"];
    if((a.row == 0)&&(a.section ==0 ))
    {
        UITableViewCell* tempCell = (UITableViewCell *)noti.object;
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [tempCell addSubview:imageView4Theme];
        }
        else if (appwishlistCoreWorker.productViewController!=nil) {
            [appwishlistCoreWorker.productViewController.view addSubview:imageView4Theme];
        }
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"InitializedProductCell-After" object:nil];
        [appwishlistCoreWorker addAddToWishlistButtonToProductView:appwishlistCoreWorker.imageView :appwishlistCoreWorker.product];
    }
}



-(void)SCProductViewController_Theme01_controllerViewWillAppear: (NSNotification*)noti
{
    NSString * viewClassName = NSStringFromClass([noti.object class]);
    if([viewClassName isEqualToString:@"SCProductViewController_Theme01"])
    {
        self.actived = YES;
        
        appwishlistCoreWorker.productViewController = (SCProductViewController *)noti.object;
        appwishlistCoreWorker.product = appwishlistCoreWorker.productViewController.product;
        appwishlistCoreWorker.imageView = imageView4Theme;
        appwishlistCoreWorker.reloadAddToWishlistIcon = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCProductViewController_Theme01_InitializedProductCell:) name:@"InitializedProductCell-After" object:nil];
    }
}
-(void)SCProductViewControllerPad_Theme01_controllerViewWillAppear: (NSNotification *)noti
{
    NSString * viewClassName = NSStringFromClass([noti.object class]);
    if([viewClassName isEqualToString:@"SCProductViewControllerPad_Theme01"])
    {
        self.actived = YES;
        
        appwishlistCoreWorker.productViewController = (SCProductViewController *)noti.object;
        appwishlistCoreWorker.product = appwishlistCoreWorker.productViewController.product;
        appwishlistCoreWorker.imageView = imageView4Theme;
        appwishlistCoreWorker.reloadAddToWishlistIcon = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SCProductViewController_Theme01_InitializedProductCell:) name:@"InitializedProductCell-After" object:nil];
    }
}

-(void)viewControllerDidLoad:(NSNotification *)noti
{
    NSString * viewClassName = NSStringFromClass([noti.object class]);
    if([viewClassName isEqualToString:@"SCCartViewController_Pad"])
    {
        globalCartViewController = noti.object;
    }
}
#pragma mark actions
- (void)pushWishlistViewController
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (![[SimiGlobalVar sharedInstance]isLogin]) {
        loginVC = [[SCLoginViewController alloc]init];
        loginVC.navigationItem.title = [SCLocalizedString(@"Sign In") uppercaseString];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *navi;
            navi = [[UINavigationController alloc]initWithRootViewController:loginVC];
            
            if(wishlistPopOver == nil){
                wishlistPopOver = [[UIPopoverController alloc]initWithContentViewController:navi];
            }
            [wishlistPopOver presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
            wishlistPopOver.delegate = self;
        }
        else
            [(UINavigationController *)currentVC pushViewController:loginVC animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelLogin:) name:@"SCLoginViewController-DidCancel" object:nil];
    }
    else
    {
        @try {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
                [(UINavigationController *)currentVC pushViewController:wishlistiPadViewController animated:YES];
                
                UINavigationBar * bar = [(UINavigationController *)currentVC navigationBar];
                [bar setBackgroundImage:[[UIImage imageNamed:@"pixel"]imageWithColor:THEME_COLOR] forBarMetrics:UIBarMetricsDefault];
                [bar setTintColor:[UIColor whiteColor]];
                globalAppWishlistiPadViewController = wishlistiPadViewController;
            }
            else {
                [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
                [(UINavigationController *)currentVC pushViewController:wishlistViewController animated:YES];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
}

#pragma mark dealloc


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
